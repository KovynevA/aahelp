import 'dart:math' as math;

import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }

    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _openUrl(String value) async {
    await launchUrl(Uri.parse(value));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 980;
    final cardWidth = isWide ? 260.0 : math.max(240.0, screenWidth - 32);
    final palette = context.appPalette;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        AppPanel(
          gradient: LinearGradient(
            colors: [
              palette.heroStart.withValues(alpha: 0.92),
              palette.heroEnd.withValues(alpha: 0.92),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Настройки интерфейса',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: palette.isDark
                          ? Colors.white
                          : const Color(0xFF132A39),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Темы теперь живут отдельно и не занимают место на рабочих экранах. Здесь можно спокойно выбрать визуальный стиль приложения.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: palette.isDark
                          ? Colors.white.withValues(alpha: 0.92)
                          : const Color(0xFF163240),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<AppThemePreset>(
          valueListenable: AppThemeController.instance,
          builder: (context, selectedPreset, _) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppThemePreset.values.map((preset) {
                final previewPalette = themePaletteForPreset(preset);
                final isSelected = preset == selectedPreset;

                return SizedBox(
                  width: cardWidth,
                  child: AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    preset.label,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    preset.subtitle,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: previewPalette.accentSoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  color: previewPalette.accent,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _ThemeSwatch(color: previewPalette.backgroundTop),
                            const SizedBox(width: 8),
                            _ThemeSwatch(color: previewPalette.surface),
                            const SizedBox(width: 8),
                            _ThemeSwatch(color: previewPalette.accent),
                            const SizedBox(width: 8),
                            _ThemeSwatch(color: previewPalette.heroEnd),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: isSelected
                              ? FilledButton.tonalIcon(
                                  onPressed: null,
                                  icon: const Icon(Icons.check_rounded),
                                  label: const Text('Тема активна'),
                                )
                              : FilledButton(
                                  onPressed: () =>
                                      AppThemeController.instance.setPreset(
                                    preset,
                                  ),
                                  child: const Text('Применить'),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'О приложении',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _appVersion.isEmpty
                    ? 'AA Help'
                    : 'AA Help $_appVersion',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Некоммерческое приложение для поиска групп АА и поддержки ежедневной практики.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => _openUrl('https://t.me/app_aahelper'),
                    icon: const Icon(Icons.telegram),
                    label: const Text('Telegram'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        _openUrl('mailto:kovynevandrei@gmail.com'),
                    icon: const Icon(Icons.mail_outline_rounded),
                    label: const Text('Email'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        _openUrl('https://github.com/KovynevA/aahelp'),
                    icon: const Icon(Icons.code_rounded),
                    label: const Text('GitHub'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}
