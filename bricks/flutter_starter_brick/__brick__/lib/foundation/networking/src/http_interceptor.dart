import 'package:dio/dio.dart' as dio;

/// The owned base every step of a client's chain extends.
///
/// It sits on the transport package's own interceptor type, which is why it
/// lives here: `foundation/networking` is the one folder that package may be
/// imported in, and this base keeps the package's name out of every signature
/// the rest of the app reads. Nothing outside this folder implements it.
abstract class HttpInterceptor extends dio.Interceptor {
  /// Creates a chain step.
  const HttpInterceptor();
}
