/// A minimal functional Result type for Dart.
///
/// Inspired by Rust / Kotlin Result.
///
/// Represents either a [Success] or an [Error].
library;

sealed class Res<E, T> {
  const Res();

  // =========================
  // Constructors
  // =========================

  /// Creates a successful result.
  ///
  /// **Parameters**
  /// - [value]: The success value.
  ///
  /// **Returns**
  /// - `Success<T>` containing [value]
  ///
  /// **Example**
  /// ```dart
  /// final r = Res.success(10);
  /// ```
  const factory Res.success(T value) = Success<E, T>;

  /// Creates an error result.
  ///
  /// **Parameters**
  /// - [error]: The error value.
  ///
  /// **Returns**
  /// - `Error<E>` containing [error]
  ///
  /// **Example**
  /// ```dart
  /// final r = Res.error("fail");
  /// ```
  const factory Res.error(E error) = Error<E, T>;

  /// Creates a `Success<void>`.
  ///
  /// Useful when there is no meaningful return value.
  ///
  /// **Returns**
  /// - `Success(null)`
  ///
  /// **Example**
  /// ```dart
  /// final r = Res.unit();
  /// ```
  static Res<E, void> unit<E>() => Success<E, void>(null);

  // =========================
  // State
  // =========================

  /// Whether this is a success.
  ///
  /// **Returns**
  /// - `true` if [Success]
  /// - `false` otherwise
  bool get isSuccess => this is Success<E, T>;

  /// Whether this is an error.
  ///
  /// **Returns**
  /// - `true` if [Error]
  /// - `false` otherwise
  bool get isError => this is Error<E, T>;

  /// Returns the success value or `null`.
  ///
  /// **Returns**
  /// - Value if success
  /// - `null` if error
  T? get success =>
      this is Success<E, T> ? (this as Success<E, T>).value : null;

  /// Returns the error value or `null`.
  ///
  /// **Returns**
  /// - Error if error
  /// - `null` if success
  E? get error => this is Error<E, T> ? (this as Error<E, T>).error : null;

  // =========================
  // Core
  // =========================

  /// Pattern matching with named callbacks.
  ///
  /// **Parameters**
  /// - [success]: Called if result is success
  /// - [error]: Called if result is error
  ///
  /// **Returns**
  /// - A value of type [R]
  ///
  /// **Example**
  /// ```dart
  /// final result = Res.success(10).when(
  ///   success: (v) => v * 2,
  ///   error: (e) => 0,
  /// );
  /// ```
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) error,
  }) {
    if (this is Success<E, T>) {
      return success((this as Success<E, T>).value);
    }
    return error((this as Error<E, T>).error);
  }

  /// Handles both success and error cases.
  ///
  /// **Parameters**
  /// - [success]: Called if success
  /// - [error]: Called if error
  ///
  /// **Returns**
  /// - A value of type [R]
  ///
  /// **Example**
  /// ```dart
  /// final result = Res.error("fail").fold(
  ///   (v) => v,
  ///   (e) => 0,
  /// );
  /// ```
  R fold<R>(R Function(T value) success, R Function(E error) error) {
    if (this is Success<E, T>) {
      return success((this as Success<E, T>).value);
    }
    return error((this as Error<E, T>).error);
  }

  // =========================
  // Transform
  // =========================

  /// Transforms the success value.
  ///
  /// **Parameters**
  /// - [fn]: Function applied to the success value
  ///
  /// **Returns**
  /// - `Success<U>` if success
  /// - `Error<E>` unchanged if error
  ///
  /// **Example**
  /// ```dart
  /// Res.success(5).map((v) => v * 2);
  /// ```
  Res<E, U> map<U>(U Function(T value) fn) {
    if (this is Success<E, T>) {
      return Res.success(fn((this as Success<E, T>).value));
    }
    return Res.error((this as Error<E, T>).error);
  }

  /// Transforms the error value.
  ///
  /// **Parameters**
  /// - [fn]: Function applied to the error
  ///
  /// **Returns**
  /// - `Error<F>` if error
  /// - `Success<T>` unchanged if success
  Res<F, T> mapError<F>(F Function(E error) fn) {
    if (this is Error<E, T>) {
      return Res.error(fn((this as Error<E, T>).error));
    }
    return Res.success((this as Success<E, T>).value);
  }

  /// Chains another result-producing function.
  ///
  /// **Parameters**
  /// - [fn]: Function returning another [Res]
  ///
  /// **Returns**
  /// - Result of [fn] if success
  /// - Original error otherwise
  ///
  /// **Example**
  /// ```dart
  /// Res.success(5).andThen((v) => Res.success(v * 2));
  /// ```
  Res<E, R> andThen<R>(Res<E, R> Function(T value) fn) {
    if (this is Success<E, T>) {
      return fn((this as Success<E, T>).value);
    }
    return Res.error((this as Error<E, T>).error);
  }

  // =========================
  // Mapping helpers
  // =========================

  /// Maps success or returns fallback.
  ///
  /// **Parameters**
  /// - [fallback]: Value returned if error
  /// - [fn]: Function applied to success
  ///
  /// **Returns**
  /// - Result of [fn] or fallback
  R mapOr<R>(R fallback, R Function(T value) fn) {
    if (this is Success<E, T>) {
      return fn((this as Success<E, T>).value);
    }
    return fallback;
  }

  /// Maps success or computes fallback.
  ///
  /// **Parameters**
  /// - [fallback]: Function applied if error
  /// - [fn]: Function applied if success
  ///
  /// **Returns**
  /// - Result of either function
  R mapOrElse<R>(R Function(E error) fallback, R Function(T value) fn) {
    if (this is Success<E, T>) {
      return fn((this as Success<E, T>).value);
    }
    return fallback((this as Error<E, T>).error);
  }

  // =========================
  // Filters
  // =========================

  /// Filters success value by predicate.
  ///
  /// **Parameters**
  /// - [predicate]: Condition to validate value
  /// - [err]: Error if predicate fails
  ///
  /// **Returns**
  /// - Same success if valid
  /// - Error otherwise
  Res<E, T> filter(bool Function(T value) predicate, E err) {
    if (this is Success<E, T>) {
      final v = (this as Success<E, T>).value;
      if (predicate(v)) {
        return this;
      }
      return Res.error(err);
    }
    return this;
  }

  /// Checks if value satisfies predicate.
  ///
  /// **Parameters**
  /// - [predicate]: Condition to test the value
  ///
  /// **Returns**
  /// - `true` if success and predicate is satisfied
  /// - `false` otherwise
  ///
  /// **Example**
  /// ```dart
  /// Res.success(10).exists((v) => v > 5); // true
  /// ```
  bool exists(bool Function(T value) predicate) {
    if (this is Success<E, T>) {
      return predicate((this as Success<E, T>).value);
    }
    return false;
  }

  /// Checks if value equals [value].
  ///
  /// **Parameters**
  /// - [value]: Value to compare
  ///
  /// **Returns**
  /// - `true` if success and values are equal
  /// - `false` otherwise
  ///
  /// **Example**
  /// ```dart
  /// Res.success(10).contains(10); // true
  /// ```
  bool contains(T value) {
    if (this is Success<E, T>) {
      return (this as Success<E, T>).value == value;
    }
    return false;
  }

  /// Executes side-effect if success.
  ///
  /// **Parameters**
  /// - [fn]: Function executed with the success value
  ///
  /// **Returns**
  /// - The same [Res] instance
  ///
  /// **Example**
  /// ```dart
  /// Res.success(10).tap(print);
  /// ```
  Res<E, T> tap(void Function(T value) fn) {
    if (this is Success<E, T>) {
      fn((this as Success<E, T>).value);
    }
    return this;
  }

  /// Executes side-effect if error.
  ///
  /// **Parameters**
  /// - [fn]: Function executed with the error
  ///
  /// **Returns**
  /// - The same [Res] instance
  ///
  /// **Example**
  /// ```dart
  /// Res.error("fail").tapError(print);
  /// ```
  Res<E, T> tapError(void Function(E error) fn) {
    if (this is Error<E, T>) {
      fn((this as Error<E, T>).error);
    }
    return this;
  }

  /// Returns value or fallback.
  ///
  /// **Parameters**
  /// - [fallback]: Function to produce value if error
  ///
  /// **Returns**
  /// - Success value or computed fallback
  ///
  /// **Example**
  /// ```dart
  /// Res.error("fail").getOrElse((_) => 0);
  /// ```
  T getOrElse(T Function(E error) fallback) {
    if (this is Success<E, T>) {
      return (this as Success<E, T>).value;
    }
    return fallback((this as Error<E, T>).error);
  }

  /// Converts error into success.
  ///
  /// **Parameters**
  /// - [fn]: Function to recover from error
  ///
  /// **Returns**
  /// - Same success or recovered success
  ///
  /// **Example**
  /// ```dart
  /// Res.error("fail").recover((_) => 0);
  /// ```
  Res<E, T> recover(T Function(E error) fn) {
    if (this is Success<E, T>) {
      return this;
    }
    return Res.success(fn((this as Error<E, T>).error));
  }

  /// Async map.
  ///
  /// **Parameters**
  /// - [fn]: Async function applied to success
  ///
  /// **Returns**
  /// - Future of transformed result
  ///
  /// **Example**
  /// ```dart
  /// await Res.success(2).mapAsync((v) async => v * 2);
  /// ```
  Future<Res<E, R>> mapAsync<R>(Future<R> Function(T value) fn) async {
    if (this is Success<E, T>) {
      final v = await fn((this as Success<E, T>).value);
      return Res.success(v);
    }
    return Res.error((this as Error<E, T>).error);
  }

  /// Async flatMap.
  ///
  /// **Parameters**
  /// - [fn]: Async function returning [Res]
  ///
  /// **Returns**
  /// - Future of chained result
  ///
  /// **Example**
  /// ```dart
  /// await Res.success(2).flatMapAsync((v) async => Res.success(v * 2));
  /// ```
  Future<Res<E, R>> flatMapAsync<R>(
    Future<Res<E, R>> Function(T value) fn,
  ) async {
    if (this is Success<E, T>) {
      return fn((this as Success<E, T>).value);
    }
    return Res.error((this as Error<E, T>).error);
  }

  /// Converts to nullable.
  ///
  /// **Returns**
  /// - Value if success
  /// - `null` if error
  ///
  /// **Example**
  /// ```dart
  /// final v = Res.success(10).toNullable(); // 10
  /// ```
  T? toNullable() {
    if (this is Success<E, T>) {
      return (this as Success<E, T>).value;
    }
    return null;
  }

  /// Executes function safely.
  ///
  /// **Parameters**
  /// - [fn]: Function to execute
  /// - [mapper]: Maps exception to error
  ///
  /// **Returns**
  /// - `Success` if no exception
  /// - `Error` otherwise
  ///
  /// **Example**
  /// ```dart
  /// final r = Res.tryCatch(
  ///   () => int.parse("10"),
  ///   (e, _) => "parse error",
  /// );
  /// ```
  static Res<E, T> tryCatch<E, T>(
    T Function() fn,
    E Function(Object error, StackTrace stack) mapper,
  ) {
    try {
      return Res.success(fn());
    } catch (e, s) {
      return Res.error(mapper(e, s));
    }
  }

  /// Executes async function safely.
  ///
  /// **Parameters**
  /// - [fn]: Async function to execute
  /// - [mapper]: Maps exception to error
  ///
  /// **Returns**
  /// - Future of `Res`
  ///
  /// **Example**
  /// ```dart
  /// final r = await Res.asyncTry(
  ///   () async => 10,
  ///   (e, _) => "error",
  /// );
  /// ```
  static Future<Res<E, T>> asyncTry<E, T>(
    Future<T> Function() fn,
    E Function(Object error, StackTrace stack) mapper,
  ) async {
    try {
      final v = await fn();
      return Res.success(v);
    } catch (e, s) {
      return Res.error(mapper(e, s));
    }
  }

  /// Creates from nullable.
  ///
  /// **Parameters**
  /// - [value]: Nullable value
  /// - [err]: Error if null
  ///
  /// **Returns**
  /// - `Success` if not null
  /// - `Error` otherwise
  ///
  /// **Example**
  /// ```dart
  /// Res.fromNullable(null, "error");
  /// ```
  static Res<E, T> fromNullable<E, T>(T? value, E err) {
    if (value == null) {
      return Res.error(err);
    }
    return Res.success(value);
  }

  /// Creates from boolean condition.
  ///
  /// **Parameters**
  /// - [condition]: Boolean condition
  /// - [err]: Error if false
  ///
  /// **Returns**
  /// - `Success<void>` if true
  /// - `Error` otherwise
  ///
  /// **Example**
  /// ```dart
  /// Res.fromBool(1 > 0, "error");
  /// ```
  static Res<E, void> fromBool<E>(bool condition, E err) {
    if (condition) {
      return Res.unit();
    }
    return Res.error(err);
  }

  // =========================
  // Collections
  // =========================

  /// Combines multiple results.
  ///
  /// **Parameters**
  /// - [list]: List of [Res] values
  ///
  /// **Returns**
  /// - `Success<List<T>>` if all results are success
  /// - First encountered `Error` otherwise
  ///
  /// **Behavior**
  /// - Stops at the first error (fail-fast)
  ///
  /// **Example**
  /// ```dart
  /// final r = Res.combine([
  ///   Res.success(1),
  ///   Res.success(2),
  /// ]);
  /// // Success([1, 2])
  /// ```
  static Res<E, List<T>> combine<E, T>(List<Res<E, T>> list) {
    final values = <T>[];

    for (final r in list) {
      if (r is Success<E, T>) {
        values.add(r.value);
      } else {
        return Res.error((r as Error<E, T>).error);
      }
    }

    return Res.success(values);
  }

  /// Runs futures sequentially.
  ///
  /// **Parameters**
  /// - [list]: List of async [Res] operations
  ///
  /// **Returns**
  /// - `Success<List<T>>` if all succeed
  /// - First `Error` encountered otherwise
  ///
  /// **Behavior**
  /// - Executes one by one (awaits each before next)
  /// - Stops at the first error (fail-fast)
  ///
  /// **Example**
  /// ```dart
  /// final r = await Res.sequence([
  ///   Future.value(Res.success(1)),
  ///   Future.value(Res.success(2)),
  /// ]);
  /// ```
  static Future<Res<E, List<T>>> sequence<E, T>(
    List<Future<Res<E, T>>> list,
  ) async {
    final values = <T>[];

    for (final f in list) {
      final r = await f;

      if (r is Success<E, T>) {
        values.add(r.value);
      } else {
        return Res.error((r as Error<E, T>).error);
      }
    }

    return Res.success(values);
  }

  /// Runs futures in parallel.
  ///
  /// **Parameters**
  /// - [list]: List of async [Res] operations
  ///
  /// **Returns**
  /// - `Success<List<T>>` if all succeed
  /// - First `Error` found otherwise
  ///
  /// **Behavior**
  /// - Executes all futures concurrently
  /// - Waits for all to complete before evaluating
  /// - Still returns only the first error found
  ///
  /// **Example**
  /// ```dart
  /// final r = await Res.parallel([
  ///   Future.value(Res.success(1)),
  ///   Future.value(Res.success(2)),
  /// ]);
  /// ```
  static Future<Res<E, List<T>>> parallel<E, T>(
    List<Future<Res<E, T>>> list,
  ) async {
    final results = await Future.wait(list);

    final values = <T>[];

    for (final r in results) {
      if (r is Success<E, T>) {
        values.add(r.value);
      } else {
        return Res.error((r as Error<E, T>).error);
      }
    }

    return Res.success(values);
  }

  /// Maps items and sequences results.
  ///
  /// **Parameters**
  /// - [list]: Input values
  /// - [fn]: Async function returning [Res] for each item
  ///
  /// **Returns**
  /// - `Success<List<R>>` if all succeed
  /// - First `Error` encountered otherwise
  ///
  /// **Behavior**
  /// - Executes sequentially (like [sequence])
  /// - Stops at first error (fail-fast)
  ///
  /// **Example**
  /// ```dart
  /// final r = await Res.traverse(
  ///   [1, 2, 3],
  ///   (v) async => Res.success(v * 2),
  /// );
  /// Success([2, 4, 6])
  /// ```
  static Future<Res<E, List<R>>> traverse<E, T, R>(
    List<T> list,
    Future<Res<E, R>> Function(T item) fn,
  ) async {
    final values = <R>[];

    for (final item in list) {
      final r = await fn(item);

      if (r is Success<E, R>) {
        values.add(r.value);
      } else {
        return Res.error((r as Error<E, R>).error);
      }
    }

    return Res.success(values);
  }

  /// Combines two results.
  ///
  /// **Parameters**
  /// - [a]: First result
  /// - [b]: Second result
  ///
  /// **Returns**
  /// - `Success<(A, B)>` if both are success
  /// - First encountered `Error` otherwise
  ///
  /// **Behavior**
  /// - Fail-fast: returns the first error found
  ///
  /// **Example**
  /// ```dart
  /// final r = Res.zip(
  ///   Res.success(1),
  ///   Res.success("a"),
  /// );
  /// // Success((1, "a"))
  /// ```
  static Res<E, (A, B)> zip<E, A, B>(Res<E, A> a, Res<E, B> b) {
    if (a is Success<E, A> && b is Success<E, B>) {
      return Res.success((a.value, b.value));
    }
    if (a is Error<E, A>) {
      return Res.error(a.error);
    }
    return Res.error((b as Error<E, B>).error);
  }

  /// Combines three results.
  ///
  /// **Parameters**
  /// - [a]: First result
  /// - [b]: Second result
  /// - [c]: Third result
  ///
  /// **Returns**
  /// - `Success<(A, B, C)>` if all succeed
  /// - First encountered `Error` otherwise
  ///
  /// **Behavior**
  /// - Fail-fast in left-to-right order
  ///
  /// **Example**
  /// ```dart
  /// final r = Res.zip3(
  ///   Res.success(1),
  ///   Res.success("a"),
  ///   Res.success(true),
  /// );
  /// Success((1, "a", true))
  /// ```
  static Res<E, (A, B, C)> zip3<E, A, B, C>(
    Res<E, A> a,
    Res<E, B> b,
    Res<E, C> c,
  ) {
    if (a is Success<E, A> && b is Success<E, B> && c is Success<E, C>) {
      return Res.success((a.value, b.value, c.value));
    }
    if (a is Error<E, A>) {
      return Res.error(a.error);
    }
    if (b is Error<E, B>) {
      return Res.error(b.error);
    }
    return Res.error((c as Error<E, C>).error);
  }

  /// Combines four results.
  ///
  /// **Parameters**
  /// - [a]: First result
  /// - [b]: Second result
  /// - [c]: Third result
  /// - [d]: Fourth result
  ///
  /// **Returns**
  /// - `Success<(A, B, C, D)>` if all succeed
  /// - First encountered `Error` otherwise
  ///
  /// **Behavior**
  /// - Fail-fast in left-to-right order
  ///
  /// **Example**
  /// ```dart
  /// final r = Res.zip4(
  ///   Res.success(1),
  ///   Res.success("a"),
  ///   Res.success(true),
  ///   Res.success(2.5),
  /// );
  /// // Success((1, "a", true, 2.5))
  /// ```
  static Res<E, (A, B, C, D)> zip4<E, A, B, C, D>(
    Res<E, A> a,
    Res<E, B> b,
    Res<E, C> c,
    Res<E, D> d,
  ) {
    if (a is Success<E, A> &&
        b is Success<E, B> &&
        c is Success<E, C> &&
        d is Success<E, D>) {
      return Res.success((a.value, b.value, c.value, d.value));
    }
    if (a is Error<E, A>) {
      return Res.error(a.error);
    }
    if (b is Error<E, B>) {
      return Res.error(b.error);
    }
    if (c is Error<E, C>) {
      return Res.error(c.error);
    }
    return Res.error((d as Error<E, D>).error);
  }

  /// Flattens nested results.
  ///
  /// **Parameters**
  /// - [res]: Nested result (`Res<E, Res<E, T>>`)
  ///
  /// **Returns**
  /// - Inner `Res` if outer is success
  /// - Outer error otherwise
  ///
  /// **Behavior**
  /// - Removes one level of nesting
  ///
  /// **Example**
  /// ```dart
  /// final r = Res.flatten(
  ///   Res.success(Res.success(10)),
  /// );
  /// // Success(10)
  /// ```
  static Res<E, T> flatten<E, T>(Res<E, Res<E, T>> res) {
    if (res is Success<E, Res<E, T>>) {
      return res.value;
    }
    return Res.error((res as Error<E, Res<E, T>>).error);
  }
}

// =========================
// IMPLEMENTATION
// =========================

final class Success<E, T> extends Res<E, T> {
  const Success(this.value);
  final T value;

  @override
  String toString() => 'Success($value)';
}

final class Error<E, T> extends Res<E, T> {
  const Error(this.error);
  @override
  final E error;

  @override
  String toString() => 'Error($error)';
}

// =========================
// Global helpers
// =========================

/// Shortcut for [Success]
Res<E, T> success<E, T>(T value) => Success<E, T>(value);

/// Shortcut for [Error]
Res<E, T> error<E, T>(E err) => Error<E, T>(err);

/// Shortcut for [Res.unit]
Res<E, void> unit<E>() => Success<E, void>(null);
