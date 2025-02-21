class HttpResponse<T> {
  const HttpResponse({
    required this.statusCode,
    required this.headers,
    required this.data,
  });
  final int? statusCode;

  final Map<String, dynamic>? headers;

  final T? data;
}
