/// A sealed Result class for domain-level error handling without throwing exceptions.
sealed class Result<T, E> {
  const Result();

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  T unwrap() {
    if (this is Ok<T, E>) {
      return (this as Ok<T, E>).value;
    }
    throw StateError('Called unwrap on Err: ${(this as Err<T, E>).error}');
  }

  T unwrapOr(T defaultValue) {
    if (this is Ok<T, E>) {
      return (this as Ok<T, E>).value;
    }
    return defaultValue;
  }

  E unwrapErr() {
    if (this is Err<T, E>) {
      return (this as Err<T, E>).error;
    }
    throw StateError('Called unwrapErr on Ok: ${(this as Ok<T, E>).value}');
  }
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
