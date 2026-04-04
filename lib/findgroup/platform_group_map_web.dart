// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:aahelp/findgroup/map_models.dart';
import 'package:aahelp/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
  static final _groupTapEvents =
      html.EventStreamProvider<html.CustomEvent>('aahelp-group-tap');
  static int _mapCounter = 0;

  final String _apiKey = _normalizeApiKey(
    const String.fromEnvironment('yandex_web_api_key'),
  );
  late final String _viewType = 'aahelp-yandex-web-map-${_mapCounter++}';
  late final String _containerId =
      'aahelp-yandex-web-map-container-${_mapCounter++}';
  late final html.DivElement _container = html.DivElement()
    ..id = _containerId
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.border = '0'
    ..style.margin = '0'
    ..style.padding = '0';

  StreamSubscription<html.CustomEvent>? _groupTapSubscription;
  bool _mapReady = false;
  int? _lastCameraToken;

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int _) => _container,
    );
    _groupTapSubscription =
        _groupTapEvents.forTarget(_container).listen(_handleGroupTap);
    WidgetsBinding.instance.addPostFrameCallback((_) => _createMap());
  }

  @override
  void didUpdateWidget(covariant PlatformGroupMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mapReady) {
      unawaited(_syncMapState());
    }
  }

  @override
  void dispose() {
    _groupTapSubscription?.cancel();
    if (_mapReady && _interopAvailable) {
      _interop.callMethod('destroy'.toJS, _containerId.toJS);
    }
    super.dispose();
  }

  JSObject get _interop => globalContext['aahelpYandexMaps']! as JSObject;

  bool get _interopAvailable => globalContext.has('aahelpYandexMaps');

  void _handleGroupTap(html.CustomEvent event) {
    final detail = event.detail;
    if (detail is String) {
      widget.onGroupTap(detail);
    }
  }

  static String _normalizeApiKey(String apiKey) {
    final trimmed = apiKey.trim();
    if ((trimmed.startsWith("'") && trimmed.endsWith("'")) ||
        (trimmed.startsWith('"') && trimmed.endsWith('"'))) {
      return trimmed.substring(1, trimmed.length - 1).trim();
    }
    return trimmed;
  }

  Future<void> _createMap() async {
    if (!_interopAvailable || _apiKey.isEmpty) {
      return;
    }

    final created = await _interop.callMethodVarArgs<JSPromise<JSBoolean>>(
      'create'.toJS,
      <JSAny?>[
        _containerId.toJS,
        _apiKey.toJS,
        jsonEncode(_buildState()).toJS,
      ],
    ).toDart;

    if (!mounted || !created.toDart) {
      return;
    }

    _mapReady = true;
    await _applyCameraRequest(forceDefaultCenter: true);
  }

  Future<void> _syncMapState() async {
    if (!_mapReady) {
      return;
    }

    await _interop.callMethodVarArgs<JSPromise<JSAny?>>(
      'update'.toJS,
      <JSAny?>[
        _containerId.toJS,
        jsonEncode(_buildState()).toJS,
      ],
    ).toDart;

    await _applyCameraRequest();
  }

  Future<void> _applyCameraRequest({bool forceDefaultCenter = false}) async {
    if (!_mapReady) {
      return;
    }

    final request = widget.cameraRequest;
    if (request != null && request.token != _lastCameraToken) {
      _lastCameraToken = request.token;
      await _interop.callMethodVarArgs<JSPromise<JSAny?>>(
        'focus'.toJS,
        <JSAny?>[
          _containerId.toJS,
          request.point.longitude.toJS,
          request.point.latitude.toJS,
          request.zoom.toJS,
        ],
      ).toDart;
      return;
    }

    if (forceDefaultCenter && request == null) {
      await _interop.callMethodVarArgs<JSPromise<JSAny?>>(
        'focus'.toJS,
        <JSAny?>[
          _containerId.toJS,
          defaultMapPoint.longitude.toJS,
          defaultMapPoint.latitude.toJS,
          10.5.toJS,
        ],
      ).toDart;
    }
  }

  Map<String, dynamic> _buildState() {
    return <String, dynamic>{
      'clustered': widget.isClustered,
      'groups': widget.groups
          .where((group) => group.coordinates != null)
          .map((group) {
        final point = pointForGroup(group)!;
        return <String, dynamic>{
          'id': group.companyId,
          'name': group.nameOther,
          'latitude': point.latitude,
          'longitude': point.longitude,
        };
      }).toList(),
      'currentPosition': widget.currentPosition == null
          ? null
          : <String, dynamic>{
              'latitude': widget.currentPosition!.latitude,
              'longitude': widget.currentPosition!.longitude,
            },
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_apiKey.isEmpty) {
      return const ColoredBox(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Для web/PWA не задан Yandex JS API key.\n'
              'Передайте --dart-define=yandex_web_api_key=...',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (!_interopAvailable) {
      return const ColoredBox(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Не найден web-мост Yandex Maps.\n'
              'Проверьте подключение web/yandex_map.js в index.html.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return HtmlElementView(viewType: _viewType);
  }
}
