export 'socket_exception_stub.dart'
    if (dart.library.io) 'socket_exception_io.dart'
    if (dart.library.js_interop) 'socket_exception_web.dart';
