/// Base class for SafeLife typed exceptions
class AppException implements Exception {
  final String message;
  final String? technicalDetails;

  const AppException(this.message, [this.technicalDetails]);

  @override
  String toString() =>
      technicalDetails == null ? message : '$message ($technicalDetails)';
}

/// Thrown when database or Firestore operations fail
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.technicalDetails]);
}

/// Thrown when location services are disabled, denied, or timed out
class LocationException extends AppException {
  const LocationException(super.message, [super.technicalDetails]);
}

/// Thrown when network connectivity fails during emergency dispatch
class NetworkException extends AppException {
  const NetworkException(super.message, [super.technicalDetails]);
}

/// Thrown when SMS fallback transmission fails
class SmsException extends AppException {
  const SmsException(super.message, [super.technicalDetails]);
}

/// Thrown when authentication or session validation fails
class AuthException extends AppException {
  const AuthException(super.message, [super.technicalDetails]);
}

/// Thrown when medical triage questionnaire validation fails
class TriageException extends AppException {
  const TriageException(super.message, [super.technicalDetails]);
}
