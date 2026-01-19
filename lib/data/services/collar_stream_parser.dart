// lib/data/services/collar_stream_parser.dart

import 'package:flutter/foundation.dart';
import '../models/collar_packet_validated.dart';
import '../models/collar_protocol.dart';
import '../../utils/crc_utils.dart';

/// Stream parser for collar BLE data with packet reassembly and array frame handling
///
/// This parser handles:
/// - Fragmented BLE notifications (reassembly buffer)
/// - Array frames (batched packets: 2 or 4 packets per notification)
/// - Both 27-byte and 26-byte element formats
/// - Automatic header alignment
/// - CRC validation
///
/// Based on the working Python BLE visualizer implementation.
class CollarStreamParser {
  /// RX buffer for stream reassembly (handles BLE fragmentation)
  final List<int> _rxBuffer = [];

  /// Known packet/response headers for alignment
  static const Set<int> _knownHeaders = {
    0xF1, // PACKET_TYPE_STANDARD
    0xF2, // PACKET_TYPE_HIGHRES
    0xB1, // PACKET_TYPE_BATTERY
    0x11, // RESP_MODE_SWITCH
    0xAA, // RESP_ACK
    0x55, // RESP_NAK
    0xA0, // Device Info
  };

  /// Statistics
  int _totalBytesReceived = 0;
  int _packetsExtracted = 0;
  int _responsesExtracted = 0;
  int _crcErrors = 0;
  int _alignmentCorrections = 0;

  /// Reset the parser state
  void reset() {
    _rxBuffer.clear();
    _totalBytesReceived = 0;
    _packetsExtracted = 0;
    _responsesExtracted = 0;
    _crcErrors = 0;
    _alignmentCorrections = 0;
  }

  /// Get parser statistics
  Map<String, dynamic> get statistics => {
    'bytes_received': _totalBytesReceived,
    'packets_extracted': _packetsExtracted,
    'responses_extracted': _responsesExtracted,
    'crc_errors': _crcErrors,
    'alignment_corrections': _alignmentCorrections,
    'buffer_size': _rxBuffer.length,
  };

  /// Process incoming BLE data
  ///
  /// Returns a list of parsed packets and responses.
  /// Call this every time you receive a BLE notification.
  ParseResult processData(List<int> data) {
    if (data.isEmpty) {
      return ParseResult(packets: [], responses: []);
    }

    // Add to reassembly buffer
    _rxBuffer.addAll(data);
    _totalBytesReceived += data.length;

    final packets = <CollarPacket>[];
    final responses = <CollarResponse>[];

    // Extract all available packets/responses from buffer
    while (_rxBuffer.isNotEmpty) {
      // Align to known header
      _alignToKnownHeader();

      if (_rxBuffer.isEmpty) break;

      final ptype = _rxBuffer[0];

      // Try to parse stream packets (0xF1, 0xF2)
      if (ptype == 0xF1 || ptype == 0xF2) {
        final streamPackets = _tryParseStreamFrame(ptype);
        if (streamPackets != null) {
          packets.addAll(streamPackets);
          _packetsExtracted += streamPackets.length;
          continue;
        }

        // If array frame parsing failed, not enough data yet
        if (_rxBuffer.length < 27) break;

        // Skip this byte and try next
        _rxBuffer.removeAt(0);
        _alignmentCorrections++;
        continue;
      }

      // Try to parse response
      if (_isResponseType(ptype)) {
        final responseLen = _getExpectedResponseLength(ptype);
        if (responseLen > 0) {
          if (_rxBuffer.length < responseLen) break; // Wait for more data

          final responseBytes = Uint8List.fromList(
            _rxBuffer.sublist(0, responseLen),
          );
          _rxBuffer.removeRange(0, responseLen);

          final response = CollarResponse.fromBytes(responseBytes);
          if (response != null) {
            responses.add(response);
            _responsesExtracted++;
          }
          continue;
        }
      }

      // Unknown packet type, skip one byte
      _rxBuffer.removeAt(0);
      _alignmentCorrections++;
    }

    return ParseResult(packets: packets, responses: responses);
  }

  /// Align buffer to known header byte
  void _alignToKnownHeader() {
    int removedBytes = 0;
    while (_rxBuffer.isNotEmpty && !_knownHeaders.contains(_rxBuffer[0])) {
      _rxBuffer.removeAt(0);
      removedBytes++;
    }
    if (removedBytes > 0) {
      _alignmentCorrections += removedBytes;
      debugPrint('[StreamParser] Aligned: skipped $removedBytes unknown bytes');
    }
  }

  /// Try to parse stream frame (handles array frames and single packets)
  ///
  /// Returns list of packets if successful, null if more data needed
  List<CollarPacket>? _tryParseStreamFrame(int ptype) {
    // Check for array frame format
    final arrayPackets = _tryParseArrayFrame(ptype);
    if (arrayPackets != null) return arrayPackets;

    // Try single 27-byte packet
    if (_rxBuffer.length >= 27) {
      final bytes = Uint8List.fromList(_rxBuffer.sublist(0, 27));

      // Validate CRC before accepting packet
      if (!CrcUtils.validatePacketCrc(bytes)) {
        _crcErrors++;
        debugPrint('[StreamParser] CRC error in single packet, skipping');
        _rxBuffer.removeAt(0); // Skip first byte and try realigning
        return []; // Return empty list to continue processing
      }

      _rxBuffer.removeRange(0, 27);

      try {
        final packet = CollarPacket.fromBytes(bytes, throwOnCrcError: false);
        return [packet];
      } catch (e) {
        debugPrint('[StreamParser] Error parsing single packet: $e');
        return [];
      }
    }

    // Not enough data yet
    return null;
  }

  /// Try to parse array frame (batched packets)
  ///
  /// Array frames have two possible formats:
  /// 1. [ptype, count, elem1(27), elem2(27), ...] - each element has ptype
  /// 2. [ptype, count, elem1(26), elem2(26), ...] - ptype stripped from elements
  List<CollarPacket>? _tryParseArrayFrame(int ptype) {
    if (_rxBuffer.length < 2) return null;

    final count = _rxBuffer[1];

    // Array frames only have 2 or 4 packets
    if (count != 2 && count != 4) return null;

    // Try Format 1: count * 27 bytes (each element includes ptype)
    final format1Len = 2 + count * 27;
    if (_rxBuffer.length >= format1Len) {
      if (_tryParseArrayFormat1(ptype, count, format1Len)) {
        final packets = _extractArrayPacketsFormat1(ptype, count);
        if (packets != null) {
          _rxBuffer.removeRange(0, format1Len);
          return packets;
        }
      }
    }

    // Try Format 2: count * 26 bytes (ptype stripped from elements)
    final format2Len = 2 + count * 26;
    if (_rxBuffer.length >= format2Len) {
      if (_tryParseArrayFormat2(ptype, count, format2Len)) {
        final packets = _extractArrayPacketsFormat2(ptype, count);
        if (packets != null) {
          _rxBuffer.removeRange(0, format2Len);
          return packets;
        }
      }
    }

    return null;
  }

  /// Validate array frame format 1 (27-byte elements)
  bool _tryParseArrayFormat1(int ptype, int count, int totalLen) {
    final body = _rxBuffer.sublist(2, totalLen);

    for (int i = 0; i < count; i++) {
      final offset = i * 27;
      final elem = body.sublist(offset, offset + 27);

      // Each element must start with correct ptype
      if (elem[0] != ptype) return false;

      // CRC must be valid
      if (!CrcUtils.validatePacketCrc(elem)) return false;
    }

    return true;
  }

  /// Extract packets from array frame format 1
  List<CollarPacket>? _extractArrayPacketsFormat1(int ptype, int count) {
    final packets = <CollarPacket>[];
    final body = _rxBuffer.sublist(2, 2 + count * 27);

    try {
      for (int i = 0; i < count; i++) {
        final offset = i * 27;
        final elem = Uint8List.fromList(body.sublist(offset, offset + 27));
        final packet = CollarPacket.fromBytes(elem, throwOnCrcError: false);
        packets.add(packet);
      }

      debugPrint(
        '[StreamParser] ✅ Parsed array frame (format 1): $count packets',
      );
      return packets;
    } catch (e) {
      debugPrint('[StreamParser] Error extracting array format 1: $e');
      return null;
    }
  }

  /// Validate array frame format 2 (26-byte elements, ptype stripped)
  bool _tryParseArrayFormat2(int ptype, int count, int totalLen) {
    final body = _rxBuffer.sublist(2, totalLen);

    for (int i = 0; i < count; i++) {
      final offset = i * 26;
      final elem26 = body.sublist(offset, offset + 26);

      // Reconstruct 27-byte packet by prepending ptype
      final elem27 = <int>[ptype, ...elem26];

      // CRC must be valid
      if (!CrcUtils.validatePacketCrc(elem27)) return false;
    }

    return true;
  }

  /// Extract packets from array frame format 2
  List<CollarPacket>? _extractArrayPacketsFormat2(int ptype, int count) {
    final packets = <CollarPacket>[];
    final body = _rxBuffer.sublist(2, 2 + count * 26);

    try {
      for (int i = 0; i < count; i++) {
        final offset = i * 26;
        final elem26 = body.sublist(offset, offset + 26);

        // Reconstruct 27-byte packet
        final elem27 = Uint8List.fromList([ptype, ...elem26]);
        final packet = CollarPacket.fromBytes(elem27, throwOnCrcError: false);
        packets.add(packet);
      }

      debugPrint(
        '[StreamParser] ✅ Parsed array frame (format 2): $count packets',
      );
      return packets;
    } catch (e) {
      debugPrint('[StreamParser] Error extracting array format 2: $e');
      return null;
    }
  }

  /// Check if packet type is a response (not a data packet)
  bool _isResponseType(int ptype) {
    return ptype == 0x11 || // MODE_SWITCH
        ptype == 0xAA || // ACK
        ptype == 0x55 || // NAK
        ptype == 0xA0 || // DEVICE_INFO
        ptype == 0xB1; // BATTERY (could also be data packet, check length)
  }

  /// Get expected length of response packet
  int _getExpectedResponseLength(int ptype) {
    switch (ptype) {
      case 0x11:
        return 4; // MODE_SWITCH
      case 0xAA:
        return 1; // ACK
      case 0x55:
        return 1; // NAK
      case 0xA0:
        return 22; // DEVICE_INFO
      case 0xB1:
        return 12; // Battery response (matches Python PACKET_TYPE_BATTERY)
      default:
        return 0;
    }
  }
}

/// Result of parsing operation
class ParseResult {
  final List<CollarPacket> packets;
  final List<CollarResponse> responses;

  ParseResult({required this.packets, required this.responses});

  bool get hasPackets => packets.isNotEmpty;
  bool get hasResponses => responses.isNotEmpty;
  bool get isEmpty => packets.isEmpty && responses.isEmpty;
}
