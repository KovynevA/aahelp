import 'dart:io';

import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/helper/utils.dart';
import 'package:aahelp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class MySobriety extends StatelessWidget {
  const MySobriety({super.key});

  @override
  Widget build(BuildContext context) {
    return const MySobrietyWidget();
  }
}

class MySobrietyWidget extends StatefulWidget {
  const MySobrietyWidget({super.key});

  @override
  State<MySobrietyWidget> createState() => _MySobrietyWidgetState();
}

class _MySobrietyWidgetState extends State<MySobrietyWidget> {
  DateTime? sobrietyDate;
  SobrietyDuration? duration;
  List<String> anniversaries = <String>[];

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/date.txt');
  }

  Future<void> _saveDateToFile(DateTime date) async {
    final file = await _localFile;
    await file.writeAsString(date.toString());
  }

  Future<DateTime?> _loadDateFromFile() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return DateTime.parse(contents);
    } catch (_) {
      return null;
    }
  }

  Future<void> getUser() async {
    sobrietyDate = await _loadDateFromFile();
    if (!mounted) {
      return;
    }

    setState(() {
      duration = calculateSobrietyDuration();
      anniversaries = checkAnniversaries();
    });
  }

  Future<void> updateSobrietyDate(DateTime newDate) async {
    await _saveDateToFile(newDate);
    if (!mounted) {
      return;
    }

    setState(() {
      sobrietyDate = newDate;
      duration = calculateSobrietyDuration();
      anniversaries = checkAnniversaries();
    });
  }

  SobrietyDuration calculateSobrietyDuration() {
    if (sobrietyDate == null) {
      return SobrietyDuration();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sobrietyDay =
        DateTime(sobrietyDate!.year, sobrietyDate!.month, sobrietyDate!.day);

    var years = now.year - sobrietyDay.year;
    var months = now.month - sobrietyDay.month;
    var days = now.day - sobrietyDay.day;

    if (days < 0) {
      months--;
      final lastDayOfPrevMonth = DateTime(now.year, now.month, 0).day;
      days += lastDayOfPrevMonth;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return SobrietyDuration(
      years: years,
      months: months,
      days: days,
      totalDays: today.difference(sobrietyDay).inDays,
    );
  }

  List<String> checkAnniversaries() {
    if (sobrietyDate == null) {
      return <String>[];
    }

    final currentDuration = calculateSobrietyDuration();
    final result = <String>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sobrietyDay =
        DateTime(now.year, sobrietyDate!.month, sobrietyDate!.day);

    if (currentDuration.years > 0 && today == sobrietyDay) {
      result.add(
        '${currentDuration.years} ${_getYearWord(currentDuration.years)} трезвости!',
      );
    }

    if (currentDuration.months > 0 && sobrietyDate!.day == now.day) {
      result.add(
        '${currentDuration.years} ${_getYearWord(currentDuration.years)} '
        '${currentDuration.months} ${_getMonthWord(currentDuration.months)} трезвости!',
      );
    }

    if (currentDuration.totalDays > 0 && currentDuration.totalDays % 10 == 0) {
      result.add('${currentDuration.totalDays} дней трезвости!');
    }

    if (_hasRepeatingDigits(currentDuration.totalDays)) {
      result.add('Особый день: ${currentDuration.totalDays} дней трезвости!');
    }

    return result;
  }

  String _getYearWord(int years) {
    if (years % 100 >= 11 && years % 100 <= 14) {
      return 'лет';
    }
    switch (years % 10) {
      case 1:
        return 'год';
      case 2:
      case 3:
      case 4:
        return 'года';
      default:
        return 'лет';
    }
  }

  String _getMonthWord(int months) {
    if (months % 100 >= 11 && months % 100 <= 14) {
      return 'месяцев';
    }
    switch (months % 10) {
      case 1:
        return 'месяц';
      case 2:
      case 3:
      case 4:
        return 'месяца';
      default:
        return 'месяцев';
    }
  }

  bool _hasRepeatingDigits(int number) {
    final str = number.toString();
    if (str.length == 1) {
      return false;
    }
    return str.split('').every((c) => c == str[0]);
  }

  String _getDayWord(int days) {
    if (days % 100 >= 11 && days % 100 <= 14) {
      return 'дней';
    }
    switch (days % 10) {
      case 1:
        return 'день';
      case 2:
      case 3:
      case 4:
        return 'дня';
      default:
        return 'дней';
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final initialDate = sobrietyDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      confirmText: 'Выбрать',
      locale: const Locale('ru', 'RU'),
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      await updateSobrietyDate(pickedDate);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Дата трезвости обновлена')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDuration = duration ?? SobrietyDuration();
    final palette = context.appPalette;
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final compactWidth = MediaQuery.sizeOf(context).width - 32;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Точка опоры',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: palette.isDark
                            ? Colors.white
                            : const Color(0xFF153040),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  sobrietyDate == null
                      ? 'Выберите дату начала трезвости, и приложение будет считать срок и напоминать о круглых датах.'
                      : 'Твой путь уже идёт. Здесь собраны самые важные цифры по трезвости в одном спокойном экране.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.isDark
                            ? Colors.white.withValues(alpha: 0.92)
                            : const Color(0xFF17303F),
                      ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _showDatePicker(context),
                      icon: const Icon(Icons.event_rounded),
                      label: Text(
                        sobrietyDate == null
                            ? 'Установить дату'
                            : 'Изменить дату',
                      ),
                    ),
                    if (sobrietyDate != null)
                      FilledButton.tonalIcon(
                        onPressed: () => _showDatePicker(context),
                        icon: const Icon(Icons.edit_calendar_rounded),
                        label: const Text('Скорректировать'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: isWide ? 260 : compactWidth,
                child: AppMetricCard(
                  icon: Icons.today_rounded,
                  label: 'Дата трезвости',
                  value: sobrietyDate == null
                      ? 'Не выбрана'
                      : DateFormat('dd.MM.yyyy').format(sobrietyDate!),
                ),
              ),
              SizedBox(
                width: isWide ? 260 : compactWidth,
                child: AppMetricCard(
                  icon: Icons.calendar_month_rounded,
                  label: 'Всего дней',
                  value: '${currentDuration.totalDays}',
                  accent: palette.accentSecondary,
                ),
              ),
              SizedBox(
                width: isWide ? 320 : compactWidth,
                child: AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Основной срок',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      if (sobrietyDate == null)
                        Text(
                          'Дата ещё не выбрана.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        )
                      else
                        BeautifulText(
                          text:
                              '${currentDuration.years} ${_getYearWord(currentDuration.years)} '
                              '${currentDuration.months} ${_getMonthWord(currentDuration.months)} '
                              '${currentDuration.days} ${_getDayWord(currentDuration.days)}',
                          fontSize: 28,
                          withGradient: true,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (anniversaries.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Памятные даты',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...anniversaries.map(
                    (msg) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: palette.accentSoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.celebration_rounded, color: palette.accent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                msg,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
