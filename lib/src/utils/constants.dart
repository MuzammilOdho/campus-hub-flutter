// Application-wide constants and configuration

class AppConstants {
  // App metadata
  static const String appName = 'Campus Hub';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'A resource-sharing platform for Mehran University (MUET) students';

  // API configuration
  static const String defaultApiBaseUrl = 'http://10.0.2.2:8080';

  // Resource categories (matching backend enums)
  static const List<String> resourceCategories = [
    'Books',
    'Lab Equipment',
    'Electronics',
    'Stationery',
    'Miscellaneous',
  ];

  // Backend enum mappings for categories
  static const Map<String, String> categoryBackendMap = {
    'Books': 'BOOKS',
    'Lab Equipment': 'LAB_EQUIPMENT',
    'Electronics': 'ELECTRONICS',
    'Stationery': 'STATIONERY',
    'Miscellaneous': 'MISCELLANEOUS',
  };

  // Resource types
  static const List<String> resourceTypes = [
    'Share',
    'Donate',
  ];

  // Backend enum mappings for types
  static const Map<String, String> typeBackendMap = {
    'Share': 'LEND',
    'Donate': 'DONATE',
  };

  // Status values
  static const String statusAvailable = 'AVAILABLE';
  static const String statusUnavailable = 'UNAVAILABLE';
  static const String statusInUse = 'IN_USE';
  static const String statusReserved = 'RESERVED';

  // Request status
  static const String requestPending = 'PENDING';
  static const String requestAccepted = 'ACCEPTED';
  static const String requestApproved = 'APPROVED';
  static const String requestDeclined = 'DECLINED';
  static const String requestRejected = 'REJECTED';

  // Transaction status
  static const String transactionActive = 'ACTIVE';
  static const String transactionInProgress = 'IN_PROGRESS';
  static const String transactionOngoing = 'ONGOING';
  static const String transactionReturning = 'RETURNING';
  static const String transactionAwaitingReturn = 'AWAITING_RETURN';
  static const String transactionPendingReturn = 'PENDING_RETURN';
  static const String transactionCompleted = 'COMPLETED';
  static const String transactionCancelled = 'CANCELLED';

  // Date/Time formats
  static const String dateFormat = 'dd-MM-yyyy';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'dd-MM-yyyy HH:mm';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image constraints
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 85;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 5);

  // Polling intervals
  static const Duration requestPollInterval = Duration(seconds: 20);

  // Default durations
  static const int defaultBorrowDays = 7;
  static const int maxBorrowDays = 365;

  // UI constants
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Error messages
  static const String networkErrorMessage =
      'Network error. Please check your internet connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String authErrorMessage =
      'Authentication failed. Please login again.';
  static const String permissionErrorMessage =
      'You are not authorized to perform this action.';
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';

  // Success messages
  static const String resourceUploadedMessage = 'Resource uploaded successfully';
  static const String requestSentMessage = 'Request sent successfully';
  static const String requestApprovedMessage = 'Request approved';
  static const String requestDeclinedMessage = 'Request declined';
  static const String returnMarkedMessage = 'Marked as returned';
  static const String returnConfirmedMessage = 'Return confirmed';
  static const String resourceDeletedMessage = 'Resource deleted';

  // Validation
  static const int minNameLength = 3;
  static const int maxNameLength = 100;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 1000;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;

  // Cache durations
  static const Duration cacheShort = Duration(minutes: 5);
  static const Duration cacheMedium = Duration(minutes: 15);
  static const Duration cacheLong = Duration(hours: 1);
}

