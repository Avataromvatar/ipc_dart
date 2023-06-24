/// Support for doing something awesome.
///
/// More dartdocs go here.
library ipc;

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:ipc/interface/error_exception.dart';
// import 'package:ipc/interface/pipe.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

export 'helpers/channel_helper.dart';
export 'interface/error_exception.dart';
// export 'interface/pipe.dart';

part 'interface/pipe.dart';
part 'pipe/pipe_named.dart';




// TODO: Export any libraries intended for clients of this package.
