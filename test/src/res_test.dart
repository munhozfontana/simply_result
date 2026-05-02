import 'package:flutter_test/flutter_test.dart';
import 'package:simply_result/simply_result.dart';

void main() {
  // ========================
  // Constructors
  // ========================

  group('constructors', () {
    test('success constructor', () {
      const r = Res<String, int>.success(10);

      expect(r.isSuccess, true);
      expect(r.isError, false);
      expect(r.success, 10);
      expect(r.error, null);
    });

    test('error constructor', () {
      const r = Res<String, int>.error('fail');

      expect(r.isSuccess, false);
      expect(r.isError, true);
      expect(r.success, null);
      expect(r.error, 'fail');
    });

    test('unit', () {
      final r = Res.unit<String>();

      expect(r.isSuccess, true);
    });
  });

  // ========================
  // Core
  // ========================

  group('when / fold', () {
    test('when success', () {
      const r = Res<String, int>.success(2);

      final v = r.when(success: (v) => v * 2, error: (_) => 0);

      expect(v, 4);
    });

    test('when error', () {
      const r = Res<String, int>.error('err');

      final v = r.when(success: (v) => v * 2, error: (_) => 5);

      expect(v, 5);
    });

    test('fold success', () {
      const r = Res<String, int>.success(3);

      final v = r.fold((v) => v + 1, (_) => 0);

      expect(v, 4);
    });

    test('fold error', () {
      const r = Res<String, int>.error('fail');

      final v = r.fold((_) => 0, (_) => 9);

      expect(v, 9);
    });
  });

  // ========================
  // Transform
  // ========================

  group('map', () {
    test('map success', () {
      const r = Res<String, int>.success(2);

      final m = r.map((v) => v * 5);

      expect(m.success, 10);
    });

    test('map error', () {
      const r = Res<String, int>.error('err');

      final m = r.map((v) => v * 5);

      expect(m.error, 'err');
    });
  });

  group('mapError', () {
    test('mapError transforms error', () {
      const r = Res<String, int>.error('fail');

      final m = r.mapError((e) => 'mapped:$e');

      expect(m.error, 'mapped:fail');
    });

    test('mapError ignored on success', () {
      const r = Res<String, int>.success(7);

      final m = r.mapError((e) => 'mapped:$e');

      expect(m.success, 7);
    });
  });

  group('andThen', () {
    test('andThen success', () {
      const r = Res<String, int>.success(2);

      final res = r.andThen((v) => Res.success(v * 3));

      expect(res.success, 6);
    });

    test('andThen error', () {
      const r = Res<String, int>.error('fail');

      final res = r.andThen((v) => Res.success(v * 3));

      expect(res.error, 'fail');
    });
  });

  // ========================
  // Mapping helpers
  // ========================

  group('mapOr / mapOrElse', () {
    test('mapOr success', () {
      const r = Res<String, int>.success(4);

      final v = r.mapOr(0, (v) => v * 2);

      expect(v, 8);
    });

    test('mapOr fallback', () {
      const r = Res<String, int>.error('fail');

      final v = r.mapOr(9, (v) => v * 2);

      expect(v, 9);
    });

    test('mapOrElse success', () {
      const r = Res<String, int>.success(3);

      final v = r.mapOrElse((_) => 0, (v) => v * 4);

      expect(v, 12);
    });

    test('mapOrElse error', () {
      const r = Res<String, int>.error('fail');

      final v = r.mapOrElse((_) => 99, (v) => v * 4);

      expect(v, 99);
    });
  });

  // ========================
  // Filters
  // ========================

  group('filter', () {
    test('filter pass', () {
      const r = Res<String, int>.success(10);

      final res = r.filter((v) => v > 5, 'bad');

      expect(res.success, 10);
    });

    test('filter fail', () {
      const r = Res<String, int>.success(2);

      final res = r.filter((v) => v > 5, 'bad');

      expect(res.error, 'bad');
    });

    test('filter ignored on error', () {
      const r = Res<String, int>.error('fail');

      final res = r.filter((v) => true, 'bad');

      expect(res.error, 'fail');
    });
  });

  group('exists / contains', () {
    test('exists true', () {
      const r = Res<String, int>.success(5);

      expect(r.exists((v) => v == 5), true);
    });

    test('exists false', () {
      const r = Res<String, int>.error('fail');

      expect(r.exists((v) => true), false);
    });

    test('contains true', () {
      const r = Res<String, int>.success(7);

      expect(r.contains(7), true);
    });

    test('contains false', () {
      const r = Res<String, int>.error('fail');

      expect(r.contains(7), false);
    });
  });

  // ========================
  // Side effects
  // ========================

  group('tap / tapError', () {
    test('tap success', () {
      var captured = 0;

      const Res<String, int>.success(8).tap((v) {
        captured = v;
      });

      expect(captured, 8);
    });

    test('tapError', () {
      String? captured;

      const Res<String, int>.error('fail').tapError((e) {
        captured = e;
      });

      expect(captured, 'fail');
    });
  });

  // ========================
  // Recovery
  // ========================

  group('recovery', () {
    test('getOrElse success', () {
      const r = Res<String, int>.success(10);

      expect(r.getOrElse((_) => 0), 10);
    });

    test('getOrElse fallback', () {
      const r = Res<String, int>.error('fail');

      expect(r.getOrElse((_) => 7), 7);
    });

    test('recover', () {
      const r = Res<String, int>.error('fail');

      final res = r.recover((_) => 3);

      expect(res.success, 3);
    });
  });

  // ========================
  // Async
  // ========================

  group('async', () {
    test('mapAsync success', () async {
      const r = Res<String, int>.success(5);

      final res = await r.mapAsync((v) async => v * 2);

      expect(res.success, 10);
    });

    test('mapAsync error', () async {
      const r = Res<String, int>.error('fail');

      final res = await r.mapAsync((v) async => v * 2);

      expect(res.error, 'fail');
    });

    test('flatMapAsync', () async {
      const r = Res<String, int>.success(5);

      final res = await r.flatMapAsync((v) async => Res.success(v * 3));

      expect(res.success, 15);
    });
  });

  // ========================
  // Try
  // ========================

  group('try', () {
    test('tryCatch success', () {
      final r = Res.tryCatch<String, int>(() => 10, (_, _) => 'fail');

      expect(r.success, 10);
    });

    test('tryCatch error', () {
      final r = Res.tryCatch<String, int>(
        () => throw Exception(),
        (_, _) => 'mapped',
      );

      expect(r.error, 'mapped');
    });

    test('asyncTry success', () async {
      final r = await Res.asyncTry<String, int>(() async => 5, (_, _) => 'err');

      expect(r.success, 5);
    });

    test('asyncTry error', () async {
      final r = await Res.asyncTry<String, int>(
        () async => throw Exception(),
        (_, _) => 'mapped',
      );

      expect(r.error, 'mapped');
    });
  });

  // ========================
  // Guards
  // ========================

  group('guards', () {
    test('fromNullable success', () {
      final r = Res.fromNullable<String, int>(5, 'err');

      expect(r.success, 5);
    });

    test('fromNullable null', () {
      final r = Res.fromNullable<String, int>(null, 'err');

      expect(r.error, 'err');
    });

    test('fromBool true', () {
      final r = Res.fromBool<String>(true, 'err');

      expect(r.isSuccess, true);
    });

    test('fromBool false', () {
      final r = Res.fromBool<String>(false, 'err');

      expect(r.error, 'err');
    });
  });

  // ========================
  // Collections
  // ========================

  group('collections', () {
    test('combine success', () {
      final list = [
        const Res<String, int>.success(1),
        const Res<String, int>.success(2),
      ];

      final r = Res.combine(list);

      expect(r.success, [1, 2]);
    });

    test('combine error', () {
      final list = [
        const Res<String, int>.success(1),
        const Res<String, int>.error('fail'),
      ];

      final r = Res.combine(list);

      expect(r.error, 'fail');
    });

    test('sequence', () async {
      final list = [
        Future.value(const Res<String, int>.success(1)),
        Future.value(const Res<String, int>.success(2)),
      ];

      final r = await Res.sequence(list);

      expect(r.success, [1, 2]);
    });

    test('traverse', () async {
      final r = await Res.traverse<String, int, int>([
        1,
        2,
        3,
      ], (v) async => Res.success(v * 2));

      expect(r.success, [2, 4, 6]);
    });
  });

  group('parallel', () {
    test('returns success with all values when everything succeeds', () async {
      final futures = [
        Future.value(const Res<int, int>.success(1)),
        Future.value(const Res<int, int>.success(2)),
        Future.value(const Res<int, int>.success(3)),
      ];

      final result = await Res.parallel(futures);

      expect(result is Success<int, List<int>>, true);
      expect((result as Success).value, [1, 2, 3]);
    });

    test('returns error when any future fails', () async {
      final futures = [
        Future.value(const Res<String, int>.success(1)),
        Future.value(const Res<String, int>.error('error')),
        Future.value(const Res<String, int>.success(3)),
      ];

      final result = await Res.parallel<String, int>(futures);

      expect(result is Error<String, List<int>>, true);
      expect((result as Error).error, 'error');
    });

    test('returns success with an empty list', () async {
      final futures = <Future<Res<String, int>>>[];

      final result = await Res.parallel<String, int>(futures);

      expect(result is Success<String, List<int>>, true);
      expect((result as Success).value, isEmpty);
    });

    test('runs in parallel (not sequentially)', () async {
      final start = DateTime.now();

      final futures = [
        Future.delayed(
          const Duration(milliseconds: 100),
          () => const Res<String, int>.success(1),
        ),
        Future.delayed(
          const Duration(milliseconds: 100),
          () => const Res<String, int>.success(2),
        ),
        Future.delayed(
          const Duration(milliseconds: 100),
          () => const Res<String, int>.success(3),
        ),
      ];

      final result = await Res.parallel<String, int>(futures);

      final elapsed = DateTime.now().difference(start);

      // If it were sequential it would take ~300ms
      // Parallel execution should be close to ~100ms
      expect(elapsed.inMilliseconds < 200, true);

      expect(result is Success<String, List<int>>, true);
      expect(result.success?.length, 3);
    });
  });
  // ========================
  // Zip
  // ========================

  group('zip', () {
    test('zip success', () {
      final r = Res.zip(
        const Res<String, int>.success(1),
        const Res<String, int>.success(2),
      );

      expect(r.success, (1, 2));
    });

    test('zip error', () {
      final r = Res.zip(
        const Res<String, int>.error('fail'),
        const Res<String, int>.success(2),
      );

      expect(r.error, 'fail');
    });

    test('last', () {
      final r = Res.zip(
        const Res<String, int>.success(2),
        const Res<String, int>.error('fail'),
      );

      expect(r.error, 'fail');
    });

    test('zip3', () {
      final r = Res.zip3(
        const Res<String, int>.success(1),
        const Res<String, int>.success(2),
        const Res<String, int>.success(3),
      );

      expect(r.success, (1, 2, 3));
    });

    test('zip3 error last', () {
      final r = Res.zip3(
        const Res<String, int>.success(1),
        const Res<String, int>.success(2),
        const Res<String, int>.error('fail'),
      );
      expect(r.error, 'fail');
    });

    test('zip4', () {
      final r = Res.zip4(
        const Res<String, int>.success(1),
        const Res<String, int>.success(2),
        const Res<String, int>.success(3),
        const Res<String, int>.success(4),
      );

      expect(r.success, (1, 2, 3, 4));
    });
  });

  // ========================
  // Flatten
  // ========================

  group('flatten', () {
    test('flatten success', () {
      final r = Res.flatten<String, int>(const Res.success(Res.success(5)));

      expect(r.success, 5);
    });

    test('flatten error', () {
      final r = Res.flatten<String, int>(const Res.error('fail'));

      expect(r.error, 'fail');
    });
  });

  // ========================
  // Equality
  // ========================

  group('equality', () {
    test('success equality', () {
      expect(const Success<String, int>(5), const Success<String, int>(5));
    });

    test('error equality', () {
      expect(
        const Error<String, int>('fail'),
        const Error<String, int>('fail'),
      );
    });
  });

  // ========================
  // Global helpers
  // ========================

  group('global helpers', () {
    test('success helper', () {
      final r = success<String, int>(5);

      expect(r.success, 5);
    });

    test('error helper', () {
      final r = error<String, int>('fail');

      expect(r.error, 'fail');
    });

    test('unit helper', () {
      final r = unit<String>();

      expect(r.isSuccess, true);
    });
  });

  // ========================
  // Extra coverage
  // ========================

  group('extra coverage', () {
    test('toNullable success', () {
      const r = Res<String, int>.success(5);

      expect(r.toNullable(), 5);
    });

    test('toNullable error', () {
      const r = Res<String, int>.error('fail');

      expect(r.toNullable(), null);
    });

    test('tap ignored on error', () {
      var captured = 0;

      const Res<String, int>.error('fail').tap((v) {
        captured = v;
      });

      expect(captured, 0);
    });

    test('tapError ignored on success', () {
      String? captured;

      const Res<String, int>.success(5).tapError((e) {
        captured = e;
      });

      expect(captured, null);
    });

    test('exists false on success', () {
      const r = Res<String, int>.success(5);

      expect(r.exists((v) => v > 10), false);
    });

    test('contains false on success', () {
      const r = Res<String, int>.success(5);

      expect(r.contains(10), false);
    });

    test('flatMapAsync error path', () async {
      const r = Res<String, int>.error('fail');

      final res = await r.flatMapAsync((v) async {
        return Res.success(v * 2);
      });

      expect(res.error, 'fail');
    });

    test('sequence stops on error', () async {
      final list = [
        Future.value(const Res<String, int>.success(1)),
        Future.value(const Res<String, int>.error('fail')),
        Future.value(const Res<String, int>.success(3)),
      ];

      final res = await Res.sequence(list);

      expect(res.error, 'fail');
    });

    test('traverse error', () async {
      final res = await Res.traverse<String, int, int>([1, 2, 3], (v) async {
        if (v == 2) {
          return const Res.error('fail');
        }
        return Res.success(v);
      });

      expect(res.error, 'fail');
    });

    test('zip3 error precedence', () {
      final r = Res.zip3(
        const Res<String, int>.success(1),
        const Res<String, int>.error('fail'),
        const Res<String, int>.success(3),
      );

      expect(r.error, 'fail');
    });

    test('zip4 error precedence', () {
      final r = Res.zip4(
        const Res<String, int>.success(1),
        const Res<String, int>.success(2),
        const Res<String, int>.error('fail'),
        const Res<String, int>.success(4),
      );

      expect(r.error, 'fail');
    });

    test('zip4 error last', () {
      final r = Res.zip4(
        const Res<String, int>.success(1),
        const Res<String, int>.success(2),
        const Res<String, int>.success(3),
        const Res<String, int>.error('fail'),
      );

      expect(r.error, 'fail');
    });

    test('flatten success containing error', () {
      final r = Res.flatten<String, int>(const Res.success(Res.error('fail')));

      expect(r.error, 'fail');
    });

    test('toString success', () {
      const r = Res<String, int>.success(5);

      expect(r.toString(), 'Success(5)');
    });

    test('toString error', () {
      const r = Res<String, int>.error('fail');

      expect(r.toString(), 'Error(fail)');
    });

    test('hashCode success', () {
      const r = Res<String, int>.success(5);

      expect(r.hashCode, isA<int>());
    });

    test('hashCode error', () {
      const r = Res<String, int>.error('fail');

      expect(r.hashCode, isA<int>());
    });
  });
}
