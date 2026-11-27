import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

/// Shown instead of the app on phones whose screen is too narrow for the
/// course layout (for example, a normal, non-folding phone).
///
/// Foldables unfolded and tablets are wide enough, so they never see this page.
class UnsupportedDevicePage extends StatelessWidget {
  const UnsupportedDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // This page is shown before the app's normal UI is available, so it
    // forces LTR and a fixed dark background instead of relying on the
    // app theme or the locale.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        // Fixed dark background so the message is readable regardless of
        // the system or app theme.
        color: const Color(0xFF1B1B1E),
        // SafeArea keeps the content clear of notches, status bars and
        // rounded corners on the phone.
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                // Shrink to the content so the message stays centred
                // rather than stretching to fill the screen.
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Visual cue that the problem is the device, not the app.
                  const Icon(
                    Icons.devices_rounded,
                    size: 64,
                    color: Colors.orangeAccent,
                  ),
                  const Gap(24),
                  Text(
                    'This app requires a bigger screen',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(12),
                  // Instruction for the user on what to do next.
                  Text(
                    'Open it on a tablet or on a foldable phone that is unfolded.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      // Slightly dimmed so the subtitle sits below the heading.
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
