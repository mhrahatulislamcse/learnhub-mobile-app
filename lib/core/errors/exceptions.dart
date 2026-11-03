/// Custom Exceptions thrown at the data layer
class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException({required this.message, this.code});

  @override
  String toString() => 'ServerException(code: $code, message: $message)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException(message: $message)';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});

  @override
  String toString() => 'AuthException(code: $code, message: $message)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection detected'});

  @override
  String toString() => 'NetworkException(message: $message)';
}

