import 'package:aahelp/findgroup/find_map.dart';
import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/helper/utils.dart';
import 'package:flutter/material.dart';

class FindGroup extends StatefulWidget {
  const FindGroup({super.key});

  @override
  State<FindGroup> createState() => _FindGroupState();
}

class _FindGroupState extends State<FindGroup> {
  late Future<List<GroupsAA>> futureGroupAAList;
  List<GroupsAA> groups = <GroupsAA>[];
  List<GroupsAA> filterGroups = <GroupsAA>[];
  TimePeriod todayTime = TimePeriod.none;
  bool isToday = false;

  @override
  void initState() {
    super.initState();
    futureGroupAAList = loadGroupsAAList();
  }

  Future<List<GroupsAA>> loadGroupsAAList() async {
    final loadedGroups = await GroupsAA.fetchGroupAAList();
    if (!mounted) {
      return loadedGroups;
    }

    setState(() {
      groups = loadedGroups;
      filterGroups = loadedGroups;
    });

    return loadedGroups;
  }

  Future<void> updateFilterGroups() async {
    final groupSearchService = GroupSearchService();
    final nextGroups = await groupSearchService.filterGroupsByTime(
      todayTime,
      groups,
      isToday,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      filterGroups = nextGroups;
    });
  }

  Future<void> _reload() async {
    setState(() {
      futureGroupAAList = loadGroupsAAList();
    });
    await futureGroupAAList;
    await updateFilterGroups();
  }

  Future<void> _setTimePeriod(TimePeriod nextValue) async {
    setState(() {
      todayTime = nextValue;
    });
    await updateFilterGroups();
  }

  Future<void> _setTodayFilter(bool nextValue) async {
    setState(() {
      isToday = nextValue;
    });
    await updateFilterGroups();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GroupsAA>>(
      future: futureGroupAAList,
      builder: (context, snapshot) {
        return switch (snapshot.connectionState) {
          ConnectionState.waiting => const _GroupsLoadingState(),
          _ when snapshot.hasError => _GroupsErrorState(
              onReload: _reload,
              message: '${snapshot.error}',
            ),
          _ when !snapshot.hasData || snapshot.data!.isEmpty =>
            const _GroupsEmptyState(),
          _ => FindMapWidget(
              allGroupsCount: groups.length,
              groups: filterGroups,
              todayTime: todayTime,
              isToday: isToday,
              onTimePeriodChanged: _setTimePeriod,
              onTodayChanged: _setTodayFilter,
            ),
        };
      },
    );
  }
}

class _GroupsLoadingState extends StatelessWidget {
  const _GroupsLoadingState();

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Загружаем группы и карту…',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupsErrorState extends StatelessWidget {
  const _GroupsErrorState({
    required this.onReload,
    required this.message,
  });

  final VoidCallback onReload;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 56),
              const SizedBox(height: 16),
              Text(
                'Не удалось загрузить список групп.',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupsEmptyState extends StatelessWidget {
  const _GroupsEmptyState();

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Center(
        child: Text(
          'Не найдено ни одной группы.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
