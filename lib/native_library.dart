import 'dart:ffi' as ffi;
import 'dart:io';

typedef NativeAdd = ffi.Int32 Function(ffi.Int32, ffi.Int32);
typedef DartAdd = int Function(int, int);

class NativeLibrary {
  final ffi.DynamicLibrary _lib;

  NativeLibrary._(this._lib);

  static NativeLibrary open() {
    final lib = Platform.isAndroid
        ? ffi.DynamicLibrary.open('native_functions.so')
        : ffi.DynamicLibrary.process();
    return NativeLibrary._(lib);
  }

  int add(int a, int b) {
    final addFunction = _lib
        .lookup<ffi.NativeFunction<NativeAdd>>('add')
        .asFunction<DartAdd>();
    return addFunction(a, b);
  }
}
