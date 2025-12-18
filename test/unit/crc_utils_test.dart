import 'package:flutter_test/flutter_test.dart';
import 'package:vetsync/utils/crc_utils.dart';

void main() {
  group('CRC-16-CCITT Utils', () {
    test('Calculates CRC correctly for empty data', () {
      expect(CrcUtils.crc16Ccitt([]), 0xFFFF);
    });

    test('Calculates CRC correctly for single byte', () {
      expect(CrcUtils.crc16Ccitt([0x00]), 0xE1F0);
    });

    test('Calculates CRC correctly for test vector "123456789"', () {
      final input = '123456789'.codeUnits;
      expect(CrcUtils.crc16Ccitt(input), 0x29B1);
    });

    test('Validates packet with correct CRC', () {
      // Create a valid packet manually
      final data = [0xF1, 0x01, 0x02, 0x03];
      final crc = CrcUtils.crc16Ccitt(data);
      // Append CRC (little endian first byte, then second byte?)
      // CrcUtils.validatePacketCrc reads: packet[offset] | (packet[offset + 1] << 8)
      // So it expects Little Endian CRC in the packet.

      final packet = [...data, crc & 0xFF, (crc >> 8) & 0xFF];

      expect(CrcUtils.validatePacketCrc(packet, crcOffset: 4), isTrue);
    });

    test('Rejects packet with incorrect CRC', () {
      final data = [0xF1, 0x01, 0x02, 0x03];
      final packet = [...data, 0x00, 0x00]; // Invalid CRC

      expect(CrcUtils.validatePacketCrc(packet, crcOffset: 4), isFalse);
    });
  });
}
