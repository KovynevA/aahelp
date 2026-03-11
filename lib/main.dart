import 'package:aahelp/findgroup/findgroup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yandex_maps_mapkit/init.dart' as init;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init.initMapkit(apiKey: 'd6d67c41-2b7d-43a5-b78b-47adaf4e9227');
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
