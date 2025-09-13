class ApiException implements Exception {
  final String _message;
  final String _prefix;

  ApiException(this._message, this._prefix);

  @override
  String toString() {
    return "$_message, $_prefix";
  }
}

class FetchDataException extends ApiException {
  FetchDataException(String? message)
      : super(message!, "Error during data fetching");
}

class BadRequestException extends ApiException {
  BadRequestException(String? message) : super(message!, "Bad request error!");
}

class UnauthorizedRequestException extends ApiException {
  UnauthorizedRequestException(String? message)
      : super(message!, "Unauthorized request Exception");
}

class TimeOutException extends ApiException {
  TimeOutException(String? message) : super(message!, "Time out Exception!");
}
