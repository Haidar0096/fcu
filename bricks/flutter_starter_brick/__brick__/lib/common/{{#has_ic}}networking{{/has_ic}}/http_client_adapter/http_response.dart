class HttpResponse<T> {
  final int? statusCode;

  final Map<String, dynamic>? headers;

  final T? data;

  const HttpResponse({
    required this.statusCode,
    required this.headers,
    required this.data,
  });
}
