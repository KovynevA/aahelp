import 'dart:ui';
import 'dart:math' as math;

import 'package:aahelp/findgroup/map_models.dart';
import 'package:aahelp/findgroup/platform_group_map.dart';
import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/helper/utils.dart';
import 'package:aahelp/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FindMapWidget extends StatefulWidget {
  const FindMapWidget({
    super.key,
    required this.allGroupsCount,
    required this.groups,
    required this.todayTime,
    required this.isToday,
    required this.onTimePeriodChanged,
    required this.onTodayChanged,
  });

  final int allGroupsCount;
  final List<GroupsAA> groups;
  final TimePeriod todayTime;
  final bool isToday;
  final ValueChanged<TimePeriod> onTimePeriodChanged;
  final ValueChanged<bool> onTodayChanged;

  @override
  State<FindMapWidget> createState() => _FindMapWidgetState();
}

class _FindMapWidgetState extends State<FindMapWidget> {
  List<GroupsAA> _groups = const <GroupsAA>[];
  SearchCriteria selectedCriteria = SearchCriteria.name;
  Position? _currentPosition;
  String? selectedGroupId;
  bool isClustered = true;
  MapCameraRequest? _cameraRequest;
  int _cameraRequestToken = 0;

  @override
  void initState() {
    super.initState();
    _groups = widget.groups;
    _determinePosition();
  }

  @override
  void didUpdateWidget(covariant FindMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _groups = widget.groups;
      if (selectedGroupId != null && findGroupById(selectedGroupId) == null) {
        selectedGroupId = null;
      }
    });
  }

  Future<void> _centerMap(
    MapPointData point, {
    double zoom = 18.5,
  }) async {
    setState(() {
      _cameraRequestToken += 1;
      _cameraRequest = MapCameraRequest(
        token: _cameraRequestToken,
        point: point,
        zoom: zoom,
      );
    });
  }

  Future<void> _focusCurrentPosition() async {
    final currentPosition = _currentPosition;
    if (currentPosition == null) {
      return;
    }

    await _centerMap(
      MapPointData.fromPosition(currentPosition),
      zoom: 14.5,
    );
  }

  Future<void> _focusGroup(GroupsAA group) async {
    final point = pointForGroup(group);
    if (point == null) {
      return;
    }

    setState(() {
      selectedGroupId = group.companyId;
    });

    await _centerMap(point);
  }

  void _openGroupCard(String groupId) {
    if (findGroupById(groupId) == null) {
      return;
    }

    setState(() {
      selectedGroupId = groupId;
    });
  }

  Future<void> _determinePosition() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        return;
      }
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) {
      return;
    }

    final nextPoint = MapPointData.fromPosition(position);
    setState(() {
      _currentPosition = position;
      if (_cameraRequest == null) {
        _cameraRequestToken += 1;
        _cameraRequest = MapCameraRequest(
          token: _cameraRequestToken,
          point: nextPoint,
          zoom: 10.5,
        );
      }
    });
  }

  GroupsAA? findGroupById(String? groupId) {
    if (groupId == null) {
      return null;
    }

    for (final group in _groups) {
      if (group.companyId == groupId) {
        return group;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1100;
        final isCompact = constraints.maxWidth < 640;
        final sideInset = isCompact ? 8.0 : 12.0;
        final selectedGroup = findGroupById(selectedGroupId);
        final bottomPanelHeight = selectedGroup == null
            ? 0.0
            : math.min(
                isCompact ? 440.0 : 520.0,
                constraints.maxHeight * (isCompact ? 0.62 : 0.68),
              ).toDouble();
        final topOverlayWidth = isWide
            ? math.min(470.0, constraints.maxWidth * 0.42).toDouble()
            : constraints.maxWidth - sideInset * 2;
        final mapRadius = isCompact ? 24.0 : 30.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(mapRadius),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.surfaceMuted,
                    borderRadius: BorderRadius.circular(mapRadius),
                  ),
                  child: PlatformGroupMap(
                    groups: _groups,
                    currentPosition: _currentPosition,
                    isClustered: isClustered,
                    cameraRequest: _cameraRequest,
                    onGroupTap: _openGroupCard,
                  ),
                ),
              ),
              Positioned(
                top: sideInset,
                left: sideInset,
                right: isWide ? null : sideInset,
                child: SizedBox(
                  width: topOverlayWidth,
                  child: BuildFloatingSearchBar(
                    allGroupsCount: widget.allGroupsCount,
                    displayedGroupsCount: _groups.length,
                    groups: _groups,
                    selectedCriteria: selectedCriteria,
                    currentPosition: _currentPosition,
                    todayTime: widget.todayTime,
                    isToday: widget.isToday,
                    onCriteriaChanged: (criteria) {
                      setState(() {
                        selectedCriteria = criteria;
                      });
                    },
                    onTimePeriodChanged: widget.onTimePeriodChanged,
                    onTodayChanged: widget.onTodayChanged,
                    onGroupSelected: _focusGroup,
                  ),
                ),
              ),
              Positioned(
                right: sideInset,
                top: isWide ? sideInset : null,
                bottom: isWide ? null : bottomPanelHeight + sideInset + 10,
                child: _MapActionPanel(
                  isClustered: isClustered,
                  canFocusUser: _currentPosition != null,
                  onClusterToggle: (value) {
                    setState(() {
                      isClustered = value;
                    });
                  },
                  onFocusCurrent: _focusCurrentPosition,
                ),
              ),
              if (selectedGroup != null)
                if (isWide)
                  Positioned(
                    top: 92,
                    right: sideInset,
                    bottom: sideInset,
                    child: SizedBox(
                      width: 396,
                      child: _SelectedGroupPanel(
                        group: selectedGroup,
                        currentPosition: _currentPosition,
                        onClose: () {
                          setState(() {
                            selectedGroupId = null;
                          });
                        },
                      ),
                    ),
                  )
                else
                  Positioned(
                    left: sideInset,
                    right: sideInset,
                    bottom: sideInset,
                    child: SizedBox(
                      height: bottomPanelHeight,
                      child: _SelectedGroupPanel(
                        group: selectedGroup,
                        currentPosition: _currentPosition,
                        onClose: () {
                          setState(() {
                            selectedGroupId = null;
                          });
                        },
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class BuildFloatingSearchBar extends StatefulWidget {
  const BuildFloatingSearchBar({
    super.key,
    required this.allGroupsCount,
    required this.displayedGroupsCount,
    required this.groups,
    required this.selectedCriteria,
    required this.currentPosition,
    required this.todayTime,
    required this.isToday,
    required this.onCriteriaChanged,
    required this.onTimePeriodChanged,
    required this.onTodayChanged,
    required this.onGroupSelected,
  });

  final int allGroupsCount;
  final int displayedGroupsCount;
  final Position? currentPosition;
  final List<GroupsAA> groups;
  final SearchCriteria selectedCriteria;
  final TimePeriod todayTime;
  final bool isToday;
  final ValueChanged<SearchCriteria> onCriteriaChanged;
  final ValueChanged<TimePeriod> onTimePeriodChanged;
  final ValueChanged<bool> onTodayChanged;
  final ValueChanged<GroupsAA> onGroupSelected;

  @override
  State<BuildFloatingSearchBar> createState() => _BuildFloatingSearchBarState();
}

class _BuildFloatingSearchBarState extends State<BuildFloatingSearchBar> {
  String queryNameGroup = '';
  List<GroupsAA> _groups = const <GroupsAA>[];
  final GroupSearchService groupSearchService = GroupSearchService();
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _groups = widget.groups;
    _currentPosition = widget.currentPosition;
  }

  @override
  void didUpdateWidget(covariant BuildFloatingSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _groups = widget.groups;
    _currentPosition = widget.currentPosition;
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  double? _parseRadiusKm(String value) {
    final normalizedValue = value.trim().replaceAll(',', '.');
    final radius = double.tryParse(normalizedValue);
    if (radius == null || radius <= 0) {
      return null;
    }
    return radius;
  }

  double? _distanceKmForGroup(GroupsAA group) {
    final currentPosition = _currentPosition;
    final coordinates = group.coordinates;
    if (currentPosition == null || coordinates == null) {
      return null;
    }

    final latitude = double.tryParse(coordinates.lat);
    final longitude = double.tryParse(coordinates.lon);
    if (latitude == null || longitude == null) {
      return null;
    }

    return Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          latitude,
          longitude,
        ) /
        1000;
  }

  void _clearQuery() {
    textController.clear();
    setState(() {
      queryNameGroup = '';
    });
  }

  void _handleCriteriaChanged(SearchCriteria criteria) {
    if (criteria == widget.selectedCriteria) {
      return;
    }

    final switchesRadiusMode =
        (criteria == SearchCriteria.proximity) !=
        (widget.selectedCriteria == SearchCriteria.proximity);
    widget.onCriteriaChanged(criteria);

    if (switchesRadiusMode && queryNameGroup.isNotEmpty) {
      _clearQuery();
    }
  }

  Future<void> _openFiltersSheet() async {
    var draftCriteria = widget.selectedCriteria;
    var draftIsToday = widget.isToday;
    var draftTimePeriod = widget.todayTime;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: context.appPalette.surface,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Параметры карты',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Режим поиска',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SearchCriteria.values.map((criteria) {
                        return ChoiceChip(
                          avatar: Icon(criteriaToIcon(criteria), size: 16),
                          label: Text(criteriaToString(criteria)),
                          selected: draftCriteria == criteria,
                          onSelected: (_) {
                            setSheetState(() {
                              draftCriteria = criteria;
                            });
                            _handleCriteriaChanged(criteria);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Расписание',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Сегодня'),
                          selected: draftIsToday,
                          onSelected: (value) {
                            setSheetState(() {
                              draftIsToday = value;
                            });
                            widget.onTodayChanged(value);
                          },
                        ),
                        ...TimePeriod.values.map((period) {
                          return ChoiceChip(
                            label: Text(_timePeriodLabel(period)),
                            selected: draftTimePeriod == period,
                            onSelected: (_) {
                              setSheetState(() {
                                draftTimePeriod = period;
                              });
                              widget.onTimePeriodChanged(period);
                            },
                          );
                        }),
                      ],
                    ),
                    if (draftCriteria == SearchCriteria.proximity) ...[
                      const SizedBox(height: 18),
                      Text(
                        _currentPosition == null
                            ? 'Поиск рядом станет доступен после определения геопозиции.'
                            : 'Введите радиус в километрах в верхнее поле поиска.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<GroupsAA> filterGroupsByProximity(double maxDistance) {
    final nearbyGroups = _groups.where((group) {
      final distanceKm = _distanceKmForGroup(group);
      return distanceKm != null && distanceKm <= maxDistance;
    }).toList();

    nearbyGroups.sort((left, right) {
      final leftDistance = _distanceKmForGroup(left) ?? double.infinity;
      final rightDistance = _distanceKmForGroup(right) ?? double.infinity;
      return leftDistance.compareTo(rightDistance);
    });

    return nearbyGroups;
  }

  List<GroupsAA> filterGroups(SearchCriteria searchCriteria) {
    final normalizedQuery = queryNameGroup.trim().toLowerCase();
    var filteredGroups = _groups;

    switch (searchCriteria) {
      case SearchCriteria.name:
        filteredGroups = filteredGroups.where((group) {
          final groupName =
              group.nameOther.replaceFirst('Группа АА ', '').toLowerCase();
          return groupName.startsWith(normalizedQuery);
        }).toList();
      case SearchCriteria.metro:
        filteredGroups = filteredGroups
            .where(
              (group) =>
                  group.metro?.any(
                    (station) =>
                        station.toLowerCase().startsWith(normalizedQuery),
                  ) ??
                  false,
            )
            .toList();
      case SearchCriteria.area:
        filteredGroups = filteredGroups
            .where(
              (group) =>
                  group.district?.toLowerCase().startsWith(normalizedQuery) ??
                  false,
            )
            .toList();
      case SearchCriteria.address:
        filteredGroups = filteredGroups
            .where(
              (group) =>
                  group.address?.toLowerCase().contains(normalizedQuery) ??
                  false,
            )
            .toList();
      case SearchCriteria.proximity:
        final radiusKm = _parseRadiusKm(queryNameGroup);
        if (radiusKm == null) {
          return const <GroupsAA>[];
        }
        filteredGroups = filterGroupsByProximity(radiusKm);
    }

    return filteredGroups.take(12).toList();
  }

  String hintForSearchBar(SearchCriteria criteria) {
    switch (criteria) {
      case SearchCriteria.name:
        return 'Найти группу по названию';
      case SearchCriteria.area:
        return 'Найти по району';
      case SearchCriteria.metro:
        return 'Найти по метро';
      case SearchCriteria.address:
        return 'Найти по адресу';
      case SearchCriteria.proximity:
        return 'Рядом со мной, км';
    }
  }

  String criteriaToString(SearchCriteria criteria) {
    switch (criteria) {
      case SearchCriteria.name:
        return 'Группа';
      case SearchCriteria.area:
        return 'Район';
      case SearchCriteria.metro:
        return 'Метро';
      case SearchCriteria.address:
        return 'Адрес';
      case SearchCriteria.proximity:
        return 'Рядом';
    }
  }

  IconData criteriaToIcon(SearchCriteria criteria) {
    switch (criteria) {
      case SearchCriteria.name:
        return Icons.people_alt_outlined;
      case SearchCriteria.area:
        return Icons.map_outlined;
      case SearchCriteria.metro:
        return Icons.train_outlined;
      case SearchCriteria.address:
        return Icons.home_outlined;
      case SearchCriteria.proximity:
        return Icons.near_me_outlined;
    }
  }

  String _scheduleSummary() {
    final buffer = StringBuffer(widget.isToday ? 'Сегодня' : 'Все дни');
    if (widget.todayTime != TimePeriod.none) {
      buffer.write(' • ${_timePeriodLabel(widget.todayTime)}');
    }
    return buffer.toString();
  }

  String _resultsHintMessage() {
    if (widget.selectedCriteria == SearchCriteria.proximity &&
        _currentPosition == null) {
      return 'Чтобы искать ближайшие группы, включите геопозицию.';
    }

    if (widget.selectedCriteria == SearchCriteria.proximity &&
        _parseRadiusKm(queryNameGroup) == null) {
      return 'Введите радиус в километрах, например 3 или 5.5.';
    }

    return 'Ничего не найдено по текущему фильтру.';
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups = queryNameGroup.isEmpty
        ? const <GroupsAA>[]
        : filterGroups(widget.selectedCriteria);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 900;
    final isCompact = screenWidth < 640;
    final palette = context.appPalette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapOverlaySurface(
          padding: EdgeInsets.all(isCompact ? 10 : 12),
          radius: isCompact ? 20 : 22,
          surfaceOpacity: 0.76,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      focusNode: focusNode,
                      keyboardType: widget.selectedCriteria ==
                              SearchCriteria.proximity
                          ? const TextInputType.numberWithOptions(
                              decimal: true,
                            )
                          : TextInputType.text,
                      inputFormatters:
                          widget.selectedCriteria == SearchCriteria.proximity
                              ? <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.,]'),
                                  ),
                                ]
                              : null,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: hintForSearchBar(widget.selectedCriteria),
                        prefixIcon: Icon(
                          widget.selectedCriteria == SearchCriteria.proximity
                              ? Icons.near_me_outlined
                              : Icons.search_rounded,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isCompact ? 14 : 15,
                        ),
                        suffixIcon: queryNameGroup.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: _clearQuery,
                              ),
                      ),
                      onChanged: (query) {
                        setState(() {
                          queryNameGroup = query;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<SearchCriteria>(
                    tooltip: 'Режим поиска',
                    initialValue: widget.selectedCriteria,
                    onSelected: _handleCriteriaChanged,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    itemBuilder: (context) {
                      return SearchCriteria.values.map((criteria) {
                        return PopupMenuItem<SearchCriteria>(
                          value: criteria,
                          child: Row(
                            children: [
                              Icon(criteriaToIcon(criteria), size: 18),
                              const SizedBox(width: 10),
                              Text(criteriaToString(criteria)),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: _OverlayActionChip(
                      icon: criteriaToIcon(widget.selectedCriteria),
                      label: criteriaToString(widget.selectedCriteria),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Фильтры и расписание',
                    child: IconButton(
                      onPressed: _openFiltersSheet,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            palette.surfaceMuted.withValues(alpha: 0.92),
                        foregroundColor: palette.accent,
                      ),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _OverlayInfoBadge(
                    icon: Icons.pin_drop_outlined,
                    label:
                        '${widget.displayedGroupsCount} из ${widget.allGroupsCount}',
                  ),
                  _OverlayInfoBadge(
                    icon: Icons.schedule_outlined,
                    label: _scheduleSummary(),
                  ),
                  if (widget.selectedCriteria == SearchCriteria.proximity)
                    _OverlayInfoBadge(
                      icon: Icons.near_me_outlined,
                      label: _currentPosition == null
                          ? 'Геопозиция нужна'
                          : 'Радиус, км',
                    ),
                ],
              ),
              if (widget.selectedCriteria == SearchCriteria.proximity &&
                  queryNameGroup.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _currentPosition == null
                        ? 'Разрешите доступ к местоположению, затем введите радиус в километрах.'
                        : 'Введите радиус в километрах, чтобы показать ближайшие группы.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (isWide && !widget.isToday && widget.todayTime == TimePeriod.none)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Дополнительные фильтры доступны по кнопке настройки.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
        if (queryNameGroup.isNotEmpty) SizedBox(height: isCompact ? 8 : 10),
        if (queryNameGroup.isNotEmpty)
          _MapOverlaySurface(
            padding: EdgeInsets.all(isCompact ? 8 : 10),
            radius: isCompact ? 18 : 20,
            surfaceOpacity: 0.8,
            shadowBlur: 14,
            child: (widget.selectedCriteria == SearchCriteria.proximity &&
                    _parseRadiusKm(queryNameGroup) == null) ||
                (widget.selectedCriteria == SearchCriteria.proximity &&
                    _currentPosition == null)
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        _resultsHintMessage(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : filteredGroups.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            _resultsHintMessage(),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: isCompact ? 260 : 320,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredGroups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final group = filteredGroups[index];
                            final distanceKm = widget.selectedCriteria ==
                                    SearchCriteria.proximity
                                ? _distanceKmForGroup(group)
                                : null;
                            return Material(
                              color: palette.surface.withValues(alpha: 0.84),
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  focusNode.unfocus();
                                  _clearQuery();
                                  widget.onGroupSelected(group);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    isCompact ? 12 : 14,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.nameOther,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        group.address ?? 'Адрес не указан',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          if (distanceKm != null)
                                            _MetaChip(
                                              icon: Icons.near_me_outlined,
                                              label:
                                                  '${distanceKm.toStringAsFixed(1)} км',
                                            ),
                                          _MetaChip(
                                            icon: Icons.schedule_outlined,
                                            label: groupSearchService
                                                .formatTiming(
                                                  group.workingTime,
                                                )
                                                .trim(),
                                          ),
                                          _MetaChip(
                                            icon: Icons.call_outlined,
                                            label: groupSearchService
                                                .formatPhone(group.phone)
                                                .trim(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
      ],
    );
  }

  String _timePeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.morning:
        return 'Утро';
      case TimePeriod.afternoon:
        return 'День';
      case TimePeriod.evening:
        return 'Вечер';
      case TimePeriod.none:
        return 'Все';
    }
  }
}

class _MapActionPanel extends StatelessWidget {
  const _MapActionPanel({
    required this.isClustered,
    required this.canFocusUser,
    required this.onClusterToggle,
    required this.onFocusCurrent,
  });

  final bool isClustered;
  final bool canFocusUser;
  final ValueChanged<bool> onClusterToggle;
  final VoidCallback onFocusCurrent;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return _MapOverlaySurface(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      radius: 20,
      surfaceOpacity: 0.74,
      shadowBlur: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Показать моё положение',
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: palette.surfaceMuted.withValues(alpha: 0.92),
                foregroundColor: palette.accent,
              ),
              onPressed: canFocusUser ? onFocusCurrent : null,
              icon: const Icon(Icons.my_location_rounded),
            ),
          ),
          const SizedBox(height: 6),
          Tooltip(
            message: isClustered
                ? 'Кластеры включены'
                : 'Кластеры выключены',
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: isClustered
                    ? palette.accentSoft.withValues(alpha: 0.92)
                    : palette.surfaceMuted.withValues(alpha: 0.92),
                foregroundColor:
                    isClustered ? palette.accent : Theme.of(context).hintColor,
              ),
              onPressed: () => onClusterToggle(!isClustered),
              icon: Icon(
                isClustered
                    ? Icons.grid_view_rounded
                    : Icons.scatter_plot_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum RouteMode {
  driving,
  transit,
  walking,
}

extension RouteModePresentation on RouteMode {
  String get label {
    switch (this) {
      case RouteMode.driving:
        return 'Авто';
      case RouteMode.transit:
        return 'Транспорт';
      case RouteMode.walking:
        return 'Пешком';
    }
  }

  IconData get icon {
    switch (this) {
      case RouteMode.driving:
        return Icons.directions_car_rounded;
      case RouteMode.transit:
        return Icons.directions_bus_rounded;
      case RouteMode.walking:
        return Icons.directions_walk_rounded;
    }
  }

  String get yandexRouteType {
    switch (this) {
      case RouteMode.driving:
        return 'auto';
      case RouteMode.transit:
        return 'mt';
      case RouteMode.walking:
        return 'pd';
    }
  }
}

class _SelectedGroupPanel extends StatelessWidget {
  const _SelectedGroupPanel({
    required this.group,
    required this.currentPosition,
    required this.onClose,
  });

  final GroupsAA group;
  final Position? currentPosition;
  final VoidCallback onClose;

  String? _buildYandexRouteUrl(RouteMode mode) {
    final destination = pointForGroup(group);
    final origin = currentPosition;
    if (destination == null || origin == null) {
      return null;
    }

    return Uri.https(
      'yandex.ru',
      '/maps/',
      <String, String>{
        'mode': 'routes',
        'rtext':
            '${origin.latitude},${origin.longitude}~${destination.latitude},${destination.longitude}',
        'rtt': mode.yandexRouteType,
        'll': '${destination.longitude},${destination.latitude}',
        'z': '15',
      },
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    final groupSearchService = GroupSearchService();
    final palette = context.appPalette;
    final isCompact = MediaQuery.sizeOf(context).width < 640;
    final canBuildRoute =
        currentPosition != null && pointForGroup(group) != null;
    final phone =
        group.phone?.isNotEmpty ?? false ? group.phone!.first.number : null;

    return _MapOverlaySurface(
      radius: isCompact ? 22 : 24,
      padding: EdgeInsets.all(isCompact ? 14 : 16),
      surfaceOpacity: 0.84,
      shadowBlur: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Выбранная группа',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      group.nameOther,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: isCompact
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: palette.surfaceMuted.withValues(alpha: 0.9),
                ),
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                overscroll: false,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if ((group.city?.isNotEmpty ?? false))
                          _MetaChip(
                            icon: Icons.location_city_outlined,
                            label: group.city!,
                          ),
                        if ((group.district?.isNotEmpty ?? false))
                          _MetaChip(
                            icon: Icons.map_outlined,
                            label: group.district!,
                          ),
                        if (group.metro?.isNotEmpty ?? false)
                          ...group.metro!.map(
                            (station) => _MetaChip(
                              icon: Icons.train_outlined,
                              label: station,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Маршрут',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: RouteMode.values.map((mode) {
                        final routeUrl = _buildYandexRouteUrl(mode);
                        return FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 11,
                            ),
                          ),
                          onPressed: routeUrl == null
                              ? null
                              : () => launchUrlString(
                                    routeUrl,
                                    mode: kIsWeb
                                        ? LaunchMode.platformDefault
                                        : LaunchMode.externalApplication,
                                  ),
                          icon: Icon(mode.icon),
                          label: Text(mode.label),
                        );
                      }).toList(),
                    ),
                    if (!canBuildRoute)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Для построения маршрута нужно разрешить доступ к геопозиции.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    const SizedBox(height: 12),
                    if ((group.address?.isNotEmpty ?? false))
                      TextAndIconRowWidget(
                        icon: const Icon(Icons.place_outlined),
                        text: group.address!,
                      ),
                    if (group.workingTime?.isNotEmpty ?? false)
                      TextAndIconRowWidget(
                        icon: const Icon(Icons.schedule_outlined),
                        text: groupSearchService.formatTiming(group.workingTime),
                      ),
                    if (group.phone?.isNotEmpty ?? false)
                      TextAndIconRowWidget(
                        icon: const Icon(Icons.call_outlined),
                        text: groupSearchService.formatPhone(group.phone),
                      ),
                    if ((group.infoPage?.isNotEmpty ?? false))
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: RichText(
                          text: TextSpan(
                            text: group.infoPage!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrlString(group.infoPage!);
                              },
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (group.infoPage?.isNotEmpty ?? false)
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => launchUrlString(group.infoPage!),
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text('Подробнее'),
                          ),
                        if (phone != null)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => launchUrlString(
                              'tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}',
                            ),
                            icon: const Icon(Icons.call_rounded),
                            label: const Text('Позвонить'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: palette.surfaceMuted.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: palette.border.withValues(alpha: 0.72),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: palette.accent.withValues(alpha: 0.88),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapOverlaySurface extends StatelessWidget {
  const _MapOverlaySurface({
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 22,
    this.surfaceOpacity = 0.78,
    this.shadowBlur = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double surfaceOpacity;
  final double shadowBlur;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: surfaceOpacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: palette.border.withValues(alpha: 0.58),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.shadow.withValues(alpha: 0.55),
                blurRadius: shadowBlur,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _OverlayActionChip extends StatelessWidget {
  const _OverlayActionChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surfaceMuted.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border.withValues(alpha: 0.72)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: palette.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.expand_more_rounded,
            size: 16,
            color: Theme.of(context).hintColor,
          ),
        ],
      ),
    );
  }
}

class _OverlayInfoBadge extends StatelessWidget {
  const _OverlayInfoBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: palette.surfaceMuted.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: palette.accent.withValues(alpha: 0.88),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

enum SearchCriteria {
  name,
  area,
  metro,
  address,
  proximity,
}
