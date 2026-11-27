# phone_gate

A small Flutter package that keeps your app off normal-size phones. Wrap your app in `PhoneGate` and, on an iOS or Android device whose shortest screen side is under 600 logical pixels, users see a "This app requires a bigger screen" page instead of your UI. Tablets, unfolded foldables and desktop get the app as usual.

It's meant for apps whose layout only works on large screens, such as a two-column course or editor UI that you don't want to squeeze onto a phone.

## Features

- **One-widget gate**: wrap the root (or any screen) in `PhoneGate` and pass the current screen size.
- **Tablet threshold built in**: blocks mobile devices whose shortest side is below 600 logical pixels, the same cut-off Android uses for tablets (`sw600dp`).
- **Rotation-proof**: uses the screen's *shortest* side, so turning a phone sideways doesn't get it past the gate.
- **Foldable-aware**: the check runs on every rebuild, so a foldable switches between the blocked page and the app as it's folded and unfolded.
- **Desktop is never blocked**: on macOS, Windows and Linux the app shows however small the window is.
- **Ready-made blocked page**: `UnsupportedDevicePage` shows a dark, centred message with a devices icon, telling users to open the app on a tablet or an unfolded foldable. It doesn't depend on your app's theme or locale.
- **Testable helpers**: `PhoneGate.isMobile` and `PhoneGate.isUnsupportedPhone(size)` are static, so you can reuse the same rule elsewhere.

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:phone_gate/phone_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => PhoneGate(
          size: MediaQuery.sizeOf(context),
          child: const HomePage(),
        ),
      ),
    );
  }
}
```

The size is passed in rather than read inside the widget, which keeps the gate easy to test with any size you like. Passing `MediaQuery.sizeOf(context)` means the gate updates by itself when the screen changes.

You can also use the rule directly:

```dart
if (PhoneGate.isUnsupportedPhone(MediaQuery.sizeOf(context))) {
  // e.g. hide a feature, log analytics, etc.
}
```

## How it works

```
lib/
├── phone_gate.dart                    # PhoneGate widget and its static helpers
└── src/
    └── unsupported_device_page.dart   # Page shown on blocked phones
```

- `PhoneGate.isMobile` is true when `defaultTargetPlatform` is iOS or Android.
- `PhoneGate.isUnsupportedPhone(size)` is true when `isMobile` and `size.shortestSide < PhoneGate.minSupportedShortestSide` (600).
- `PhoneGate.build` returns `UnsupportedDevicePage` when that's true, otherwise `child`.

| Device | Example size (logical px) | Result |
| --- | --- | --- |
| Phone, portrait | 390 × 844 | Blocked |
| Phone, landscape | 844 × 390 | Blocked |
| Unfolded foldable | 713 × 848 | App |
| Tablet | 800 × 1280 | App |
| Desktop window, any size | 320 × 480 | App |

## Installation

The package isn't on pub.dev. Add it as a Git dependency in your app's `pubspec.yaml`:

```yaml
dependencies:
  phone_gate:
    git:
      url: https://github.com/trey-a-hope/phone-gate.git
      ref: main
```

Then run `flutter pub get`.

### Requirements

- Dart SDK `^3.14.0`
- Flutter `>=1.17.0`
- Dependencies pulled in by the package: [`gap`](https://pub.dev/packages/gap) and [`material_ui`](https://pub.dev/packages/material_ui), both used by the blocked page.

## Testing

```bash
flutter pub get
flutter test
```

`test/phone_gate_test.dart` covers the platform check, the 600 px threshold (including the exact boundary), portrait vs landscape, and the widget switching between `child` and the blocked page. `test/unsupported_device_page_test.dart` covers the blocked page itself.

## Known limitations

- **Mobile web is gated too.** On web, Flutter's `defaultTargetPlatform` reports the browser's operating system, so a Flutter web app opened in a phone browser counts as iOS or Android and is blocked like the native app.
- **The threshold and the blocked page aren't configurable yet.** `minSupportedShortestSide` is a constant, and `UnsupportedDevicePage` isn't exported from `package:phone_gate/phone_gate.dart` and has fixed English copy.

## License

No license has been chosen yet (`LICENSE` is still a placeholder).
