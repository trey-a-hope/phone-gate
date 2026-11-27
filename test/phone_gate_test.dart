import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_gate/phone_gate.dart';
import 'package:phone_gate/src/unsupported_device_page.dart';

/// Typical logical sizes used across the tests.
const _phonePortrait = Size(390, 844);
const _phoneLandscape = Size(844, 390);
const _tablet = Size(800, 1280);
const _unfoldedFoldable = Size(713, 848);
const _desktopWindow = Size(1280, 800);
const _tinyDesktopWindow = Size(320, 480);

void main() {
  // Each test sets the platform it needs; always restore the default after.
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('PhoneGate.isMobile', () {
    test('is true on iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(PhoneGate.isMobile, isTrue);
    });

    test('is true on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(PhoneGate.isMobile, isTrue);
    });

    for (final platform in [
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.fuchsia,
    ]) {
      test('is false on ${platform.name}', () {
        debugDefaultTargetPlatformOverride = platform;
        expect(PhoneGate.isMobile, isFalse);
      });
    }
  });

  group('PhoneGate.minSupportedShortestSide', () {
    test('is 600 logical pixels (Android sw600dp tablet threshold)', () {
      expect(PhoneGate.minSupportedShortestSide, 600);
    });
  });

  group('PhoneGate.isUnsupportedPhone', () {
    group('on a mobile device', () {
      setUp(() {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
      });

      test('blocks a normal phone in portrait', () {
        expect(PhoneGate.isUnsupportedPhone(_phonePortrait), isTrue);
      });

      test('blocks a normal phone in landscape', () {
        expect(PhoneGate.isUnsupportedPhone(_phoneLandscape), isTrue);
      });

      test('allows a tablet', () {
        expect(PhoneGate.isUnsupportedPhone(_tablet), isFalse);
      });

      test('allows an unfolded foldable', () {
        expect(PhoneGate.isUnsupportedPhone(_unfoldedFoldable), isFalse);
      });

      test('treats a shortest side of exactly 600 as supported', () {
        expect(
          PhoneGate.isUnsupportedPhone(const Size(600, 900)),
          isFalse,
        );
      });

      test('treats a shortest side just under 600 as unsupported', () {
        expect(
          PhoneGate.isUnsupportedPhone(const Size(599.9, 900)),
          isTrue,
        );
      });

      test('gives the same answer in portrait and landscape', () {
        const portrait = Size(500, 900);
        const landscape = Size(900, 500);
        expect(
          PhoneGate.isUnsupportedPhone(portrait),
          PhoneGate.isUnsupportedPhone(landscape),
        );
      });
    });

    group('on a non-mobile platform', () {
      test('never blocks a small desktop window', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        expect(PhoneGate.isUnsupportedPhone(_tinyDesktopWindow), isFalse);
      });

      test('never blocks a small window on Windows', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        expect(PhoneGate.isUnsupportedPhone(_desktopWindow), isFalse);
        expect(PhoneGate.isUnsupportedPhone(_tinyDesktopWindow), isFalse);
      });
    });
  });

  group('PhoneGate widget', () {
    const childKey = Key('app-child');
    const child = SizedBox(key: childKey, child: Text('app'));

    Widget gate(Size size) => Directionality(
          textDirection: TextDirection.ltr,
          child: PhoneGate(size: size, child: child),
        );

    // The foundation debug override must be cleared before testWidgets'
    // invariant checks run, so each widget test resets it in a finally block.
    Future<void> onPlatform(
      TargetPlatform platform,
      Future<void> Function() body,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await body();
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    }

    testWidgets('shows the app on a tablet', (tester) async {
      await onPlatform(TargetPlatform.android, () async {
        await tester.pumpWidget(gate(_tablet));

        expect(find.byKey(childKey), findsOneWidget);
        expect(find.byType(UnsupportedDevicePage), findsNothing);
      });
    });

    testWidgets('shows the unsupported page on a phone', (tester) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await tester.pumpWidget(gate(_phonePortrait));

        expect(find.byType(UnsupportedDevicePage), findsOneWidget);
        expect(find.byKey(childKey), findsNothing);
      });
    });

    testWidgets('shows the app on desktop even when the window is small',
        (tester) async {
      await onPlatform(TargetPlatform.macOS, () async {
        await tester.pumpWidget(gate(_tinyDesktopWindow));

        expect(find.byKey(childKey), findsOneWidget);
        expect(find.byType(UnsupportedDevicePage), findsNothing);
      });
    });

    testWidgets('switches to the app when a phone is unfolded',
        (tester) async {
      await onPlatform(TargetPlatform.android, () async {
        await tester.pumpWidget(gate(_phonePortrait));
        expect(find.byType(UnsupportedDevicePage), findsOneWidget);

        await tester.pumpWidget(gate(_unfoldedFoldable));
        expect(find.byType(UnsupportedDevicePage), findsNothing);
        expect(find.byKey(childKey), findsOneWidget);
      });
    });

    testWidgets('switches back to the unsupported page when a foldable closes',
        (tester) async {
      await onPlatform(TargetPlatform.android, () async {
        await tester.pumpWidget(gate(_unfoldedFoldable));
        expect(find.byKey(childKey), findsOneWidget);

        await tester.pumpWidget(gate(_phonePortrait));
        expect(find.byType(UnsupportedDevicePage), findsOneWidget);
        expect(find.byKey(childKey), findsNothing);
      });
    });
  });
}
