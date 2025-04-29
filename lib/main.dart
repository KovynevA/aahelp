import 'package:aahelp/diary/diaryhtml.dart';
import 'package:aahelp/findgroup/findgroup.dart';
import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/helper/utils.dart';
import 'package:aahelp/mysobriety/mysobriety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    Locale('ru', 'RU'),  // Русский язык
  ],
  locale: const Locale('ru', 'RU'),  

      debugShowCheckedModeBanner: false,
      home: HomePage(), // Выносим основной контент в отдельный виджет
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String appVersion = '1.0.0';
  String appName = 'My App';

  @override
  void initState() {
    super.initState();
    getPackageInfo();
  }

  Future<void> getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      appName = packageInfo.appName;
    });
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'О приложении',
          style: AppTextStyle.menutextstyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Название: $appName', style: AppTextStyle.valuesstyle),
            SizedBox(height: 8),
            Text('Версия: $appVersion', style: AppTextStyle.booktextstyle),
            SizedBox(height: 16),
            Text('Разработчик: Kovynev Andrey',
                style: AppTextStyle.booktextstyle),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('https://t.me/app_aahelper')),
              child: Text(
                'Telegram: t.me/app_aahelper',
                style: AppTextStyle.booktextstyle,
              ),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () =>
                  launchUrl(Uri.parse('mailto:kovynevandrei@gmail.com')),
              child: Text('Email: kovynevandrei@gmail.com',
                  style: AppTextStyle.booktextstyle),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () =>
                  launchUrl(Uri.parse('https://github.com/KovynevA/aahelp')),
              child: Text('GitHub: github.com/KovynevA/aahelp',
                  style: AppTextStyle.booktextstyle),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text('Помощник АА', style: AppTextStyle.menutextstyle),
      ),
      drawer: Drawer(
        backgroundColor: AppColor.backgroundColor,
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: DrawerHeader(
                      curve: Curves.decelerate,
                      decoration: BoxDecoration(color: Colors.lightBlueAccent),
                      child: Card(
                        color: Colors.lightBlueAccent,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child:
                              Text('Меню', style: AppTextStyle.menutextstyle),
                        ),
                      ),
                    ),
                  ),
                  const TabBarPage(tabWidget: FindGroup(title: 'Найти группу')),
                  const TabBarPage(tabWidget: Diary(title: 'Ежедневник')),
                  const TabBarPage(
                      tabWidget: MySobriety(title: 'Моя трезвость')),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: GestureDetector(
                onTap: () => _showAboutDialog(context),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'О приложении',
                    style: AppTextStyle.booktextstyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: FindGroup(title: 'Найти группу'),
      backgroundColor: AppColor.backgroundColor,
    );
  }
}
