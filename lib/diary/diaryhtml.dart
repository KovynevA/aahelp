import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' as html_dom;
import 'package:html/parser.dart' as html_parser;

class Diary extends StatelessWidget {
  const Diary({super.key});

  @override
  Widget build(BuildContext context) {
    return const DiaryWidget();
  }
}

class DiaryWidget extends StatelessWidget {
  const DiaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = width >= 1280 ? 980.0 : 860.0;

    return FutureBuilder<Map<String, String>>(
      future: loadAsset(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return AppPanel(
            child: Center(
              child: Text('Ошибка: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const AppPanel(
            child: Center(child: Text('Ошибка загрузки ежедневника')),
          );
        }

        final todayText = snapshot.data!;
        final header = todayText['header'] ?? '';
        final body = todayText['body'] ?? '';
        final today = DateTime.now();
        final todayDate = '${today.day} ${_getMonthName(today.month)}';
        final palette = context.appPalette;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
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
                          todayDate,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: palette.isDark
                                    ? Colors.white
                                    : const Color(0xFF172B38),
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          header.isEmpty ? 'Текст на сегодня' : header,
                          style:
                              Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontSize: 28,
                                    color: palette.isDark
                                        ? Colors.white
                                        : const Color(0xFF132734),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppPanel(
                    child: HtmlWidget(
                      body,
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      customStylesBuilder: (element) {
                        if (element.localName == 'h5') {
                          return {
                            'font-size': '26px',
                            'font-weight': '700',
                            'margin-bottom': '12px',
                          };
                        }
                        if (element.localName == 'p') {
                          return {
                            'line-height': '1.65',
                            'margin-bottom': '12px',
                          };
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<Map<String, String>> loadAsset() async {
  try {
    final data = await rootBundle.loadString('assets/txt/diary.html');
    return parseHtmlForToday(data);
  } catch (e) {
    debugPrint('Error loading file: $e');
    return {'header': '', 'body': 'Ошибка загрузки файла'};
  }
}

Map<String, String> parseHtmlForToday(String htmlContent) {
  final today = DateTime.now();
  final todayDate = '${today.day} ${_getMonthName(today.month)}';
  final document = html_parser.parse(htmlContent);
  final dateHeaders = document.querySelectorAll('h2');

  var header = '';
  var body = '';

  for (final dateHeader in dateHeaders) {
    final dateText = dateHeader.text.trim();
    if (!dateText.contains(todayDate)) {
      continue;
    }

    html_dom.Element? nextElement = dateHeader.nextElementSibling;
    while (nextElement != null) {
      if (nextElement.localName == 'h5') {
        header = nextElement.text.trim();
      } else if (nextElement.localName == 'div') {
        body = nextElement.innerHtml.trim();
        break;
      }
      nextElement = nextElement.nextElementSibling;
    }

    break;
  }

  if (header.isEmpty && body.isEmpty) {
    return {'header': '', 'body': 'No text found for today.'};
  }

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
