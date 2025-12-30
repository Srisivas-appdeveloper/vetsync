import 'dart:typed_data';

class RawDataChunk {
  final Map<String, String> uploadHeaders;

  RawDataChunk({required this.uploadHeaders});

  Uint8List toMessagePack() => Uint8List(0); // Stub
}
