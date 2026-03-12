import 'package:aahelp/helper/utils.dart' show GroupsAA, TimePeriod;
import 'package:flutter/material.dart' hide ImageProvider;
import 'package:latlong2/latlong.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/mapkit_factory.dart';
import 'package:yandex_maps_mapkit/src/bindings/image/image_provider.dart';
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
  List<PlacemarkMapObject> _markers = [];

  @override
  void initState() {
    super.initState();
    _groups = widget.groups;
    print(_groups?.length);
  }

  // Загрузка списка групп и расстановка маркеров
  void loadMarkerList(List<GroupsAA> groups) {
    _markers = groups
        .where((group) => group.coordinates != null)
        .map((group) => buildMarker(
              LatLng(
                double.parse(group.coordinates!.lat),
                double.parse(group.coordinates!.lon),
              ),
              group.nameOther,
              group.companyId,
            ))
        .toList();
    // _determinePosition();
    // _markers.add(positionMarker());
  }

  PlacemarkMapObject buildMarker(LatLng coordinates, String word, String id) {
    final imageProvider =
        ImageProvider.fromImageProvider(const AssetImage("assets/group.png"));
    return _mapWindow!.map.mapObjects.addPlacemark()
      ..geometry = Point(
          latitude: coordinates.latitude, longitude: coordinates.longitude)
      ..setIcon(imageProvider);
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
