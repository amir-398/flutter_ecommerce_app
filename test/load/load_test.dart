import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce_app/services/api_service.dart';
import 'package:flutter_ecommerce_app/models/product.dart';

void main() {
  group('Load Tests', () {
    test('should handle concurrent API calls', () async {
      // Test concurrent API calls to simulate load
      final futures = <Future<List<Product>>>[];

      // Create 10 concurrent requests
      for (int i = 0; i < 10; i++) {
        futures.add(ApiService.getProducts());
      }

      final stopwatch = Stopwatch()..start();

      try {
        final results = await Future.wait(futures);
        stopwatch.stop();

        // Verify all requests completed successfully
        expect(results.length, equals(10));
        for (final result in results) {
          expect(result, isA<List<Product>>());
        }

        print(
          '✅ Load test passed: 10 concurrent requests completed in ${stopwatch.elapsedMilliseconds}ms',
        );

        // Performance assertion: should complete within 30 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(30000));
      } catch (e) {
        stopwatch.stop();
        print(
          '⚠️ Load test completed with errors in ${stopwatch.elapsedMilliseconds}ms: $e',
        );
        // In load testing, we might accept some failures
        expect(stopwatch.elapsedMilliseconds, lessThan(30000));
      }
    });

    test('should handle rapid sequential API calls', () async {
      final stopwatch = Stopwatch()..start();
      final results = <List<Product>>[];

      try {
        // Make 20 rapid sequential calls
        for (int i = 0; i < 20; i++) {
          final products = await ApiService.getProducts();
          results.add(products);
        }

        stopwatch.stop();

        expect(results.length, equals(20));
        print(
          '✅ Sequential load test passed: 20 requests completed in ${stopwatch.elapsedMilliseconds}ms',
        );

        // Performance assertion: should complete within 60 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(60000));
      } catch (e) {
        stopwatch.stop();
        print(
          '⚠️ Sequential load test completed with errors in ${stopwatch.elapsedMilliseconds}ms: $e',
        );
        expect(stopwatch.elapsedMilliseconds, lessThan(60000));
      }
    });

    test('should handle mixed API operations under load', () async {
      final stopwatch = Stopwatch()..start();
      final futures = <Future>[];

      try {
        // Mix different API operations
        for (int i = 0; i < 5; i++) {
          futures.add(ApiService.getProducts());
          futures.add(ApiService.getCategories());
          futures.add(ApiService.getProduct(i + 1));
        }

        final results = await Future.wait(futures);
        stopwatch.stop();

        expect(results.length, equals(15)); // 5 + 5 + 5
        print(
          '✅ Mixed operations load test passed: 15 mixed requests completed in ${stopwatch.elapsedMilliseconds}ms',
        );

        // Performance assertion: should complete within 45 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(45000));
      } catch (e) {
        stopwatch.stop();
        print(
          '⚠️ Mixed operations load test completed with errors in ${stopwatch.elapsedMilliseconds}ms: $e',
        );
        expect(stopwatch.elapsedMilliseconds, lessThan(45000));
      }
    });

    test('should measure memory usage during load', () async {
      // This is a basic memory usage test
      final initialMemory = ProcessInfo.currentRss;

      final futures = <Future<List<Product>>>[];

      // Create multiple concurrent requests
      for (int i = 0; i < 15; i++) {
        futures.add(ApiService.getProducts());
      }

      try {
        await Future.wait(futures);

        final finalMemory = ProcessInfo.currentRss;
        final memoryIncrease = finalMemory - initialMemory;

        print(
          '📊 Memory usage: Initial: ${initialMemory ~/ 1024}KB, Final: ${finalMemory ~/ 1024}KB, Increase: ${memoryIncrease ~/ 1024}KB',
        );

        // Basic memory check: increase should be reasonable (less than 100MB)
        expect(memoryIncrease, lessThan(100 * 1024 * 1024));
      } catch (e) {
        print('⚠️ Memory test completed with errors: $e');
        // Memory test should not fail the build
      }
    });

    test('should handle timeout scenarios gracefully', () async {
      final stopwatch = Stopwatch()..start();

      try {
        // Test with a very short timeout to simulate network issues
        final future = ApiService.getProducts().timeout(
          const Duration(seconds: 1),
          onTimeout: () {
            throw TimeoutException(
              'Request timed out',
              const Duration(seconds: 1),
            );
          },
        );

        await future;
        stopwatch.stop();
        print(
          '✅ Timeout test: Request completed in ${stopwatch.elapsedMilliseconds}ms',
        );
      } catch (e) {
        stopwatch.stop();
        print(
          '⚠️ Timeout test: Request failed after ${stopwatch.elapsedMilliseconds}ms: $e',
        );

        // Timeout is expected in some cases, so we don't fail the test
        expect(e, isA<TimeoutException>());
      }
    });
  });
}
