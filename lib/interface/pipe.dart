// library ipc_pipe;
part of ipc;

// part '../pipe/pipe_named.dart';

class OpenFlags {
  static int forWrite = 1;
  static int forRead = 2;
  static int forReadAndWrite = 3;
  static int nonBlock = 4;
  static int createIfNotExist = 8;
}

///one exemplary Pipe(fifo) work just one direction
abstract class IPCPipe {
  ///Look OpenFlags for example flags = OpenFlags.forWrite|OpenFlags.forRead;
  int get openFlags;

  ///pipe have max size for one transaction to write
  /// TODO: check
  ///if you wtite >maxBuffer reader get you package splitting to part (if he wait)
  ///but if all data will be wrote reader get all data>maxBuffer
  int get maxBuffer;

  ///path for named pipe
  String? get name;

  ///one exemplary Pipe(fifo) work just one direction
  ///if you set flag read and write IPCPipe throw error
  Future<int> openPipe(int flags, {String? path, int maxPipeBuffer = 65536});
  Future<int> closedPipe({bool andDelete = false});

  ///
  // Future<void> write(Uint8List bytes);
  // Future<Uint8List?> read();
  Future<Sink<Uint8List>?> writeStream();
  Future<Stream<Uint8List>?> readStream();
  factory IPCPipe() {
    return _PipeNamed();
  }
}
