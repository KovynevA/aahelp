import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/helper/utils.dart';
import 'package:aahelp/findgroup/findMap.dart';
import 'package:flutter/material.dart';


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
  bool isToday = false;
  List<GroupsAA> filterGroups = [];

  @override
  void initState() {
    super.initState();
    futureGroupAAList = loadGroupsAAList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: isToday,
                  onChanged: (bool? newvalue) {
                    setState(() {
                      isToday = newvalue!;
                    });
                    updateFilterGroups(); // Обновляем фильтрацию
                  },
                ),
                Text(
                  'На сегодня',
                  style: AppTextStyle.spantextstyle,
                ),
              ],
            ),
          ],
        ),
      ),
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
