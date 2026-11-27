import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:phone_gate/src/unsupported_device_page.dart';

/// Blocks the app on normal-sized phones and lets everything else through.
///
/// Wrap the app's root (or any screen) in a [PhoneGate]. When the app runs on
/// iOS or Android and the screen's shortest side is below
/// [minSupportedShortestSide], it shows [UnsupportedDevicePage] in place of
/// [child]. Tablets, unfolded foldables, desktop and web always get [child].
///
/// ```dart
/// PhoneGate(
///   size: MediaQuery.sizeOf(context),
///   child: const HomePage(),
/// )
/// ```
class PhoneGate extends StatelessWidget {
  /// Whether the app is running on a mobile platform (iOS or Android).
  ///
  /// Only mobile platforms are gated. Desktop and web are never blocked,
  /// however small the window is.
  static bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  /// Smallest screen side (in logical pixels) that a mobile device needs to
  /// run the app.
  ///
  /// Matches Android's "tablet" threshold (sw600dp): unfolded foldables and
  /// tablets are at or above it, normal phones are below it.
  static const double minSupportedShortestSide = 600;

  /// Whether the app should be blocked for a screen of the given [size].
  ///
  /// True only on a mobile device whose shortest side is below
  /// [minSupportedShortestSide], meaning a normal phone. Using the shortest
  /// side makes the result the same in portrait and landscape, so rotating a
  /// phone sideways doesn't get it past the gate.
  static bool isUnsupportedPhone(Size size) =>
      isMobile && size.shortestSide < minSupportedShortestSide;

  /// Creates a gate that shows [child] unless [size] belongs to a phone.
  const PhoneGate({super.key, required this.size, required this.child});

  /// The current screen size in logical pixels, usually from
  /// `MediaQuery.sizeOf(context)`.
  ///
  /// It's passed in, not read inside the widget, so the gate is easy to test
  /// with any size you like.
  final Size size;

  /// The widget to show when the device is supported.
  final Widget child;

  /// Shows [UnsupportedDevicePage] on a phone, otherwise [child].
  ///
  /// The decision is made again on every rebuild. If you pass a fresh
  /// [size] from `MediaQuery`, the gate updates on its own when a foldable
  /// is opened or closed.
  @override
  Widget build(BuildContext context) =>
      isUnsupportedPhone(size) ? const UnsupportedDevicePage() : child;
}
