import 'dart:io';

import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class MySobriety extends StatelessWidget {
  final String title;
  const MySobriety({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text(title),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/images/wallpaper.jpg'), // Ваше изображение
            fit: BoxFit.cover, // Растягиваем на весь экран
            opacity: 0.7, // Прозрачность
          ),
        ),
        child: const MySobrietyWidget(),
      ),
    );
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
  List<String> anniversaries = [];

  @override
  void initState() {
    getUser();

    super.initState();
  }

  // Функция для получения пути к файлу
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Функция для получения ссылки на файл
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/date.txt');
  }

  // Функция для сохранения даты в файл
  Future<void> _saveDateToFile(DateTime date) async {
    final file = await _localFile;
    await file.writeAsString(date.toString());
  }

  // Функция для загрузки даты из файла
  Future<DateTime?> _loadDateFromFile() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return DateTime.parse(contents);
    } catch (e) {
      // Если файл не существует или произошла ошибка, возвращаем null
      return null;
    }
  }

  void getUser() async {
    sobrietyDate = await _loadDateFromFile();
    setState(() {
      duration = calculateSobrietyDuration();
      anniversaries = checkAnniversaries();
    });
  }

  // Метод для обновления даты трезвости
  Future<void> updateSobrietyDate(DateTime newDate) async {
    setState(() {
      sobrietyDate = newDate;
      _saveDateToFile(newDate);
      duration = calculateSobrietyDuration();
      anniversaries = checkAnniversaries();
    });
  }

  // Метод для расчета срока трезвости
  SobrietyDuration calculateSobrietyDuration() {
    if (sobrietyDate == null) return SobrietyDuration();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sobrietyDay =
        DateTime(sobrietyDate!.year, sobrietyDate!.month, sobrietyDate!.day);

    int years = now.year - sobrietyDay.year;
    int months = now.month - sobrietyDay.month;
    int days = now.day - sobrietyDay.day;

    // Корректировка, если текущий день месяца меньше дня трезвости
    if (days < 0) {
      months--;
      // Находим последний день предыдущего месяца
      final lastDayOfPrevMonth = DateTime(now.year, now.month, 0).day;
      days += lastDayOfPrevMonth;
    }

    // Корректировка, если текущий месяц меньше месяца трезвости
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

  // Метод для проверки юбилеев
  List<String> checkAnniversaries() {
    if (sobrietyDate == null) return [];

    final duration = calculateSobrietyDuration();
    final anniversaries = <String>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sobrietyDay =
        DateTime(now.year, sobrietyDate!.month, sobrietyDate!.day);

    // Проверка годовщины (ровно N лет)
    if (duration.years > 0 && today == sobrietyDay) {
      anniversaries
          .add('${duration.years} ${_getYearWord(duration.years)} трезвости!');
    }

    // Проверка месячной годовщины (ровно N месяцев)
    if (duration.months > 0 && sobrietyDate!.day == now.day) {
      anniversaries.add(
          '${duration.years} ${_getYearWord(duration.years)} ${duration.months} ${_getMonthWord(duration.months)} трезвости!');
    }

    // Проверка "круглых" дней (делятся на 10)
    if (duration.totalDays > 0 && duration.totalDays % 10 == 0) {
      anniversaries.add('${duration.totalDays} дней трезвости!');
    }

    // Проверка дней с повторяющимися цифрами (11, 22, 111, 222 и т.д.)
    if (_hasRepeatingDigits(duration.totalDays)) {
      anniversaries.add('Особый день - ${duration.totalDays} дней трезвости!');
    }

    return anniversaries;
  }

  // Вспомогательные методы для склонения слов
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
    if (str.length == 1) return false;
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

  void _showDatePicker(BuildContext context) async {
    final initialDate = sobrietyDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      confirmText: 'Выбрать',
      locale: const Locale('ru', 'RU'),
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: AppColor.cardColor,
            textButtonTheme:
                TextButtonThemeData(style: AppButtonStyle.dialogButton),
            textTheme: const TextTheme(
              titleMedium: AppTextStyle.valuesstyle,
              bodyLarge: AppTextStyle.menutextstyle,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      await updateSobrietyDate(pickedDate);
      // Обновляем UI
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Дата трезвости обновлена')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (sobrietyDate != null)
                Card(
                  color: AppColor.cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      'Дата трезвости: \n${DateFormat('dd.MM.yyyy').format(sobrietyDate ?? DateTime.now())}',
                      style: AppTextStyle.valuesstyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: () => _showDatePicker(context),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: const Text(
                    'Установить дату\n трезвости',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (sobrietyDate != null) ...[
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Center(
              child: Text(
                'Ты трезвый уже ',
                style: AppTextStyle.menutextstyle,
              ),
            ),
          ),
          // Отображаем срок трезвости
          if ((duration?.years ?? 0) > 0)
            BeautifulText(
              text: '${duration?.years} ${_getYearWord(duration?.years ?? 0)} '
                  '${duration?.months} ${_getMonthWord(duration?.months ?? 0)} '
                  '${duration?.days} ${_getDayWord(duration?.days ?? 0)}',
              fontSize: 24,
              withShadow: true,
              withGradient: true,
              color: Colors.blue,
              withAnimation: true,
            )
          else if ((duration?.months ?? 0) > 0)
            BeautifulText(
              text:
                  '${duration?.months} ${_getMonthWord(duration?.months ?? 0)} '
                  '${duration?.days} ${_getDayWord(duration?.days ?? 0)}',
              fontSize: 24,
              withShadow: true,
              withGradient: true,
              color: Colors.blue,
              withAnimation: true,
            )
          else
            BeautifulText(
              text: '${duration?.days} ${_getDayWord(duration?.days ?? 0)}',
              fontSize: 24,
              withShadow: true,
              withGradient: true,
              color: Colors.blue,
              withAnimation: true,
            ),

          // Отображаем общее количество дней, если больше месяца
          if ((duration?.totalDays ?? 0) >= 30)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: BeautifulText(
                text: 'Всего дней: ${duration?.totalDays}',
                fontSize: 48,
                withShadow: true,
                withGradient: true,
                color: Colors.red,
                withAnimation: true,
              ),
            ),

          // Показываем юбилеи
          if (anniversaries.isNotEmpty)
            Column(
              children: [
                Divider(
                  height: 10.0,
                ),
                const BeautifulText(
                  text: 'Поздравляем с юбилеем!',
                  fontSize: 36,
                  withShadow: true,
                  withGradient: true,
                  color: Colors.green,
                  withAnimation: true,
                ),
                ...anniversaries.map(
                  (msg) => BeautifulText(
                    text: msg,
                    fontSize: 36,
                    withShadow: true,
                    withGradient: true,
                    color: Colors.green,
                    withAnimation: true,
                  ),
                ),
              ],
            ),
        ] else
          const Text(
            'Дата трезвости не установлена',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
      ],
    );
  }
}
