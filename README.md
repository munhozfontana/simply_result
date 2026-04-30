
# simply_result

A lightweight Result type for Dart.

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
![coverage](https://img.shields.io/badge/coverage-98%25-brightgreen)

---

## Features

- Functional Result type
- Success / Error modeling
- Functional helpers (map, flatMap, zip)
- Async helpers
- Zero dependencies
- High test coverage

---

## API Index

Quick dictionary of all helpers available in **simply_result**.

- [simply\_result](#simply_result)
  - [Features](#features)
  - [API Index](#api-index)
  - [Installation](#installation)
  - [API](#api)
  - [Constructors](#constructors)
    - [`success(value)`](#successvalue)
    - [`error(err)`](#errorerr)
    - [`Res.unit()`](#resunit)
  - [Core](#core)
    - [`map`](#map)
    - [`flatMap`](#flatmap)
    - [`mapError`](#maperror)
    - [`fold`](#fold)
  - [Recovery](#recovery)
    - [`getOrElse`](#getorelse)
    - [`recover`](#recover)
  - [Async](#async)
    - [`mapAsync`](#mapasync)
    - [`flatMapAsync`](#flatmapasync)
  - [Side effects](#side-effects)
    - [`tap`](#tap)
    - [`tapError`](#taperror)
  - [Mapping helpers](#mapping-helpers)
    - [`mapOr`](#mapor)
    - [`mapOrElse`](#maporelse)
  - [Filters](#filters)
    - [`filter`](#filter)
    - [`exists`](#exists)
    - [`contains`](#contains)
  - [Conversions](#conversions)
    - [`toNullable`](#tonullable)
  - [Try](#try)
    - [`tryCatch`](#trycatch)
    - [`asyncTry`](#asynctry)
  - [Guards](#guards)
    - [`fromNullable`](#fromnullable)
    - [`fromBool`](#frombool)
  - [Collections](#collections)
    - [`combine`](#combine)
    - [`sequence`](#sequence)
    - [`parallel`](#parallel)
    - [`traverse`](#traverse)
  - [Zip](#zip)
    - [`zip`](#zip-1)
    - [`zip3`](#zip3)
    - [`zip4`](#zip4)
  - [Advanced](#advanced)
    - [`flatten`](#flatten)

## Installation

```yaml
dependencies:
  simply_result: ^1.0.0
```

## API

---

## Constructors

### `success(value)`

Creates a **successful result** containing a value.

Use it when an operation completes correctly.

```dart
final result = success(10);

print(result);
// → Success(10)
```

---

### `error(err)`

Creates a **failed result** containing an error.

Useful for returning failures **without throwing exceptions**.

```dart
final result = error("network failure");

print(result);
// → Error(network failure)
```

---

### `Res.unit()`

Creates a success result containing `null`.
Useful when the operation has **no meaningful return value**.

```dart
final result = Res.unit();

print(result);
// → Success(null)
```

---

## Core

### `map`

Transforms the value **only if the result is `Success`**.
If the result is `Error`, it is propagated unchanged.

```dart
final result = success(5)
    .map((v) => v * 2);

print(result);
// → Success(10)
```

Error propagation:

```dart
final result = error("fail")
    .map((v) => v * 2);

print(result);
// → Error(fail)
```

---

### `flatMap`

Chains operations that **also return a `Res`**.

Useful for composing multiple fallible operations.

```dart
final result = success(5)
    .flatMap((v) => success(v * 2));

print(result);
// → Success(10)
```

Error propagation:

```dart
final result = error("fail")
    .flatMap((v) => success(v * 2));

print(result);
// → Error(fail)
```

---

### `mapError`

Transforms the **error value** without touching the success value.

```dart
final result = error("network")
    .mapError((e) => "Error: $e");

print(result);
// → Error(Error: network)
```

---

### `fold`

Handles **both success and error cases**, returning a single value.

```dart
final result = success(10).fold(
  (value) => "Value: $value",
  (err) => "Error: $err",
);

print(result);
// → Value: 10
```

With error:

```dart
final result = error("fail").fold(
  (value) => "Value: $value",
  (err) => "Error: $err",
);

print(result);
// → Error: fail
```

---

## Recovery

### `getOrElse`

Returns the value if success, otherwise returns a **fallback**.

```dart
final value = success(10)
    .getOrElse((_) => 0);

print(value);
// → 10
```

With error:

```dart
final value = error("fail")
    .getOrElse((_) => 0);

print(value);
// → 0
```

---

### `recover`

Transforms an error into success.

```dart
final result = error("fail")
    .recover((_) => 42);
```

---

## Async

### `mapAsync`

Asynchronous version of `map`.

```dart
final result = await success(5)
    .mapAsync((v) async => v * 2);

print(result);
// → Success(10)
```

---

### `flatMapAsync`

Asynchronous version of `flatMap`.

```dart
final result = await success(5)
    .flatMapAsync((v) async => success(v * 2));

print(result);
// → Success(10)
```

---

## Side effects

### `tap`

Executes side-effect on success.

```dart
success(10).tap(print);
```

---

### `tapError`

Executes side-effect on error.

```dart
error("fail").tapError(print);
```

---

## Mapping helpers

### `mapOr`

Returns a fallback if `Error`.

```dart
final result = error("fail")
    .mapOr(0, (v) => v * 2);
```

---

### `mapOrElse`

Lazy fallback for `Error`.

```dart
final result = error("fail")
    .mapOrElse(
      (e) => -1,
      (v) => v * 2,
    );
```

---

## Filters

### `filter`

Fails if predicate does not match.

```dart
final result = success(10)
    .filter((v) => v > 5, "too small");
```

---

### `exists`

Checks predicate on success.

```dart
success(10).exists((v) => v > 5);
```

---

### `contains`

Checks equality on success.

```dart
success(10).contains(10);
```

---

## Conversions

### `toNullable`

Converts to nullable value.

```dart
success(10).toNullable(); // 10
error("fail").toNullable(); // null
```

---

## Try

### `tryCatch`

Wraps sync code.

```dart
final result = Res.tryCatch(
  () => int.parse("10"),
  (e, _) => e.toString(),
);
```

---

### `asyncTry`

Wraps async code.

```dart
final result = await Res.asyncTry(
  () async => 10,
  (e, _) => e.toString(),
);
```

---

## Guards

### `fromNullable`

Creates result from nullable.

```dart
final result = Res.fromNullable(null, "error");
```

---

### `fromBool`

Creates result from condition.

```dart
final result = Res.fromBool(false, "fail");
```

---

## Collections

### `combine`

Combines multiple results.

```dart
final result = Res.combine([
  success(1),
  success(2),
]);
```

---

### `sequence`

Runs futures sequentially.

```dart
final result = await Res.sequence([
  Future.value(success(1)),
  Future.value(success(2)),
]);
```

---

### `parallel`

Runs futures in parallel.

```dart
final result = await Res.parallel([
  Future.value(success(1)),
  Future.value(success(2)),
]);
```

---

### `traverse`

Maps and sequences.

```dart
final result = await Res.traverse(
  [1, 2, 3],
  (n) async => success(n * 2),
);
```

---

## Zip

### `zip`

Combines **two results** into one.

```dart
final result = Res.zip(
  success(2),
  success(3),
);

print(result);
// → Success((2, 3))
```

---

### `zip3`

Combines **three results**.

```dart
final result = Res.zip3(
  success(2),
  success(3),
  success(5),
);

print(result);
// → Success((2, 3, 5))
```

---

### `zip4`

Combines four results.

```dart
final result = Res.zip4(
  success(1),
  success(2),
  success(3),
  success(4),
);
```

---

## Advanced

### `flatten`

Flattens nested results.

```dart
final result = Res.flatten(
  success(success(10)),
);
```
