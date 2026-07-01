class ApiException implements Exception {
  final String message;
  final String prefix;

  ApiException(this.message, this.prefix);

  @override
  String toString() {
    return "$message, $prefix";
  }
}

class FetchDataException extends ApiException {
  FetchDataException(String? message)
      : super(message!, "Error during data fetching");
  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException(String? message) : super(message!, "Bad request error!");
  @override
  String toString() => message;
}

class UnauthorizedRequestException extends ApiException {
  UnauthorizedRequestException(String? message)
      : super(message!, "Unauthorized request Exception");
  @override
  String toString() => message;
}

class TimeOutException extends ApiException {
  TimeOutException(String? message) : super(message!, "Time out Exception!");

  @override
  String toString() => message;
}

class NotFoundException extends ApiException {
  NotFoundException([String? message])
      : super(message!, "Resource Not Found: ");
}

class DuplicateAutoTaskException extends ApiException {
  DuplicateAutoTaskException([String? message])
      : super(message!, "Can't add duplicate task");
}
