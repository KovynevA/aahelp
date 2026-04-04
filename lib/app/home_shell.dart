import 'package:aahelp/diary/diaryhtml.dart';
import 'package:aahelp/findgroup/findgroup.dart';
import 'package:aahelp/mysobriety/mysobriety.dart';
import 'package:aahelp/settings/settings_page.dart';
import 'package:aahelp/stepandtraditions/step.dart';
import 'package:aahelp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum HomeSection {
  groups,
  diary,
  principles,
  sobriety,
  settings,
}

extension HomeSectionPresentation on HomeSection {
  String get title {
    switch (this) {
      case HomeSection.groups:
        return 'Группы АА';
      case HomeSection.diary:
        return 'Ежедневник';
      case HomeSection.principles:
        return '12 шагов и традиций';
      case HomeSection.sobriety:
        return 'Моя трезвость';
      case HomeSection.settings:
        return 'Настройки';
    }
  }

  String get compactTitle {
    switch (this) {
      case HomeSection.groups:
        return 'Карта';
      case HomeSection.diary:
        return 'Дневник';
      case HomeSection.principles:
        return '12х12';
      case HomeSection.sobriety:
        return 'Трезвость';
      case HomeSection.settings:
        return 'Настройки';
    }
  }

  String get navigationLabel {
    switch (this) {
      case HomeSection.groups:
        return 'Карта';
      case HomeSection.diary:
        return 'Дневник';
      case HomeSection.principles:
        return '12х12';
      case HomeSection.sobriety:
        return 'Трезвость';
      case HomeSection.settings:
        return 'Ещё';
    }
  }

  String get subtitle {
    switch (this) {
      case HomeSection.groups:
        return 'Поиск по карте, районам, метро и адресу';
      case HomeSection.diary:
        return 'Текст на сегодня в спокойной, удобной подаче';
      case HomeSection.principles:
        return 'Краткие и полные тексты шагов и традиций';
      case HomeSection.sobriety:
        return 'Дата, срок трезвости и памятные даты';
      case HomeSection.settings:
        return 'Темы, внешний вид и информация о приложении';
    }
  }

  IconData get icon {
    switch (this) {
      case HomeSection.groups:
        return Icons.map_rounded;
      case HomeSection.diary:
        return Icons.menu_book_rounded;
      case HomeSection.principles:
        return Icons.auto_stories_rounded;
      case HomeSection.sobriety:
        return Icons.favorite_rounded;
      case HomeSection.settings:
        return Icons.tune_rounded;
    }
  }
}

class AaHomeShell extends StatefulWidget {
  const AaHomeShell({super.key});

  @override
  State<AaHomeShell> createState() => _AaHomeShellState();
}

class _AaHomeShellState extends State<AaHomeShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Widget> _pages = const <Widget>[
    FindGroup(),
    Diary(),
    StepAndTraditions(),
    MySobriety(),
    SettingsPage(),
  ];

  int _selectedIndex = 0;
  String _appVersion = '';

  HomeSection get _section => HomeSection.values[_selectedIndex];

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

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 1100;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: isWide
          ? null
          : Drawer(
              child: _SidebarContent(
                selectedIndex: _selectedIndex,
                onSelectIndex: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  Navigator.of(context).pop();
                },
                appVersion: _appVersion,
              ),
            ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              destinations: HomeSection.values
                  .map(
                    (section) => NavigationDestination(
                      icon: Icon(section.icon),
                      label: section.navigationLabel,
                    ),
                  )
                  .toList(),
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              palette.backgroundTop,
              palette.backgroundBottom,
            ],
          ),
        ),
        child: Stack(
          children: [
            const _BackdropShapes(),
            SafeArea(
              child: Row(
                children: [
                  if (isWide)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                      child: SizedBox(
                        width: 292,
                        child: _SidebarContent(
                          selectedIndex: _selectedIndex,
                          onSelectIndex: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          appVersion: _appVersion,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isWide ? 20 : 16,
                        16,
                        isWide ? 20 : 16,
                        0,
                      ),
                      child: Column(
                        children: [
                          _ShellHeader(
                            section: _section,
                            onMenuPressed: isWide
                                ? null
                                : () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: IndexedStack(
                              index: _selectedIndex,
                              children: _pages,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({
    required this.section,
    required this.onMenuPressed,
  });

  final HomeSection section;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.appPalette;
    final isCompact = MediaQuery.sizeOf(context).width < 700;
    final showSubtitle = MediaQuery.sizeOf(context).width >= 540;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: isCompact ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          if (onMenuPressed != null)
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu_rounded),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompact ? section.compactTitle : section.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: isCompact ? 20 : null,
                  ),
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 4),
                  Text(
                    section.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({
    required this.selectedIndex,
    required this.onSelectIndex,
    required this.appVersion,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.appPalette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: palette.border.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 26,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    palette.heroStart,
                    palette.heroEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AA Help',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: palette.isDark
                          ? Colors.white
                          : const Color(0xFF12202A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Рабочие разделы и настройки собраны в одном спокойном меню без лишних кнопок поверх контента.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.isDark
                          ? Colors.white.withValues(alpha: 0.9)
                          : const Color(0xFF17303F),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Разделы',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...List.generate(HomeSection.values.length, (index) {
              final section = HomeSection.values[index];
              final isSelected = index == selectedIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => onSelectIndex(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? palette.accentSoft
                          : palette.surfaceMuted.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected ? palette.accent : palette.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(section.icon),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                section.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            const Divider(height: 1),
            if (appVersion.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Версия $appVersion',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BackdropShapes extends StatelessWidget {
  const _BackdropShapes();

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    Widget bubble({
      required double size,
      required Alignment alignment,
      required Color color,
    }) {
      return Align(
        alignment: alignment,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        bubble(
          size: 420,
          alignment: const Alignment(-1.05, -0.95),
          color: palette.heroStart.withValues(alpha: 0.14),
        ),
        bubble(
          size: 360,
          alignment: const Alignment(1.1, -0.5),
          color: palette.heroEnd.withValues(alpha: 0.14),
        ),
        bubble(
          size: 520,
          alignment: const Alignment(0.6, 1.15),
          color: palette.accentSecondary.withValues(alpha: 0.10),
        ),
      ],
    );
  }
}
