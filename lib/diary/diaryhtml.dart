import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

class Diary extends StatelessWidget {
  final String title;
  const Diary({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text(title),
      ),
      body: const DiaryWidget(),
    );
  }
}

class DiaryWidget extends StatefulWidget {
  const DiaryWidget({super.key});

  @override
  State<DiaryWidget> createState() => _DiaryWidgetState();
}

class _DiaryWidgetState extends State<DiaryWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: loadAsset(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            Map<String, String> todayText = snapshot.data!;
            String header = todayText['header']!;
            String body = todayText['body']!;

            DateTime today = DateTime.now();
            String todayDate = '${today.day} ${_getMonthName(today.month)}';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Дата
                    Text(
                      todayDate,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Заголовок <h5> (жирный и по центру)
                    if (header.isNotEmpty)
                      Center(
                        child: Text(
                          header,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    //const SizedBox(height: 16),

                    // Основной текст
                    HtmlWidget(
                      body,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      // Если у вас есть стили в HTML, вы можете использовать customStylesBuilder
                      customStylesBuilder: (element) {
                        if (element.localName == 'h5') {
                          return {
                            'color': 'black',
                            'font-weight': 'bold',
                            'font-size': '30'
                          };
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else {
            return const Center(child: Text('Ошибка загрузки Ежедневника'));
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

Future<Map<String, String>> loadAsset() async {
  try {
    String data = await rootBundle.loadString('assets/txt/diary.html');
    return parseHtmlForToday(data);
  } catch (e) {
    debugPrint('Error loading file: $e');
    return {'header': '', 'body': 'Ошибка загрузки файла'};
  }
}

Map<String, String> parseHtmlForToday(String htmlContent) {
  DateTime today = DateTime.now();
  String todayDate = '${today.day} ${_getMonthName(today.month)}';
  print('Looking for date: $todayDate');

  // Парсим HTML
  html_dom.Document document = html_parser.parse(htmlContent);

  // Находим все заголовки h2 (даты)
  List<html_dom.Element> dateHeaders = document.querySelectorAll('h2');

  String header = '';
  String body = '';

  for (var dateHeader in dateHeaders) {
    String dateText = dateHeader.text.trim();

    // Если найдена сегодняшняя дата
    if (dateText.contains(todayDate)) {
      print('Date found: $dateText');

      // Находим следующий элемент (заголовок h5)
      html_dom.Element? nextElement = dateHeader.nextElementSibling;
      while (nextElement != null) {
        if (nextElement.localName == 'h5') {
          // Нашли заголовок
          header = nextElement.text.trim();
          print('Header found: $header');
        } else if (nextElement.localName == 'div') {
          // Нашли текст
          body = nextElement.innerHtml
              .trim(); // Используем innerHtml для сохранения HTML-форматирования
          break;
        }
        nextElement = nextElement.nextElementSibling;
      }

      break;
    }
  }

  if (header.isEmpty && body.isEmpty) {
    print('No text found for today.');
    return {'header': '', 'body': 'No text found for today.'};
  }

  // Возвращаем заголовок и основной текст
  return {'header': header, 'body': body};
}

String _getMonthName(int month) {
  switch (month) {
    case 1:
      return 'января';
    case 2:
      return 'февраля';
    case 3:
      return 'марта';
    case 4:
      return 'апреля';
    case 5:
      return 'мая';
    case 6:
      return 'июня';
    case 7:
      return 'июля';
    case 8:
      return 'августа';
    case 9:
      return 'сентября';
    case 10:
      return 'октября';
    case 11:
      return 'ноября';
    case 12:
      return 'декабря';
    default:
      return '';
  }
}
