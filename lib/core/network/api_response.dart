
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? parse,
    int? statusCode,
  }) {
    final status = json['status'] ?? json['Status'];
    final success = status == 1 || status == '1' || status == true;
    return ApiResponse<T>(
      success: success,
      message: (json['message'] ?? json['msg'] ?? '').toString(),
      data: parse != null && json['data'] != null ? parse(json['data']) : null,
      statusCode: statusCode,
    );
  }
}
