import 'package:aahelp/helper/utils.dart' show GroupsAA, TimePeriod;
import 'package:flutter/material.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/mapkit_factory.dart';
import 'package:yandex_maps_mapkit/yandex_map.dart';

class FindMapWidget extends StatefulWidget {
  final List<GroupsAA> groups;
  final TimePeriod todayTime;
  final bool isToday;
  const FindMapWidget(
      {super.key,
      required this.groups,
      required this.todayTime,
      required this.isToday});

  @override
  State<FindMapWidget> createState() => _FindMapWidgetState();
}

class _FindMapWidgetState extends State<FindMapWidget> {
  MapWindow? _mapWindow;
  List<GroupsAA>? _groups = [];

  @override
  void initState() {
    super.initState();
    _groups = widget.groups;
    mapkit.onStart();
  }

  @override
  void dispose() {
    // Обязательно останавливаем карту при уничтожении виджета
    mapkit.onStop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: YandexMap(
          onMapCreated: (mapWindow) {
            _mapWindow = mapWindow;
            mapkit.onStart();
          },
        ),
      ),
    );
  }
}
