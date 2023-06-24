// import 'package:ipc_test/ipc_test.dart' as ipc_test;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ipc/ipc.dart';

const path = 'test_pipe';
Uint8List? data;
DateTime? inPack;
DateTime? inPackLast;
DateTime? outPack;
DateTime? start;
DateTime? end;
// IPCPipe ipcIN = IPCPipe();
// IPCPipe ipcOUT = IPCPipe();
Sink<Uint8List>? sink;
const startCount = 10000;
int count = 0;
int size = 1024; //65536 * 2;
int allData = 0;

// bool isRun = false;
Future<void> main(List<String> arguments) async {
  print('Hello world IPC!');
  var dirPath = Directory.current.path;
  var fullPath = '$dirPath/$path';
  IPCChannelHelper.createIPCChannel(fullPath);

  var sIn = await IPCChannelHelper.opentToRead(fullPath);
  if (sIn != null) {
    sIn.listen((event) {
      allData += event.length;
      inPack = DateTime.now();
      // print(
      //     'IN ${event.length} ${(inPack?.microsecondsSinceEpoch ?? 0) - (outPack?.microsecondsSinceEpoch ?? 0)}');

      next();
    });
  }
  sink = await IPCChannelHelper.openToWrite(fullPath);
  if (sink == null) {
    _error(err: 'open sink');
  }
  data = Uint8List(size);
  var rand = Random();
  for (var i = 0; i < data!.length; i++) {
    data![i] = rand.nextInt(100);
  }
  start = DateTime.now();
  next();
  await Future.delayed(Duration(seconds: 20));
  end = DateTime.now();
  print(
      'Done after Future $count count, $allData byte, ${(end!.microsecondsSinceEpoch - start!.microsecondsSinceEpoch) / 1000000}');
}

void next() {
  if (count < startCount) {
    count++;
    outPack = DateTime.now();
    sink!.add(data!);
  } else {
    end = DateTime.now();
    print(
        'Done $count count, $allData / ${count * size} byte, ${(end!.microsecondsSinceEpoch - start!.microsecondsSinceEpoch) / 1000000}');
    exit(0);
  }
}

void _error({String? err}) {
  print(err ?? "Error");
  exit(0);
}
