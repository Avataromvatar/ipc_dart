import 'dart:typed_data';

class OpenFlags {
  static int forWrite = 1;
  static int forRead = 2;
  static int forReadAndWrite = 3;
  static int nonBlock = 4;
  static int createIfNotExist = 8;
}

abstract class IPCNamedPipe {
  int get openFlags;
  int get maxBuffer;
  String? get name;
  Future<void> openPipe(int flags, {String? path, int maxPipeBuffer = 65536});
  Future<void> closedPipe({bool andDelete = false});
  Future<void> write(Uint8List bytes);
  Future<Uint8List?> read();
  Future<Sink<Uint8List>> writeStream();
  Future<Stream<Uint8List>> readStream();
}
