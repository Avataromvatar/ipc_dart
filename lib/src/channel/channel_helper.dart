import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:ipc/src/ipc_base.dart';

class IPCChannelHelper {
  static Future<bool> createIPCChannel(String absolutePath) async {
    try {
      if (Platform.isLinux) {
        await Process.run('mkfifo', [absolutePath]);
        File f = File(absolutePath);
        if (await f.exists()) {
          return true;
        }
        return false;
      }
    } catch (e) {
      throw IPCException(e);
    }
    return false;
  }

  static Future<bool> deleteIPCChannel(String absolutePath) async {
    try {
      if (Platform.isLinux) {
        File f = File(absolutePath);
        if (await f.exists()) {
          await f.delete();
          return true;
        }
        IPCException('No fifo in $absolutePath');
        return false;
      }
    } catch (e) {
      throw IPCException(e);
    }
    return false;
  }

  static Future<Stream<T>> opentToReadObjects<T>(
      String path, IPCObjectFactory<T> factory) async {
    assert(factory.fromRaw != null);
    var f = File(path);
    if (await f.exists()) {
      final StreamController<T> localStreamController = StreamController();
      bool isRun = true;
      Uint8List? data;
      localStreamController.onCancel = () {
        isRun = false;
      };
      Future.doWhile(() async {
        //---Worker
        try {
          //wait data
          data = await f.readAsBytes();
          if (factory.objectLen != null && factory.listFromRaw != null) {
            if (data!.lengthInBytes > factory.objectLen!) {
              var d = factory.listFromRaw!(data!);
              for (var element in d) {
                localStreamController.add(element);
              }
              return isRun;
            }
          }
          localStreamController.add(factory.fromRaw!(data!));
        } catch (e) {
          isRun = false;
          throw IPCException(e);
        }
        return isRun;
      }).then((value) async {
        await localStreamController.close();
      });
      return localStreamController.stream;
    } else {
      throw IPCException('Fifo $path is not exists');
    }
  }

  static Future<Sink<T>> openToWriteObjects<T>(
      String path, IPCObjectFactory<T> factory) async {
    assert(factory.toRaw != null);
    var f = File(path);
    if (await f.exists()) {
      final StreamController<T> localStreamController = StreamController();
      StreamSubscription<T>? subcribe;
      subcribe = localStreamController.stream.listen((event) async {
        try {
          f = await f.writeAsBytes(factory.toRaw!(event));
        } catch (e) {
          await subcribe?.cancel();
          throw IPCException(e);
        }
      });
      localStreamController.onCancel = () async {
        await subcribe?.cancel();
      };
      return localStreamController;
    } else {
      throw IPCException('Fifo $path is not exists');
    }
  }
}
