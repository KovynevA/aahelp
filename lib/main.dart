import 'package:aahelp/diary/diaryhtml.dart';
import 'package:aahelp/findgroup/findgroup.dart';
import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/helper/utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          title: const Text('Помощник АА', style: AppTextStyle.menutextstyle),
        ),
        drawer: Drawer(
          backgroundColor: AppColor.backgroundColor,
          width: MediaQuery.of(context).size.width * 0.5,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.13,
                child: const DrawerHeader(
                  curve: Curves.decelerate,
                  decoration: BoxDecoration(color: Colors.lightBlueAccent),
                  child: Text('Меню', style: AppTextStyle.menutextstyle),
                ),
              ),
              const TabBarPage(tabWidget: FindGroup(title: 'Найти группу')),
              const TabBarPage(tabWidget: Diary(title: 'Ежедневник')),
            ],
          ),
        ),
        body: FindGroup(title: 'Найти группу'),
        backgroundColor: AppColor.backgroundColor,
      ),
    );
  }
}
