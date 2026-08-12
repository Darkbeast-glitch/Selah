import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens from `selah_scripture_companion/selah/DESIGN.md`.
///
/// Selah uses a deliberate dual-font strategy (PRD §32):
///
/// * **EB Garamond** (serif) — Scripture text, references, headings, and major
///   reflective moments. Lends authority and timelessness to the Word.
/// * **Manrope** (sans) — navigation, buttons, labels, settings, body copy.
///
/// Scripture must always read as visually distinct from AI-generated text.
/// Never set a verse in Manrope, and never set interface chrome in Garamond.
abstract final class AppTypography {
  static TextStyle _serif(TextStyle style) => GoogleFonts.ebGaramond(
    fontSize: style.fontSize,
    fontWeight: style.fontWeight,
    height: style.height,
    letterSpacing: style.letterSpacing,
  );

  static TextStyle _sans(TextStyle style) => GoogleFonts.manrope(
    fontSize: style.fontSize,
    fontWeight: style.fontWeight,
    height: style.height,
    letterSpacing: style.letterSpacing,
  );

  /// 32/44 — verse-of-the-day and hero Scripture. Generous line height keeps
  /// the reading pace meditative.
  static TextStyle get displayScripture => _serif(
    const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      height: 44 / 32,
      letterSpacing: -0.32,
    ),
  );

  /// 26/36 — the same role on narrow screens.
  static TextStyle get displayScriptureMobile => _serif(
    const TextStyle(fontSize: 26, fontWeight: FontWeight.w500, height: 36 / 26),
  );

  /// 28/36 — screen titles ("Explore Scripture", "Your Library", "Reflect").
  static TextStyle get h1 => _serif(
    const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 36 / 28),
  );

  /// 22/30 — card headings and section titles.
  static TextStyle get h2 => _serif(
    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, height: 30 / 22),
  );

  /// 18/28 — primary reading body, AI explanation text.
  static TextStyle get bodyLg => _sans(
    const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, height: 28 / 18),
  );

  /// 16/24 — default interface body.
  static TextStyle get bodyMd => _sans(
    const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16),
  );

  /// 12/16 uppercase, tracked — section eyebrows ("SCRIPTURE", "REFLECT") and
  /// Scripture references. Always render with uppercase text.
  static TextStyle get labelCaps => _sans(
    const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 16 / 12,
      letterSpacing: 0.96,
    ),
  );

  /// 11/14 — bottom navigation labels.
  static TextStyle get navLabel => _sans(
    const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 14 / 11),
  );

  /// Maps the design tokens onto Material's [TextTheme] slots so stock widgets
  /// inherit the right font without per-widget overrides.
  ///
  /// Slot mapping — use the named getters above when the intent matters:
  /// * displayLarge/Medium → displayScripture / displayScriptureMobile
  /// * headlineLarge/Medium → h1 / h2
  /// * bodyLarge/Medium → bodyLg / bodyMd
  /// * labelSmall → labelCaps, labelMedium → navLabel
  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      displayLarge: displayScripture.copyWith(color: onSurface),
      displayMedium: displayScriptureMobile.copyWith(color: onSurface),
      headlineLarge: h1.copyWith(color: onSurface),
      headlineMedium: h2.copyWith(color: onSurface),
      titleLarge: h2.copyWith(color: onSurface),
      bodyLarge: bodyLg.copyWith(color: onSurface),
      bodyMedium: bodyMd.copyWith(color: onSurface),
      bodySmall: bodyMd.copyWith(fontSize: 14, color: onSurfaceVariant),
      labelLarge: bodyMd.copyWith(fontWeight: FontWeight.w600, color: onSurface),
      labelMedium: navLabel.copyWith(color: onSurfaceVariant),
      labelSmall: labelCaps.copyWith(color: onSurfaceVariant),
    );
  }
}
