import 'package:flutter/widgets.dart';

/// Spacing, radius, and elevation tokens from
/// `selah_scripture_companion/selah/DESIGN.md`.
///
/// The layout is built on an 8px vertical rhythm with wide margins. Section
/// gaps (40px+) separate different *kinds* of content — Scripture vs. AI
/// reflection — to signal a change in mental context.
abstract final class AppSpacing {
  /// Base rhythm unit. Prefer multiples of this over arbitrary values.
  static const double unit = 8;

  /// Horizontal page padding. Never let content touch the screen edge.
  static const double containerMargin = 24;

  /// Gap between items inside a row/grid.
  static const double gutter = 16;

  /// Gap between distinct content sections. Use liberally.
  static const double sectionGap = 40;

  static const double stackSm = 8;
  static const double stackMd = 16;
  static const double stackLg = 24;

  /// Standard page padding: 24px sides, generous bottom for the nav bar.
  static const pagePadding = EdgeInsets.symmetric(horizontal: containerMargin);
}

/// Corner radii. The shape language is organic and soft: cards are 16px,
/// interactive elements are 24px or fully rounded to signal touchability.
abstract final class AppRadius {
  static const double sm = 4;
  static const double base = 8;
  static const double md = 12;

  /// Standard for cards and containers.
  static const double lg = 16;

  /// Buttons, inputs, and other interactive surfaces.
  static const double xl = 24;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius interactiveRadius = BorderRadius.all(
    Radius.circular(xl),
  );
  static const BorderRadius pill = BorderRadius.all(Radius.circular(9999));
}

/// Depth is communicated through tonal layers, not aggressive shadows.
///
/// * Level 0 — main background
/// * Level 1 — topic cards, list items (1px border or tonal shift, no shadow)
/// * Level 2 — Scripture cards, active modals (ambient shadow)
abstract final class AppElevation {
  /// Extremely diffused, low-opacity, green-tinted shadow for level 2.
  /// Pass [SelahColors.ambientShadow] as [tint].
  static List<BoxShadow> ambient(Color tint) => [
    BoxShadow(
      color: tint.withValues(alpha: 0.06),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: tint.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];
}

/// Motion tokens. The app's rhythm is unhurried — transitions should feel like
/// a breath, never snappy or bouncy.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 520);
  static const Curve curve = Curves.easeOutCubic;
}
