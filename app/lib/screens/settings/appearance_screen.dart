import 'package:anitrack/utils/app_colors.dart';
import 'package:anitrack/utils/appearance_provider.dart';
import 'package:anitrack/utils/appearance_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final appearance = ref.watch(appearanceProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back, color: colors.iconMuted),
                  ),
                  Expanded(
                    child: Text(
                      'Appearance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.accent,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Theme',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 208,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _ThemeCard(
                      title: 'KOMORI',
                      style: AppStyle.komori,
                      isSelected: appearance.style == AppStyle.komori,
                      onTap: () => ref
                          .read(appearanceProvider.notifier)
                          .setStyle(AppStyle.komori),
                    ),
                    const SizedBox(width: 12),
                    _ThemeCard(
                      title: 'ANILIST',
                      style: AppStyle.anilist,
                      isSelected: appearance.style == AppStyle.anilist,
                      onTap: () => ref
                          .read(appearanceProvider.notifier)
                          .setStyle(AppStyle.anilist),
                    ),
                    const SizedBox(width: 12),
                    _ThemeCard(
                      title: 'CRIMSON',
                      style: AppStyle.crimson,
                      isSelected: appearance.style == AppStyle.crimson,
                      onTap: () => ref
                          .read(appearanceProvider.notifier)
                          .setStyle(AppStyle.crimson),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Theme mode',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      label: 'Dark',
                      selected: appearance.themeMode == ThemeMode.dark,
                      onTap: () => ref
                          .read(appearanceProvider.notifier)
                          .setThemeMode(ThemeMode.dark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ModeButton(
                      label: 'Light',
                      selected: appearance.themeMode == ThemeMode.light,
                      onTap: () => ref
                          .read(appearanceProvider.notifier)
                          .setThemeMode(ThemeMode.light),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _ModeButton(
                      label: 'Follow System',
                      selected: appearance.themeMode == ThemeMode.system,
                      onTap: () => ref
                          .read(appearanceProvider.notifier)
                          .setThemeMode(ThemeMode.system),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'App font scale',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${(appearance.fontScale * 100).round()}%',
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _ScaleIconButton(
                    icon: Icons.zoom_out_map,
                    onTap: () {
                      ref
                          .read(appearanceProvider.notifier)
                          .setFontScale(appearance.fontScale - 0.05);
                    },
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        activeTrackColor: colors.accent,
                        inactiveTrackColor: colors.divider,
                        thumbColor: colors.accent,
                        overlayColor: colors.accent.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: appearance.fontScale,
                        min: 0.8,
                        max: 1.4,
                        divisions: 12,
                        onChanged: (value) {
                          ref
                              .read(appearanceProvider.notifier)
                              .setFontScale(value);
                        },
                      ),
                    ),
                  ),
                  _ScaleIconButton(
                    icon: Icons.zoom_in_map,
                    onTap: () {
                      ref
                          .read(appearanceProvider.notifier)
                          .setFontScale(appearance.fontScale + 0.05);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 48,
        decoration: BoxDecoration(
          color: selected ? colors.accent : colors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.actionText : colors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ScaleIconButton extends StatelessWidget {
  const _ScaleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: colors.accent),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.title,
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final AppStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final palette = AppThemeFactory.paletteFor(
      style,
      isDarkMode ? Brightness.dark : Brightness.light,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 178,
            height: 144,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? palette.accent : palette.divider,
                width: isSelected ? 4 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          margin: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: palette.background,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 6,
                                width: 70,
                                decoration: BoxDecoration(
                                  color:
                                      palette.textMuted.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 6,
                                width: 36,
                                decoration: BoxDecoration(
                                  color:
                                      palette.textMuted.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int i = 0; i < 4; i++)
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: i == 1
                                ? palette.accent
                                : palette.textMuted.withValues(alpha: 0.75),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: palette.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

