import 'dart:io';

import '../api/api_service.dart';

/// Map various exceptions to user-friendly messages.
String userFriendlyError(Object error) {
  try {
    if (error is ApiException) {
      final code = error.statusCode;
      final msg = error.message;
      if (code == 401) return 'Authentication failed. Please login again.';
      if (code == 403) return 'You are not authorized to perform this action.';
      if (code >= 500) return 'Server error: $msg';
      if (msg.isNotEmpty) return msg;
      return 'Request failed (HTTP $code)';
    }
    if (error is SocketException) return 'Network error. Check your internet connection.';
    if (error is FormatException) return 'Unexpected response from server.';
    if (error is HttpException) return 'Network error: ${error.message}';
    return error.toString();
  } catch (_) {
    return error.toString();
  }
}

