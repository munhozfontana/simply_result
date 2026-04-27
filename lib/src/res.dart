import 'package:flutter/foundation.dart';

/// A minimal functional Result type for Dart.
///
/// Inspired by Rust / Kotlin Result.
///
/// Represents either a [Success] or an [Error].
@immutable
sealed class Res<E, T> {
  const Res();

  // =========================
  // Constructors
  // =========================

  const factory Res.success(T value) = Success<E, T>;
  const factory Res.error(E error) = Error<E, T>;

  static Res<E, void> unit<E>() => Success<E, void>(null);

  // =========================
  // State
  // =========================

  bool get isSuccess => this is Success<E, T>;
  bool get isError => this is Error<E, T>;

  T? get success =>
      this is Success<E, T> ? (this as Success<E, T>).value : null;

  E? get error => this is Error<E, T> ? (this as Error<E, T>).error : null;

  // =========================
  // Core
  // =========================

  R when<R>({
    required R Function(T value) success,
    required R Function(E error) error,
  }) {
    if (this is Success<E, T>) {
      return success((this as Success<E, T>).value);
    }
    return error((this as Error<E, T>).error);
  }

  R fold<R>(R Function(T value) success, R Function(E error) error) {
    if (this is Success<E, T>) {
      return success((this as Success<E, T>).value);
    }
    return error((this as Error<E, T>).error);
  }

  // =========================
  // Transform
  // =========================

  Res<E, U> map<U>(U Function(T value) fn) {
    if (this is Success<E, T>) {
      return Res.success(fn((this as Success<E, T>).value));
    }
    return Res.error((this as Error<E, T>).error);
  }

  Res<F, T> mapError<F>(F Function(E error) fn) {
    if (this is Error<E, T>) {
      return Res.error(fn((this as Error<E, T>).error));
    }
    return Res.success((this as Success<E, T>).value);
  }

  Res<E, R> andThen<R>(Res<E, R> Function(T value) fn) {
    if (this is Success<E, T>) {
      return fn((this as Success<E, T>).value);
    }
    return Res.error((this as Error<E, T>).error);
  }

  // =========================
  // Mapping helpers
  // =========================

  R mapOr<R>(R fallback, R Function(T value) fn) {
    if (this is Success<E, T>) {
      return fn((this as Success<E, T>).value);
    }
    return fallback;
  }

  R mapOrElse<R>(R Function(E error) fallback, R Function(T value) fn) {
    if (this is Success<E, T>) {
      return fn((this as Success<E, T>).value);
    }
    return fallback((this as Error<E, T>).error);
  }

  // =========================
  // Filters
  // =========================

  Res<E, T> filter(bool Function(T value) predicate, E err) {
    if (this is Success<E, T>) {
      final v = (this as Success<E, T>).value;
      if (predicate(v)) return this;
      return Res.error(err);
    }
    return this;
  }

  bool exists(bool Function(T value) predicate) {
    if (this is Success<E, T>) {
      return predicate((this as Success<E, T>).value);
    }
    return false;
  }

  bool contains(T value) {
    if (this is Success<E, T>) {
      return (this as Success<E, T>).value == value;
    }
    return false;
  }

  // =========================
  // Side effects
  // =========================

  Res<E, T> tap(void Function(T value) fn) {
    if (this is Success<E, T>) {
      fn((this as Success<E, T>).value);
    }
    return this;
  }

  Res<E, T> tapError(void Function(E error) fn) {
    if (this is Error<E, T>) {
      fn((this as Error<E, T>).error);
    }
    return this;
  }

  // =========================
  // Recovery
  // =========================

  T getOrElse(T Function(E error) fallback) {
    if (this is Success<E, T>) {
      return (this as Success<E, T>).value;
    }
    return fallback((this as Error<E, T>).error);
  }

  Res<E, T> recover(T Function(E error) fn) {
    if (this is Success<E, T>) return this;
    return Res.success(fn((this as Error<E, T>).error));
  }

  // =========================
  // Async
  // =========================

  Future<Res<E, R>> mapAsync<R>(Future<R> Function(T value) fn) async {
    if (this is Success<E, T>) {
      final v = await fn((this as Success<E, T>).value);
      return Res.success(v);
    }
    return Res.error((this as Error<E, T>).error);
  }

  Future<Res<E, R>> flatMapAsync<R>(
    Future<Res<E, R>> Function(T value) fn,
  ) async {
    if (this is Success<E, T>) {
      return fn((this as Success<E, T>).value);
    }
    return Res.error((this as Error<E, T>).error);
  }

  // =========================
  // Conversions
  // =========================

  T? toNullable() {
    if (this is Success<E, T>) {
      return (this as Success<E, T>).value;
    }
    return null;
  }

  // =========================
  // Try
  // =========================

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

  // =========================
  // Guards
  // =========================

  static Res<E, T> fromNullable<E, T>(T? value, E err) {
    if (value == null) {
      return Res.error(err);
    }
    return Res.success(value);
  }

  static Res<E, void> fromBool<E>(bool condition, E err) {
    if (condition) return Res.unit();
    return Res.error(err);
  }

  // =========================
  // Collections
  // =========================

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

  // =========================
  // Zip
  // =========================

  static Res<E, (A, B)> zip<E, A, B>(Res<E, A> a, Res<E, B> b) {
    if (a is Success<E, A> && b is Success<E, B>) {
      return Res.success((a.value, b.value));
    }

    if (a is Error<E, A>) return Res.error(a.error);
    return Res.error((b as Error<E, B>).error);
  }

  static Res<E, (A, B, C)> zip3<E, A, B, C>(
    Res<E, A> a,
    Res<E, B> b,
    Res<E, C> c,
  ) {
    if (a is Success<E, A> && b is Success<E, B> && c is Success<E, C>) {
      return Res.success((a.value, b.value, c.value));
    }

    if (a is Error<E, A>) return Res.error(a.error);
    if (b is Error<E, B>) return Res.error(b.error);
    return Res.error((c as Error<E, C>).error);
  }

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

    if (a is Error<E, A>) return Res.error(a.error);
    if (b is Error<E, B>) return Res.error(b.error);
    if (c is Error<E, C>) return Res.error(c.error);
    return Res.error((d as Error<E, D>).error);
  }

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

  @override
  bool operator ==(Object other) =>
      other is Success<E, T> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final class Error<E, T> extends Res<E, T> {
  const Error(this.error);
  @override
  final E error;

  @override
  String toString() => 'Error($error)';

  @override
  bool operator ==(Object other) =>
      other is Error<E, T> && other.error == error;

  @override
  int get hashCode => error.hashCode;
}

// =========================
// Global helpers
// =========================

Res<E, T> success<E, T>(T value) => Success<E, T>(value);

Res<E, T> error<E, T>(E err) => Error<E, T>(err);

Res<E, void> unit<E>() => Success<E, void>(null);
