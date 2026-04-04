import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aahelp/findgroup/map_models.dart';
import 'package:aahelp/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class PlatformGroupMap extends StatefulWidget {
  const PlatformGroupMap({
    super.key,
    required this.groups,
    required this.currentPosition,
    required this.isClustered,
    required this.cameraRequest,
    required this.onGroupTap,
  });

  final List<GroupsAA> groups;
  final Position? currentPosition;
  final bool isClustered;
  final MapCameraRequest? cameraRequest;
  final ValueChanged<String> onGroupTap;

  @override
  State<PlatformGroupMap> createState() => _PlatformGroupMapState();
}

class _PlatformGroupMapState extends State<PlatformGroupMap> {
  static const _clusterCollectionId = MapObjectId('groups_cluster_collection');

  YandexMapController? _controller;
  Uint8List? _groupMarkerBytes;
  Uint8List? _userMarkerBytes;
  final Map<int, Uint8List> _clusterIconCache = {};
  int? _lastCameraToken;

  @override
  void initState() {
    super.initState();
    _prepareMarkerIcons();
  }

  @override
  void didUpdateWidget(covariant PlatformGroupMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyCameraRequestIfNeeded();
  }

  Future<void> _prepareMarkerIcons() async {
    final groupMarkerBytes = await _buildPinBytes(
      fillColor: Colors.red,
      strokeColor: Colors.white,
    );
    final userMarkerBytes = await _buildPinBytes(
      fillColor: Colors.blue,
      strokeColor: Colors.white,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _groupMarkerBytes = groupMarkerBytes;
      _userMarkerBytes = userMarkerBytes;
    });
  }

  Future<Uint8List> _buildPinBytes({
    required Color fillColor,
    required Color strokeColor,
  }) async {
    const canvasSize = Size(96, 96);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    const center = Offset(48, 36);
    canvas.drawCircle(center, 18, fillPaint);
    canvas.drawCircle(center, 18, strokePaint);

    final path = Path()
      ..moveTo(48, 78)
      ..lineTo(34, 48)
      ..lineTo(62, 48)
      ..close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    final image = await recorder
        .endRecording()
        .toImage(canvasSize.width.toInt(), canvasSize.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return bytes!.buffer.asUint8List();
  }

  Future<Uint8List> _buildClusterBytes(int count) async {
    final cached = _clusterIconCache[count];
    if (cached != null) {
      return cached;
    }

    const canvasSize = Size(140, 140);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final fillPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    const circleCenter = Offset(70, 70);
    canvas.drawCircle(circleCenter, 48, fillPaint);
    canvas.drawCircle(circleCenter, 48, strokePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 44,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (canvasSize.width - textPainter.width) / 2,
        (canvasSize.height - textPainter.height) / 2,
      ),
    );

    final image = await recorder
        .endRecording()
        .toImage(canvasSize.width.toInt(), canvasSize.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = bytes!.buffer.asUint8List();
    _clusterIconCache[count] = pngBytes;
    return pngBytes;
  }

  List<PlacemarkMapObject> _buildGroupPlacemarks() {
    final markerBytes = _groupMarkerBytes;
    if (markerBytes == null) {
      return const <PlacemarkMapObject>[];
    }

    return widget.groups
        .where((group) => group.coordinates != null)
        .map((group) {
      final point = Point(
        latitude: double.parse(group.coordinates!.lat),
        longitude: double.parse(group.coordinates!.lon),
      );

      return PlacemarkMapObject(
        mapId: MapObjectId(group.companyId),
        point: point,
        consumeTapEvents: true,
        opacity: 1,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromBytes(markerBytes),
            scale: 0.9,
          ),
        ),
        text: PlacemarkText(
          text: group.nameOther,
          style: const PlacemarkTextStyle(
            size: 11,
            color: Colors.black,
            outlineColor: Colors.white,
            placement: TextStylePlacement.top,
            offset: 0.9,
          ),
        ),
        onTap: (_, __) => widget.onGroupTap(group.companyId),
      );
    }).toList();
  }

  PlacemarkMapObject? _buildUserPlacemark() {
    final currentPosition = widget.currentPosition;
    final markerBytes = _userMarkerBytes;
    if (currentPosition == null || markerBytes == null) {
      return null;
    }

    return PlacemarkMapObject(
      mapId: const MapObjectId('current_position_marker'),
      point: Point(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
      ),
      opacity: 1,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromBytes(markerBytes),
          scale: 0.9,
        ),
      ),
      text: const PlacemarkText(
        text: 'Вы здесь',
        style: PlacemarkTextStyle(
          size: 11,
          color: Colors.black,
          outlineColor: Colors.white,
          placement: TextStylePlacement.bottom,
          offset: 0.9,
        ),
      ),
    );
  }

  List<MapObject> _buildMapObjects() {
    final groupPlacemarks = _buildGroupPlacemarks();
    final userPlacemark = _buildUserPlacemark();
    final mapObjects = <MapObject>[];

    if (widget.isClustered) {
      mapObjects.add(
        ClusterizedPlacemarkCollection(
          mapId: _clusterCollectionId,
          placemarks: groupPlacemarks,
          radius: 60,
          minZoom: 15,
          onClusterAdded: (self, cluster) async {
            final iconBytes = await _buildClusterBytes(cluster.size);
            return cluster.copyWith(
              appearance: cluster.appearance.copyWith(
                opacity: 1,
                icon: PlacemarkIcon.single(
                  PlacemarkIconStyle(
                    image: BitmapDescriptor.fromBytes(iconBytes),
                    scale: 1,
                  ),
                ),
              ),
            );
          },
          onClusterTap: (self, cluster) {
            final request = MapCameraRequest(
              token: DateTime.now().microsecondsSinceEpoch,
              point: MapPointData(
                latitude: cluster.appearance.point.latitude,
                longitude: cluster.appearance.point.longitude,
              ),
              zoom: 15,
            );
            _moveCamera(request);
          },
        ),
      );
    } else {
      mapObjects.addAll(groupPlacemarks);
    }

    if (userPlacemark != null) {
      mapObjects.add(userPlacemark);
    }

    return mapObjects;
  }

  Future<void> _applyCameraRequestIfNeeded() async {
    final request = widget.cameraRequest;
    if (_controller == null ||
        request == null ||
        request.token == _lastCameraToken) {
      return;
    }

    await _moveCamera(request);
  }

  Future<void> _moveCamera(MapCameraRequest request) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    _lastCameraToken = request.token;
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: request.point.latitude,
            longitude: request.point.longitude,
          ),
          zoom: request.zoom,
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 0.35,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_groupMarkerBytes == null || _userMarkerBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return YandexMap(
      mapObjects: _buildMapObjects(),
      onMapCreated: (controller) async {
        _controller = controller;
        await _moveCamera(
          widget.cameraRequest ??
              const MapCameraRequest(
                token: 0,
                point: defaultMapPoint,
                zoom: 10.5,
              ),
        );
      },
    );
  }
}
