import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_gate/src/unsupported_device_page.dart';

const _heading = 'This app requires a bigger screen';
const _instruction =
    'Open it on a tablet or on a foldable phone that is unfolded.';

Future<void> _pumpPage(WidgetTester tester, {Size? size}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size ?? const Size(390, 844)),
        child: const UnsupportedDevicePage(),
      ),
    ),
  );
}

void main() {
  group('UnsupportedDevicePage', () {
    testWidgets('shows the heading', (tester) async {
      await _pumpPage(tester);

      expect(find.text(_heading), findsOneWidget);
    });

    testWidgets('shows the instruction for the user', (tester) async {
      await _pumpPage(tester);

      expect(find.text(_instruction), findsOneWidget);
    });

    testWidgets('shows the device icon', (tester) async {
      await _pumpPage(tester);

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.devices_rounded);
      expect(icon.size, 64);
      // Compare ARGB values: the page's colour and this test's Colors can
      // come from different library copies, so identity checks are unreliable.
      expect(icon.color?.toARGB32(), Colors.orangeAccent.toARGB32());
    });

    testWidgets('uses a fixed dark background', (tester) async {
      await _pumpPage(tester);

      final box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(UnsupportedDevicePage),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(box.color, const Color(0xFF1B1B1E));
    });

    testWidgets('forces left-to-right text direction', (tester) async {
      // Wrap in an RTL parent to prove the page overrides it.
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: MediaQuery(
              data: const MediaQueryData(size: Size(390, 844)),
              child: const UnsupportedDevicePage(),
            ),
          ),
        ),
      );

      final direction = tester.widget<Directionality>(
        find.descendant(
          of: find.byType(UnsupportedDevicePage),
          matching: find.byType(Directionality),
        ),
      );
      expect(direction.textDirection, TextDirection.ltr);
    });

    testWidgets('wraps its content in a SafeArea', (tester) async {
      await _pumpPage(tester);

      expect(
        find.descendant(
          of: find.byType(UnsupportedDevicePage),
          matching: find.byType(SafeArea),
        ),
        findsOneWidget,
      );
    });

    testWidgets('centres the content', (tester) async {
      await _pumpPage(tester);

      expect(
        find.descendant(
          of: find.byType(UnsupportedDevicePage),
          matching: find.byType(Center),
        ),
        findsWidgets,
      );
    });

    testWidgets('lays out without overflow on a small phone', (tester) async {
      await _pumpPage(tester, size: const Size(320, 568));

      expect(tester.takeException(), isNull);
      expect(find.text(_heading), findsOneWidget);
    });

    testWidgets('lays out without overflow on a large text scale',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(2.0),
            ),
            child: const UnsupportedDevicePage(),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(_heading), findsOneWidget);
    });
  });
}
