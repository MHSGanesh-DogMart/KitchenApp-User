class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic raw;

  const ApiException(this.message, {this.statusCode, this.raw});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NoInternetException extends ApiException {
  const NoInternetException() : super('No internet connection');
}

class TimeoutApiException extends ApiException {
  const TimeoutApiException()
      : super('Connection timed out. Please try again.');
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Session expired'])
      : super(statusCode: 401);
}

class BadRequestException extends ApiException {
  const BadRequestException(super.message, {super.raw})
      : super(statusCode: 400);
}

class ServerException extends ApiException {
  const ServerException([super.message = 'Server error'])
      : super(statusCode: 500);
}

class CancelledException extends ApiException {
  const CancelledException() : super('Request cancelled');
}

class UnknownApiException extends ApiException {
  const UnknownApiException([super.message = 'Something went wrong']);
}
