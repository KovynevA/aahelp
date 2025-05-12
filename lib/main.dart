import 'package:aahelp/findgroup/findgroup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'), // Русский язык
      ],
      locale: const Locale('ru', 'RU'),

      debugShowCheckedModeBanner: false,
      home: FindGroup(
          title: 'Найти группу'), // Выносим основной контент в отдельный виджет
    );
  }
}
