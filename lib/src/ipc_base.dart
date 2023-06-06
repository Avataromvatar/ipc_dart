import 'dart:typed_data';

export 'package:ipc/src/channel/channel_helper.dart';

abstract class IPCObjectFactory<T> {
  int? get objectLen;

  ///if set objectLen this method will be call then ipc get len>objectLen
  List<T> Function(Uint8List raw)? get listFromRaw;

  ///requer for read
  T Function(Uint8List raw)? get fromRaw;

  ///requer for write
  Uint8List Function(T obj)? get toRaw;
}

// abstract class IPCChannel {
//   Future<Stream<T>> opentToReadObjects<T>(
//       String path, IPCObjectFactory<T> factory);
//   Future<Sink<T>> openToWriteObjects<T>(
//       String path, IPCObjectFactory<T> factory);
//   static Future<bool> createIPCChannel(String absolutePath) =>
//       IPCChannelHelper.createIPCChannel(absolutePath);
//   static Future<bool> deleteIPCChannel(String absolutePath) =>
//       IPCChannelHelper.deleteIPCChannel(absolutePath);

// }

class IPCException implements Exception {
  dynamic message;
  IPCException([dynamic message]);

  @override
  String toString() {
    if (message == null) {
      return 'IPCException';
    } else {
      return 'IPCException: $message';
    }
  }
}
