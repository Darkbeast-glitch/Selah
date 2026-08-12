/// The single exception type surfaced above the data layer.
///
/// Data sources catch platform-specific failures (FirebaseException, HTTP
/// errors, JSON parse failures) and rethrow them as an [AppException] so
/// ViewModels and views never need to know which backend produced the error.
///
/// [message] is safe to show to a user. [cause] is for logs only.
sealed class AppException implements Exception {
  const AppException({required this.message, this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message${cause == null ? '' : ' ($cause)'}';
}

/// No usable network connection. Callers should offer cached content where
/// possible (PRD §37).
class NetworkException extends AppException {
  const NetworkException({
    super.message = "You're offline. Check your connection and try again.",
    super.cause,
    super.stackTrace,
  });
}

/// Authentication failed or the session is missing.
class AuthException extends AppException {
  const AuthException({
    super.message = 'We could not verify your session. Please reopen Selah.',
    super.cause,
    super.stackTrace,
  });
}

/// Firestore or local persistence failed.
class DataException extends AppException {
  const DataException({
    super.message = 'Something went wrong saving your data.',
    super.cause,
    super.stackTrace,
  });
}

/// The requested document or Scripture reference does not exist.
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'We could not find that passage.',
    super.cause,
    super.stackTrace,
  });
}

/// The AI backend failed, timed out, or returned a response that did not match
/// the expected structured contract (PRD §26).
class AiException extends AppException {
  const AiException({
    super.message = 'Selah could not respond just now. Please try again.',
    super.cause,
    super.stackTrace,
  });
}

/// The AI backend rejected the request for rate limiting or abuse prevention
/// (PRD §23).
class RateLimitException extends AppException {
  const RateLimitException({
    super.message = 'You have sent a lot of messages. Take a pause and try again shortly.',
    super.cause,
    super.stackTrace,
  });
}

/// An unclassified failure.
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'Something unexpected happened.',
    super.cause,
    super.stackTrace,
  });
}
