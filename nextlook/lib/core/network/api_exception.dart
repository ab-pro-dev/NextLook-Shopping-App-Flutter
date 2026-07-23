import 'package:dio/dio.dart';

/// Exception thrown for API errors, encapsulating status code and user-friendly error message.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioException(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    if (error is DioException) {
      final int? statusCode = error.response?.statusCode;
      String message = 'An unexpected error occurred. Please try again.';

      if (error.response?.data != null) {
        final responseData = error.response!.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('message') && responseData['message'] != null) {
            message = responseData['message'].toString();
          } else if (responseData.containsKey('error') && responseData['error'] != null) {
            message = responseData['error'].toString();
          }
        } else if (responseData is String && responseData.isNotEmpty) {
          message = responseData;
        }
      } else {
        switch (error.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            message = 'Connection timed out. Please check your network connection.';
            break;
          case DioExceptionType.connectionError:
            message = 'Unable to connect to server. Please ensure the server is running.';
            break;
          case DioExceptionType.cancel:
            message = 'Request was cancelled.';
            break;
          default:
            if (statusCode != null) {
              message = 'Server returned error ($statusCode).';
            }
            break;
        }
      }

      return ApiException(
        message: message,
        statusCode: statusCode,
        data: error.response?.data,
      );
    }

    return ApiException(
      message: error.toString(),
    );
  }

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
