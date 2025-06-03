import 'package:aahelp/diary/diaryhtml.dart';
import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/helper/utils.dart';
import 'package:aahelp/findgroup/find_map.dart';
import 'package:aahelp/mysobriety/mysobriety.dart';
import 'package:aahelp/stepandtraditions/step.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class FindGroup extends StatefulWidget {
  final String title;

  const FindGroup({super.key, required this.title});

  @override
  State<FindGroup> createState() => _FindGroupState();
}

class _FindGroupState extends State<FindGroup> {
  late Future<List<GroupsAA>> futureGroupAAList;
  List<GroupsAA> groups = [];
  TimePeriod todayTime = TimePeriod.none;
  List<GroupsAA> filterGroups = [];
  bool isToday = false;
  String appVersion = '1.0.0';
  String appName = 'My App';

  @override
  void initState() {
    super.initState();
    futureGroupAAList = loadGroupsAAList();
    getPackageInfo();
  }

  Future<void> getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      appName = packageInfo.appName;
    });
  }

  // Загрузка списка групп
  Future<List<GroupsAA>> loadGroupsAAList() async {
    List<GroupsAA> loadedGroups = await GroupsAA.fetchGroupAAList();
    setState(() {
      groups = loadedGroups;
      filterGroups = loadedGroups; // Инициализируем filterGroups
    });
    return loadedGroups;
  }

  // Обновление фильтрации групп
  Future<void> updateFilterGroups() async {
    final GroupSearchService groupSearchService = GroupSearchService();
    filterGroups = await groupSearchService.filterGroupsByTime(
      todayTime,
      groups,
      isToday,
    );
    setState(() {});
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BeautifulText(
              text: widget.title,
              fontSize: 18,
              color: Colors.deepPurple,
            ),
            Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  side: BorderSide(
                    width: 1.5,
                    color: Colors.deepPurple,
                  ),
                  semanticLabel: 'На сегодня',
                  value: isToday,
                  onChanged: (bool? newvalue) {
                    setState(() {
                      isToday = newvalue!;
                      updateFilterGroups();
                    });
                  },
                ),
              ],
            ),
            BeautifulText(
              text: 'На сегодня',
              fontSize: 14,
              color: Colors.deepPurple.shade400,
            ),
          ],
        ),
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
                  TabBarPage(tabWidget: FindGroup(title: 'Найти группу')),
                  const TabBarPage(tabWidget: Diary(title: 'Ежедневник')),
                  const TabBarPage(
                      tabWidget: StepAndTraditions(title: '12х12')),
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
      backgroundColor: AppColor.backgroundColor,
      bottomSheet: SegmentedButton<TimePeriod>(
        emptySelectionAllowed: true,
        style: SegmentedButton.styleFrom(
          backgroundColor: AppColor.defaultColor,
          foregroundColor: Colors.red,
          selectedForegroundColor: Colors.white,
          selectedBackgroundColor: Colors.green,
        ),
        segments: <ButtonSegment<TimePeriod>>[
          ButtonSegment<TimePeriod>(
            value: TimePeriod.morning,
            label: Text(
              'Утро',
              style: AppTextStyle.minimalsstyle,
            ),
            icon: Icon(Icons.sunny, size: 16),
          ),
          ButtonSegment<TimePeriod>(
            value: TimePeriod.afternoon,
            label: Text(
              'День',
              style: AppTextStyle.minimalsstyle,
            ),
            icon: Icon(Icons.lunch_dining, size: 16),
          ),
          ButtonSegment<TimePeriod>(
            value: TimePeriod.evening,
            label: Text(
              'Вечер',
              style: AppTextStyle.minimalsstyle,
            ),
            icon: Icon(Icons.bed, size: 15),
          ),
          ButtonSegment<TimePeriod>(
            value: TimePeriod.none,
            label: Text(
              'Весь день',
              style: AppTextStyle.minimalsstyle,
            ),
            icon: Icon(Icons.all_out, size: 16),
          ),
        ],
        selected: <TimePeriod>{todayTime},
        onSelectionChanged: (Set<TimePeriod> newSelection) async {
          setState(() {
            todayTime =
                newSelection.isNotEmpty ? newSelection.first : TimePeriod.none;
            filterGroups = groups; // Сбрасываем фильтрованные группы
          });
          await updateFilterGroups(); // Обновляем фильтрацию
        },
      ),
      body: FutureBuilder<List<GroupsAA>>(
          future: futureGroupAAList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No groups found.'));
            }
            // Не нужно здесь обновлять filterGroups, так как это уже сделано в loadGroupsAAList
            return FindMapWidget(
              groups: filterGroups,
              todayTime: todayTime,
              isToday: isToday,
            );
          }),
    );
  }
}
