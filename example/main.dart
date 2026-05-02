import 'dart:async';

import 'package:your_package/your_package.dart';

void main() async {
  state();
  core();
  transform();
  helpers();
  filters();
  recovery();
  asyncPart();
  constructors();
  collections();
}

// -------------------------
// STATE
// -------------------------

void state() {
  final s = Res.success<String, int>(10);
  final e = Res.error<String, int>('fail');

  print(s.isSuccess); // true
  print(e.isError); // true

  print(s.success); // 10
  print(e.error); // fail
}

// -------------------------
// CORE
// -------------------------

void core() {
  final r = Res.success<String, int>(5);

  final when = r.when(success: (v) => v * 2, error: (_) => 0);

  final fold = r.fold((v) => v * 3, (_) => 0);

  print(when);
  print(fold);
}

// -------------------------
// TRANSFORM
// -------------------------

void transform() {
  final r = Res.success<String, int>(5);

  final mapped = r.map((v) => v * 2);
  final mappedError = r.mapError((e) => 'error: $e');

  final chained = r.andThen((v) => Res.success(v * 10));

  print(mapped);
  print(mappedError);
  print(chained);
}

// -------------------------
// HELPERS
// -------------------------

void helpers() {
  final r = Res.success<String, int>(5);
  final e = Res.error<String, int>('fail');

  print(r.mapOr(0, (v) => v * 2));
  print(e.mapOr(0, (v) => v * 2));

  print(r.mapOrElse((_) => 0, (v) => v * 2));
  print(e.mapOrElse((err) => err.length, (v) => v * 2));
}

// -------------------------
// FILTERS + SIDE EFFECTS
// -------------------------

void filters() {
  final r = Res.success<String, int>(10);

  print(r.filter((v) => v > 5, 'too small'));
  print(r.exists((v) => v > 5));
  print(r.contains(10));

  r.tap(print);
  Res.error<String, int>('fail').tapError(print);
}

// -------------------------
// RECOVERY / EXTRACTION
// -------------------------

void recovery() {
  final e = Res.error<String, int>('fail');

  print(e.getOrElse((_) => 0));
  print(e.recover((_) => 42));
  print(e.toNullable());
}

// -------------------------
// ASYNC
// -------------------------

Future<void> asyncPart() async {
  final r = Res.success<String, int>(2);

  final mapped = await r.mapAsync((v) async => v * 2);

  final flatMapped = await r.flatMapAsync((v) async {
    return Res.success(v * 3);
  });

  print(mapped);
  print(flatMapped);

  final safe = await Res.asyncTry<String, int>(
    () async => 10,
    (e, _) => 'error',
  );

  print(safe);
}

// -------------------------
// CONSTRUCTORS
// -------------------------

void constructors() {
  print(Res.unit<String>());

  final tryCatch = Res.tryCatch<String, int>(
    () => int.parse('10'),
    (e, _) => 'parse error',
  );

  final nullable = Res.fromNullable<String, int>(null, 'null error');
  final boolRes = Res.fromBool<String>(true, 'false');

  print(tryCatch);
  print(nullable);
  print(boolRes);
}

// -------------------------
// COLLECTIONS
// -------------------------

Future<void> collections() async {
  final list = [Res.success<String, int>(1), Res.success<String, int>(2)];

  print(Res.combine(list));

  final futures = [
    Future.value(Res.success<String, int>(1)),
    Future.value(Res.success<String, int>(2)),
  ];

  print(await Res.sequence(futures));
  print(await Res.parallel(futures));

  final traversed = await Res.traverse<String, int, int>([
    1,
    2,
    3,
  ], (v) async => Res.success(v * 2));

  print(traversed);

  final a = Res.success<String, int>(1);
  final b = Res.success<String, String>('a');
  final c = Res.success<String, bool>(true);
  final d = Res.success<String, double>(2.5);

  print(Res.zip(a, b));
  print(Res.zip3(a, b, c));
  print(Res.zip4(a, b, c, d));

  final nested = Res.success<String, Res<String, int>>(Res.success(10));

  print(Res.flatten(nested));
}
