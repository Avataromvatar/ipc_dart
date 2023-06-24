// part of ipc_pipe;
part of ipc;

// int openNamedPipe(char *path,int flags);
//     int closePipe(int fd);
//     int unlinkPipe(char *path);
//     int setNonBlock(int fd);
//     // void readyToRead(int fd,void (*callback)(int id,int len));
//     int writeToPipe(int fd,char *srcBuffer,int len);
// int readFromPipe(int fd, char *targetBuffer, unsigned int maxLen);
//     int waitData(int fd,unsigned int waitSec,unsigned int waituSec);

typedef _libopenNamedPipe = ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Int);
typedef _libclosePipe = ffi.Int Function(ffi.Int);
typedef _libunlinkPipe = ffi.Int Function(ffi.Pointer<ffi.Char>);
typedef _libsetNonBlock = ffi.Int Function(ffi.Int);
typedef _libwriteToPipe = ffi.Int Function(
    ffi.Int, ffi.Pointer<ffi.Uint8>, ffi.Int);
typedef _libreadFromPipe = ffi.Int Function(
    ffi.Int, ffi.Pointer<ffi.Uint8>, ffi.Int);
typedef _libwaitData = ffi.Int Function(
  ffi.Int,
  ffi.Uint32,
  ffi.Uint32,
);

typedef __openNamedPipe = int Function(ffi.Pointer<ffi.Char>, int);
typedef __closePipe = int Function(int);
typedef __unlinkPipe = int Function(ffi.Pointer<ffi.Char>);
typedef __setNonBlock = int Function(int);
typedef __writeToPipe = int Function(int, ffi.Pointer<ffi.Uint8>, int);
typedef __readFromPipe = int Function(int, ffi.Pointer<ffi.Uint8>, int);
typedef __waitData = int Function(int, int, int);

// char *path,int flags
class _PipeNamed implements IPCPipe {
  static final libraryPath = '/lib/libpipe.a';
  static late final ffi.DynamicLibrary dylib;
  static late final __openNamedPipe _openNamedPipe;
  static late final __closePipe _closePipe;
  static late final __unlinkPipe _unlinkPipe;
  static late final __setNonBlock _setNonBlock;
  static late final __writeToPipe _writeToPipe;
  static late final __readFromPipe _readFromPipe;
  static late final __waitData _waitData;

  bool _isStream = false;
  bool _isRun = false;
  bool _isRead = false;
  bool _isWrite = false;
  int? _fd;
  String? _path;
  int _maxSize = 65536;

  StreamController<Uint8List>? _controller;

  _PipeNamed() {
    dylib = ffi.DynamicLibrary.open(libraryPath);
    _openNamedPipe = dylib
        .lookup<ffi.NativeFunction<_libopenNamedPipe>>('openNamedPipe')
        .asFunction();
    _closePipe = dylib
        .lookup<ffi.NativeFunction<_libclosePipe>>('closePipe')
        .asFunction();
    _unlinkPipe = dylib
        .lookup<ffi.NativeFunction<_libunlinkPipe>>('unlinkPipe')
        .asFunction();
    _setNonBlock = dylib
        .lookup<ffi.NativeFunction<_libsetNonBlock>>('setNonBlock')
        .asFunction();
    _writeToPipe = dylib
        .lookup<ffi.NativeFunction<_libwriteToPipe>>('writeToPipe')
        .asFunction();
    _readFromPipe = dylib
        .lookup<ffi.NativeFunction<_libreadFromPipe>>('readFromPipe')
        .asFunction();
    _waitData =
        dylib.lookup<ffi.NativeFunction<_libwaitData>>('waitData').asFunction();
  }

  @override
  // TODO: implement maxBuffer
  int get maxBuffer => _maxSize;

  @override
  // TODO: implement name
  String? get name => throw UnimplementedError();

  @override
  // TODO: implement openFlags
  int get openFlags => throw UnimplementedError();
  @override
  Future<int> closedPipe({bool andDelete = false}) async {
    if (_fd != null) {
      var tmp = _fd;
      _fd = null;
      var ret = _closePipe(tmp!);

      if (ret != 0) {
        _fd = tmp;
        return ret;
        // throw IPCException('Close pipe $tmp error: $ret');
      }
      if (andDelete) {
        await File(_path!).delete();
        return 0;
      }
      return 0;
    }
    return -1;
  }

  @override
  Future<int> openPipe(int flags,
      {String? path, int maxPipeBuffer = 65536}) async {
    if (path == null) {
      throw IPCException('Error openPipe: Named Pipe must have a path');
    }
    // ffi.Pointer<ffi.Char> p = ffi.calloc //ffi.Pointer<ffi.Char>
    var ret = _openNamedPipe(path.toNativeUtf8().cast<ffi.Char>(), flags);
    if (ret < 0) {
      throw IPCException('OpenPipe $path error: ${ret * -1}');
    }
    if (flags & OpenFlags.forRead == OpenFlags.forRead) {
      _isRead = true;
    } else if (flags & OpenFlags.forWrite == OpenFlags.forWrite) {
      _isWrite = true;
    } else {
      //if we opean just for create
      _closePipe(ret);
      return 0;
    }
    _fd = ret;
    return 0;
  }

  // @override
  // Future<Uint8List?> read() {
  //   if (_fd != null && !_isStream && _isRead) {

  //     var p = calloc.call<ffi.Uint8>(_maxSize);
  //     calloc.call()
  //     p.asTypedList(10).t
  //     // ffi.Pointer<ffi.Uint8>
  //     _readFromPipe(_fd!, p, _maxSize);
  //   }
  // }

  @override
  Future<Stream<Uint8List>?> readStream() async {
    if (_isRead && _fd != null) {
      if (!_isRun) {
        _isRun = true;
        var p = calloc.call<ffi.Uint8>(_maxSize);
        int ret = 0;
        IPCException? error;
        _controller = StreamController<Uint8List>.broadcast();
        Future.doWhile(() async {
          ret = _readFromPipe(_fd!, p, _maxSize);
          if (ret == 0) {
            // no data
          } else if (ret > 0) {
            //get data
            _controller!.add(Uint8List.fromList(p.asTypedList(ret)));
          } else {
            //error
            // error = IPCException('Error readStream: $ret');
            log('Error readStream: $ret');
            _isRun = false;
          }
          if (!_isRun) {
            calloc.free(p);
            _controller?.close();
            // if (error != null) throw error!;
          }
          return _isRun;
        });
      }
      return _controller!.stream;
    }
    return null;
  }

  // @override
  // Future<void> write(Uint8List bytes) {
  //   // TODO: implement write
  //   throw UnimplementedError();
  // }

  @override
  Future<Sink<Uint8List>?> writeStream() async {
    if (_isWrite && _fd != null) {
      if (!_isRun) {
        _isRun = true;

        int ret = 0;
        IPCException? error;
        _controller = StreamController<Uint8List>.broadcast();
        _controller!.stream.listen((event) {
          if (_fd != null) {
            var p = calloc.call<ffi.Uint8>(event.length);
            p.asTypedList(_maxSize).setAll(0, event);
            int i = event.length;

            while (i > 0) {
              ret = _writeToPipe(_fd!, p, event.length);
              if (ret < 0) {
                //error

                _isRun = false;
                i = -1;
                log('Error writeStream $_fd $ret');
              } else {
                i -= ret;
              }
            }

            calloc.free(p);

            if (!_isRun) {
              _controller!.close();
            }
          }
        });

        return _controller!.sink;
      }
    }
    return null;
  }
}
