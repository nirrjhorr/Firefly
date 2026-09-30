/// A sealed Result class for domain-level error handling without throwing exceptions.
sealed class Result<T, E> {
  const Result();
}

/// Represents a successful computation.
final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

/// Represents a failed computation.
final class Err<T, E> extends Result<T, E> {
  const Err(this.error);
  final E error;
}

/// Base class for all domain-specific failures.
abstract class Failure {
  final String message;
  const Failure(this.message);
}
