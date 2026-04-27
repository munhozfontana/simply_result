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
  - [`success(value)`](#successvalue)
  - [`error(err)`](#errorerr)
  - [`map`](#map)
  - [`flatMap`](#flatmap)
  - [`mapError`](#maperror)
  - [`fold`](#fold)
  - [`getOrElse`](#getorelse)
  - [`zip`](#zip)
  - [`zip3`](#zip3)
  - [`mapAsync`](#mapasync)
  - [`flatMapAsync`](#flatmapasync)
  - [`pipe`](#pipe)
  - [`Res.unit()`](#resunit)

## Installation

```yaml
dependencies:
  simply_result: ^1.0.0
```

## API

## `success(value)`

Creates a **successful result** containing a value.

Use it when an operation completes correctly.

```dart
final result = success(10);

print(result);
// → Success(10)
```

---

## `error(err)`

Creates a **failed result** containing an error.

Useful for returning failures **without throwing exceptions**.

```dart
final result = error("network failure");

print(result);
// → Error(network failure)
```

---

## `map`

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

## `flatMap`

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

## `mapError`

Transforms the **error value** without touching the success value.

```dart
final result = error("network")
    .mapError((e) => "Error: $e");

print(result);
// → Error(Error: network)
```

---

## `fold`

Handles **both success and error cases**, returning a single value.

```dart
final result = success(10).fold(
  (err) => "Error: $err",
  (value) => "Value: $value",
);

print(result);
// → Value: 10
```

With error:

```dart
final result = error("fail").fold(
  (err) => "Error: $err",
  (value) => "Value: $value",
);

print(result);
// → Error: fail
```

---

## `getOrElse`

Returns the value if success, otherwise returns a **fallback**.

```dart
final value = success(10)
    .getOrElse(() => 0);

print(value);
// → 10
```

With error:

```dart
final value = error("fail")
    .getOrElse(() => 0);

print(value);
// → 0
```

---

## `zip`

Combines **two results** into one.

If any result is `Error`, the first error is returned.

```dart
final result = Res.zip(
  success(2),
  success(3),
  (a, b) => a + b,
);

print(result);
// → Success(5)
```

With error:

```dart
final result = Res.zip(
  success(2),
  error("fail"),
  (a, b) => a + b,
);

print(result);
// → Error(fail)
```

---

## `zip3`

Combines **three results**.

```dart
final result = Res.zip3(
  success(2),
  success(3),
  success(5),
  (a, b, c) => a + b + c,
);

print(result);
// → Success(10)
```

---

## `mapAsync`

Asynchronous version of `map`.

```dart
final result = await success(5)
    .mapAsync((v) async => v * 2);

print(result);
// → Success(10)
```

---

## `flatMapAsync`

Asynchronous version of `flatMap`.

```dart
final result = await success(5)
    .flatMapAsync((v) async => success(v * 2));

print(result);
// → Success(10)
```

---

## `pipe`

Allows chaining transformations in a **functional pipeline style**.

```dart
final result = success(5)
    .pipe((r) => r.map((v) => v * 2));

print(result);
// → Success(10)
```

---

## `Res.unit()`

Creates a success result containing `null`.
Useful when the operation has **no meaningful return value**.

```dart
final result = Res.unit();

print(result);
// → Success(null)
```
