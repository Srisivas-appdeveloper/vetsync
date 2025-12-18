// lib/utils/crc_utils.dart

/// CRC-16-CCITT utilities for packet validation
/// Polynomial: 0x1021, Initial: 0xFFFF
///
/// Matches firmware implementation exactly.
class CrcUtils {
  /// Calculate CRC-16-CCITT checksum
  ///
  /// Algorithm:
  /// - Polynomial: 0x1021
  /// - Initial value: 0xFFFF
  /// - No final XOR
  ///
  /// Example:
  /// ```dart
  /// final data = [0xF1, 0x10, 0x27, 0x00, 0x00, ...];
  /// final crc = CrcUtils.crc16Ccitt(data);
  /// print('CRC: 0x${crc.toRadixString(16).padLeft(4, '0')}');
  /// ```
  static int crc16Ccitt(List<int> data) {
    int crc = 0xFFFF;

    for (final byte in data) {
      crc ^= (byte << 8);

      for (int j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }

    return crc;
  }

  /// Validate packet CRC
  ///
  /// Checks if the CRC at the end of the packet matches
  /// the calculated CRC of the packet data.
  ///
  /// Packet structure:
  /// - Bytes 0-24: Data
  /// - Bytes 25-26: CRC (little-endian uint16)
  ///
  /// Returns:
  /// - `true` if CRC is valid
  /// - `false` if CRC mismatch
  ///
  /// Throws:
  /// - `ArgumentError` if packet is too short
  static bool validatePacketCrc(
    List<int> packet, {
    int crcOffset = 25,
    bool throwOnError = false,
  }) {
    if (packet.length < crcOffset + 2) {
      throw ArgumentError(
        'Packet too short: ${packet.length} bytes (need at least ${crcOffset + 2})',
      );
    }

    // Extract CRC from packet (little-endian)
    final packetCrc = packet[crcOffset] | (packet[crcOffset + 1] << 8);

    // Calculate CRC over data portion
    final calculatedCrc = crc16Ccitt(packet.sublist(0, crcOffset));

    // Compare
    final isValid = packetCrc == calculatedCrc;

    if (!isValid && throwOnError) {
      throw CrcMismatchException(
        expected: calculatedCrc,
        actual: packetCrc,
        packet: packet,
      );
    }

    return isValid;
  }

  /// Verify and extract packet data if CRC is valid
  ///
  /// Returns:
  /// - Data portion of packet if CRC valid
  /// - `null` if CRC invalid
  static List<int>? verifyAndExtract(List<int> packet, {int crcOffset = 25}) {
    if (!validatePacketCrc(packet, crcOffset: crcOffset)) {
      return null;
    }
    return packet.sublist(0, crcOffset);
  }

  /// Generate lookup table for fast CRC calculation (optional optimization)
  ///
  /// Pre-compute CRC values for all possible byte values.
  /// Use this if you need maximum performance.
  static List<int> generateLookupTable() {
    final table = List<int>.filled(256, 0);

    for (int i = 0; i < 256; i++) {
      int crc = i << 8;
      for (int j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
      table[i] = crc;
    }

    return table;
  }

  /// Fast CRC calculation using lookup table
  ///
  /// About 3-4x faster than bit-by-bit calculation.
  /// Call `generateLookupTable()` once and reuse the table.
  static int crc16CcittFast(List<int> data, List<int> lookupTable) {
    int crc = 0xFFFF;

    for (final byte in data) {
      final index = ((crc >> 8) ^ byte) & 0xFF;
      crc = ((crc << 8) ^ lookupTable[index]) & 0xFFFF;
    }

    return crc;
  }
}

/// Exception thrown when CRC validation fails
class CrcMismatchException implements Exception {
  final int expected;
  final int actual;
  final List<int> packet;

  CrcMismatchException({
    required this.expected,
    required this.actual,
    required this.packet,
  });

  @override
  String toString() {
    return 'CRC mismatch: expected 0x${expected.toRadixString(16).padLeft(4, '0')}, '
        'got 0x${actual.toRadixString(16).padLeft(4, '0')} '
        '(packet: ${packet.take(10).map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}...)';
  }
}

/// Extension methods for CRC validation
extension CrcValidation on List<int> {
  /// Check if this packet has valid CRC
  bool get hasValidCrc => CrcUtils.validatePacketCrc(this);

  /// Get CRC value from packet
  int get crcValue {
    if (length < 27) return 0;
    return this[25] | (this[26] << 8);
  }

  /// Calculate what the CRC should be
  int get expectedCrc => CrcUtils.crc16Ccitt(sublist(0, 25));
}

/// Test vectors for CRC validation (use in unit tests)
class CrcTestVectors {
  /// Test vector 1: Empty data
  static const empty = <int>[];
  static const emptyCrc = 0xFFFF;

  /// Test vector 2: Single byte
  static const singleByte = [0x00];
  static const singleByteCrc = 0x1021;

  /// Test vector 3: "123456789"
  static const ascii123456789 = [
    0x31,
    0x32,
    0x33,
    0x34,
    0x35,
    0x36,
    0x37,
    0x38,
    0x39,
  ];
  static const ascii123456789Crc = 0x29B1;

  /// Test vector 4: Standard packet header (0xF1, timestamp=10000ms)
  static const standardHeader = [
    0xF1, // packet_type
    0x10, 0x27, 0x00, 0x00, // timestamp_ms = 10000
  ];
  // CRC computed over these 5 bytes: 0x????

  /// Verify all test vectors
  static bool verifyAll() {
    final tests = [
      (empty, emptyCrc, 'Empty data'),
      (singleByte, singleByteCrc, 'Single byte'),
      (ascii123456789, ascii123456789Crc, 'ASCII "123456789"'),
    ];

    for (final test in tests) {
      final calculated = CrcUtils.crc16Ccitt(test.$1);
      if (calculated != test.$2) {
        print('❌ FAIL: ${test.$3}');
        print('   Expected: 0x${test.$2.toRadixString(16).padLeft(4, '0')}');
        print('   Got:      0x${calculated.toRadixString(16).padLeft(4, '0')}');
        return false;
      }
      print('✅ PASS: ${test.$3}');
    }

    return true;
  }
}
