import 'package:flutter/material.dart';

/// Raw colour tokens for Selah, ported verbatim from the design system at
/// `selah_scripture_companion/selah/DESIGN.md`.
///
/// Widgets should NOT reference this class directly. Read colours from
/// `Theme.of(context).colorScheme` (or the [SelahColors] theme extension for
/// the tokens Material 3 has no slot for) so light/dark switching is automatic.
abstract final class AppColors {
  // ---------------------------------------------------------------- light ---
  static const lightSurface = Color(0xFFFCF9F8);
  static const lightSurfaceDim = Color(0xFFDCD9D9);
  static const lightSurfaceBright = Color(0xFFFCF9F8);
  static const lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const lightSurfaceContainerLow = Color(0xFFF6F3F2);
  static const lightSurfaceContainer = Color(0xFFF0EDED);
  static const lightSurfaceContainerHigh = Color(0xFFEAE7E7);
  static const lightSurfaceContainerHighest = Color(0xFFE5E2E1);
  static const lightOnSurface = Color(0xFF1C1B1B);
  static const lightOnSurfaceVariant = Color(0xFF444842);
  static const lightInverseSurface = Color(0xFF313030);
  static const lightInverseOnSurface = Color(0xFFF3F0EF);
  static const lightOutline = Color(0xFF747872);
  static const lightOutlineVariant = Color(0xFFC4C8C0);
  static const lightSurfaceTint = Color(0xFF546253);

  static const lightPrimary = Color(0xFF283528);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFF3E4C3E);
  static const lightOnPrimaryContainer = Color(0xFFACBCAA);
  static const lightInversePrimary = Color(0xFFBBCBB9);

  static const lightSecondary = Color(0xFF5F5E58);
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightSecondaryContainer = Color(0xFFE5E2DA);
  static const lightOnSecondaryContainer = Color(0xFF65645E);

  static const lightTertiary = Color(0xFF432F00);
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightTertiaryContainer = Color(0xFF5F4402);
  static const lightOnTertiaryContainer = Color(0xFFD9B269);

  static const lightError = Color(0xFFBA1A1A);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFDAD6);
  static const lightOnErrorContainer = Color(0xFF93000A);

  // ----------------------------------------------------------------- dark ---
  // The design reference reuses the same token names under `dark:` (Material 3
  // "fixed" roles are mode-invariant), so the dark scheme below is derived from
  // the light scheme's inverse tokens per PRD §31: "deep charcoal/green-black
  // background, warm light text".
  static const darkSurface = Color(0xFF141313);
  static const darkSurfaceDim = Color(0xFF141313);
  static const darkSurfaceBright = Color(0xFF3A3939);
  static const darkSurfaceContainerLowest = Color(0xFF0E0F0E);
  static const darkSurfaceContainerLow = Color(0xFF1C1B1B);
  static const darkSurfaceContainer = Color(0xFF201F1F);
  static const darkSurfaceContainerHigh = Color(0xFF2B2A2A);
  static const darkSurfaceContainerHighest = Color(0xFF363535);
  static const darkOnSurface = Color(0xFFE5E2E1);
  static const darkOnSurfaceVariant = Color(0xFFC4C8C0);
  static const darkInverseSurface = Color(0xFFE5E2E1);
  static const darkInverseOnSurface = Color(0xFF313030);
  static const darkOutline = Color(0xFF8E928C);
  static const darkOutlineVariant = Color(0xFF444842);
  static const darkSurfaceTint = Color(0xFFBBCBB9);

  static const darkPrimary = Color(0xFFBBCBB9);
  static const darkOnPrimary = Color(0xFF263425);
  static const darkPrimaryContainer = Color(0xFF3E4C3E);
  static const darkOnPrimaryContainer = Color(0xFFD7E7D4);
  static const darkInversePrimary = Color(0xFF283528);

  static const darkSecondary = Color(0xFFC9C6BF);
  static const darkOnSecondary = Color(0xFF31312C);
  static const darkSecondaryContainer = Color(0xFF474741);
  static const darkOnSecondaryContainer = Color(0xFFE5E2DA);

  static const darkTertiary = Color(0xFFE9C176);
  static const darkOnTertiary = Color(0xFF3F2E00);
  static const darkTertiaryContainer = Color(0xFF5F4402);
  static const darkOnTertiaryContainer = Color(0xFFFFDEA5);

  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);

  // ---------------------------------------------------------------- fixed ---
  // Mode-invariant accent tokens. The design uses these for Scripture
  // ornaments and prayer/reflection surfaces in both light and dark.
  static const primaryFixed = Color(0xFFD7E7D4);
  static const primaryFixedDim = Color(0xFFBBCBB9);
  static const onPrimaryFixed = Color(0xFF121F13);
  static const onPrimaryFixedVariant = Color(0xFF3C4A3C);

  static const secondaryFixed = Color(0xFFE5E2DA);
  static const secondaryFixedDim = Color(0xFFC9C6BF);
  static const onSecondaryFixed = Color(0xFF1C1C17);
  static const onSecondaryFixedVariant = Color(0xFF474741);

  static const tertiaryFixed = Color(0xFFFFDEA5);
  static const tertiaryFixedDim = Color(0xFFE9C176);
  static const onTertiaryFixed = Color(0xFF261900);
  static const onTertiaryFixedVariant = Color(0xFF5D4201);
}

/// Design tokens that Material 3's [ColorScheme] has no slot for.
///
/// Access with `Theme.of(context).extension<SelahColors>()!` — or the
/// `context.selahColors` shorthand in `app_theme.dart`.
@immutable
class SelahColors extends ThemeExtension<SelahColors> {
  const SelahColors({
    required this.primaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixed,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixed,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixed,
    required this.onTertiaryFixedVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.ambientShadow,
  });

  final Color primaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixed;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixed;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixed;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;

  /// Green-tinted ambient shadow colour. DESIGN.md: 20–40px blur at 5–8%
  /// opacity, tinted with the primary forest green — never neutral grey.
  final Color ambientShadow;

  static const light = SelahColors(
    primaryFixed: AppColors.primaryFixed,
    primaryFixedDim: AppColors.primaryFixedDim,
    onPrimaryFixed: AppColors.onPrimaryFixed,
    onPrimaryFixedVariant: AppColors.onPrimaryFixedVariant,
    secondaryFixed: AppColors.secondaryFixed,
    secondaryFixedDim: AppColors.secondaryFixedDim,
    onSecondaryFixed: AppColors.onSecondaryFixed,
    onSecondaryFixedVariant: AppColors.onSecondaryFixedVariant,
    tertiaryFixed: AppColors.tertiaryFixed,
    tertiaryFixedDim: AppColors.tertiaryFixedDim,
    onTertiaryFixed: AppColors.onTertiaryFixed,
    onTertiaryFixedVariant: AppColors.onTertiaryFixedVariant,
    surfaceDim: AppColors.lightSurfaceDim,
    surfaceBright: AppColors.lightSurfaceBright,
    ambientShadow: AppColors.lightSurfaceTint,
  );

  static const dark = SelahColors(
    primaryFixed: AppColors.primaryFixed,
    primaryFixedDim: AppColors.primaryFixedDim,
    onPrimaryFixed: AppColors.onPrimaryFixed,
    onPrimaryFixedVariant: AppColors.onPrimaryFixedVariant,
    secondaryFixed: AppColors.secondaryFixed,
    secondaryFixedDim: AppColors.secondaryFixedDim,
    onSecondaryFixed: AppColors.onSecondaryFixed,
    onSecondaryFixedVariant: AppColors.onSecondaryFixedVariant,
    tertiaryFixed: AppColors.tertiaryFixed,
    tertiaryFixedDim: AppColors.tertiaryFixedDim,
    onTertiaryFixed: AppColors.onTertiaryFixed,
    onTertiaryFixedVariant: AppColors.onTertiaryFixedVariant,
    surfaceDim: AppColors.darkSurfaceDim,
    surfaceBright: AppColors.darkSurfaceBright,
    ambientShadow: Color(0xFF000000),
  );

  @override
  SelahColors copyWith({
    Color? primaryFixed,
    Color? primaryFixedDim,
    Color? onPrimaryFixed,
    Color? onPrimaryFixedVariant,
    Color? secondaryFixed,
    Color? secondaryFixedDim,
    Color? onSecondaryFixed,
    Color? onSecondaryFixedVariant,
    Color? tertiaryFixed,
    Color? tertiaryFixedDim,
    Color? onTertiaryFixed,
    Color? onTertiaryFixedVariant,
    Color? surfaceDim,
    Color? surfaceBright,
    Color? ambientShadow,
  }) {
    return SelahColors(
      primaryFixed: primaryFixed ?? this.primaryFixed,
      primaryFixedDim: primaryFixedDim ?? this.primaryFixedDim,
      onPrimaryFixed: onPrimaryFixed ?? this.onPrimaryFixed,
      onPrimaryFixedVariant:
          onPrimaryFixedVariant ?? this.onPrimaryFixedVariant,
      secondaryFixed: secondaryFixed ?? this.secondaryFixed,
      secondaryFixedDim: secondaryFixedDim ?? this.secondaryFixedDim,
      onSecondaryFixed: onSecondaryFixed ?? this.onSecondaryFixed,
      onSecondaryFixedVariant:
          onSecondaryFixedVariant ?? this.onSecondaryFixedVariant,
      tertiaryFixed: tertiaryFixed ?? this.tertiaryFixed,
      tertiaryFixedDim: tertiaryFixedDim ?? this.tertiaryFixedDim,
      onTertiaryFixed: onTertiaryFixed ?? this.onTertiaryFixed,
      onTertiaryFixedVariant:
          onTertiaryFixedVariant ?? this.onTertiaryFixedVariant,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      ambientShadow: ambientShadow ?? this.ambientShadow,
    );
  }

  @override
  SelahColors lerp(SelahColors? other, double t) {
    if (other == null) return this;
    return SelahColors(
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      primaryFixedDim: Color.lerp(primaryFixedDim, other.primaryFixedDim, t)!,
      onPrimaryFixed: Color.lerp(onPrimaryFixed, other.onPrimaryFixed, t)!,
      onPrimaryFixedVariant:
          Color.lerp(onPrimaryFixedVariant, other.onPrimaryFixedVariant, t)!,
      secondaryFixed: Color.lerp(secondaryFixed, other.secondaryFixed, t)!,
      secondaryFixedDim:
          Color.lerp(secondaryFixedDim, other.secondaryFixedDim, t)!,
      onSecondaryFixed:
          Color.lerp(onSecondaryFixed, other.onSecondaryFixed, t)!,
      onSecondaryFixedVariant: Color.lerp(
        onSecondaryFixedVariant,
        other.onSecondaryFixedVariant,
        t,
      )!,
      tertiaryFixed: Color.lerp(tertiaryFixed, other.tertiaryFixed, t)!,
      tertiaryFixedDim:
          Color.lerp(tertiaryFixedDim, other.tertiaryFixedDim, t)!,
      onTertiaryFixed: Color.lerp(onTertiaryFixed, other.onTertiaryFixed, t)!,
      onTertiaryFixedVariant: Color.lerp(
        onTertiaryFixedVariant,
        other.onTertiaryFixedVariant,
        t,
      )!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      ambientShadow: Color.lerp(ambientShadow, other.ambientShadow, t)!,
    );
  }
}
