import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/helper/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
  State<FindMapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<FindMapWidget> {
  List<GroupsAA>? _groups = [];
  List<Marker> _markers = [];
  late MapController _mapController;
  SearchCriteria selectedCriteria = SearchCriteria.name;
  Position? _currentPosition;
  double? _panelHeightOpen;
  final PanelController panelController = PanelController();
  String? selectedNamegroup;
  bool isGroup = true;

  @override
  void initState() {
    super.initState();
    _groups = widget.groups;
    _mapController = MapController();
    loadMarkerList(_groups!);
  }

  void updateMap() {
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant FindMapWidget oldWidget) {
    // if (oldWidget.groups.first.nameOther != _groups?.first.nameOther) {
    setState(() {
      _groups = widget.groups;
      loadMarkerList(_groups!);
    });
    //  }
    super.didUpdateWidget(oldWidget);
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
    _determinePosition();
    _markers.add(positionMarker());
  }

// Местоположение пользователя
  Marker positionMarker() {
    return Marker(
      point: LatLng(_currentPosition?.latitude ?? 0.0,
          _currentPosition?.longitude ?? 0.0),
      child: Icon(
        Icons.gps_fixed_outlined,
        size: 20,
        color: Colors.black,
      ),
    );
  }

  Marker buildMarker(LatLng coordinates, String word, String id) {
    return Marker(
      key: Key(id),
      width: 100,
      height: 60,
      point: coordinates,
      child: Container(
        height: 40,
        width: 100,
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              word,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 8.0),
            ),
            Icon(
              Icons.home,
              size: 20,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  void centerMap(LatLng coordinates) {
    setState(() {
      // Обновляем состояние карты с новыми координатами
      _mapController.move(coordinates, 18.5);
    });
  }

// Определяем текушую позицию
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle case when location services are not enabled
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        // Если пользователь отказался включить службы геолокации, можно показать соответствующее сообщение
        return;
      }
    }
    permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle case when location permissions are denied
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle case when location permissions are permanently denied
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _mapController.move(
        LatLng(
          _currentPosition?.latitude ?? 0.0,
          _currentPosition?.longitude ?? 0.0,
        ),
        10.5,
      );
    });

    debugPrint('Текущая позиция = $position');
  }

  Widget _panel(ScrollController sc, GroupsAA? group) {
    final GroupSearchService groupSearchService = GroupSearchService();
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 12, 10, 60),
      child: ListView(
        controller: sc,
        children: [
          Center(
            child: TextAndIconRowWidget(
              icon: Icon(Icons.people),
              text: ' ${group?.nameOther}',
            ),
          ),
          if (group?.city != null && group?.city != '')
            TextAndIconRowWidget(
              icon: Icon(Icons.house),
              text: ' ${group?.city}',
            ),
          if (group?.district != null && group?.district != '')
            TextAndIconRowWidget(
              icon: Icon(Icons.area_chart),
              text: ' ${group?.district}',
            ),
          if (group?.metro != null && group?.metro != [])
            TextAndIconRowWidget(
              icon: Icon(Icons.train),
              text: ' ${group?.metro}',
            ),
          if (group?.workingTime != null && group?.workingTime != [])
            TextAndIconRowWidget(
              icon: Icon(Icons.schedule),
              text:
                  ' \n ${groupSearchService.formatTiming(group?.workingTime)}',
            ),
          if (group?.address != null && group?.address != '')
            TextAndIconRowWidget(
                icon: Icon(Icons.location_city), text: ' ${group?.address}'),
          if (group?.phone != null && group?.phone != [])
            TextAndIconRowWidget(
              icon: Icon(Icons.phone),
              text: '\n ${groupSearchService.formatPhone(group?.phone)}',
            ),
          if (group?.infoPage != null && group?.infoPage != '')
            Text(
              'Дополнительная информация: ',
              style: AppTextStyle.valuesstyle,
            ),
          RichText(
            text: TextSpan(
              text: '${group?.infoPage}',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrlString('${group?.infoPage}');
                },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose;
    super.dispose();
  }

  GroupsAA? findGroupByID(String? id) {
    GroupsAA? foundGroup;
    if (_groups != null && _groups != []) {
      for (var group in _groups!) {
        if (group.companyId == id) {
          foundGroup = group;
          break;
        }
      }
      return foundGroup;
    } else {
      return null;
    }
  }

  // Метод для вычисления расстояния между двумя точками
  double _calculateDistance(LatLng a, LatLng b) {
    final dx = a.latitude - b.latitude;
    final dy = a.longitude - b.longitude;
    return dx * dx + dy * dy; // Квадрат расстояния (для оптимизации)
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;
    return Stack(
      children: [
        SlidingUpPanel(
          controller: panelController,
          defaultPanelState: PanelState.CLOSED,
          maxHeight: _panelHeightOpen!,
          minHeight: 0.0,
          parallaxEnabled: true,
          parallaxOffset: .5,
          border: Border.all(width: 2.5, color: Colors.black),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          backdropEnabled: true,
          backdropColor: Colors.white,
          panelBuilder: (sc) => _panel(sc, findGroupByID(selectedNamegroup)),
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(55.751453, 37.618737),
                  initialZoom: 10.5,
                  keepAlive: true,
                  onTap: (tapPosition, latLng) {
                    // Проверяем, был ли нажат маркер
                    if (!isGroup) {
                      final tappedGroup = _groups?.firstWhere(
                        (group) =>
                            group.coordinates != null &&
                            _calculateDistance(
                                  LatLng(
                                    double.parse(group.coordinates!.lat),
                                    double.parse(group.coordinates!.lon),
                                  ),
                                  latLng,
                                ) <
                                0.000001, // Пороговое значение для нажатия
                      );
                      if (tappedGroup != null) {
                        setState(() {
                          selectedNamegroup = tappedGroup.companyId;
                          panelController.open();
                        });
                      }
                    }
                  },
                ),
                mapController: _mapController,
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  isGroup
                      ? MarkerClusterLayerWidget(
                          options: MarkerClusterLayerOptions(
                            maxClusterRadius: 120,
                            size: const Size(40, 40),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(50),
                            maxZoom: 15,
                            markers: _markers,
                            builder: (context, markers) {
                              return Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.blue),
                                child: Center(
                                  child: Text(
                                    markers.length.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                            onMarkerTap: (marker) {
                              setState(() {
                                panelController.open();
                                selectedNamegroup =
                                    (marker.key as ValueKey).value as String;
                              });
                            },
                          ),
                        )
                      : MarkerLayer(markers: _markers),
                ],
              ),
              BuildFloatingSearchBar(
                centerMap: centerMap,
                groups: _groups ?? [],
                selectedCriteria: selectedCriteria,
                todayTime: widget.todayTime,
                isToday: widget.isToday,
                currentPosition: _currentPosition,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 60,
          right: 10,
          child: ExpandableFab(
            searchCriteria: SearchCriteria.values,
            onSelected: (criteria) {
              setState(() {
                selectedCriteria = criteria;
              });
            },
          ),
        ),
        Positioned(
          top: 50,
          right: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BeautifulText(
                text: isGroup ? 'Не группировать?' : 'Группировать?',
                fontSize: 14,
                color: Colors.deepPurple.shade400,
              ),
              Checkbox(
                side: BorderSide(
                  width: 1.5,
                  color: Colors.deepPurple,
                ),
                semanticLabel: isGroup ? 'Не группировать?' : 'Группировать?',
                value: isGroup,
                onChanged: (bool? newvalue) {
                  setState(() {
                    isGroup = newvalue!;
                    updateMap();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Поиск
class BuildFloatingSearchBar extends StatefulWidget {
  final Function(LatLng)
      centerMap; // Принимаем колбек-функцию через конструктор
  final Position? currentPosition;
  final List<GroupsAA> groups;
  final SearchCriteria selectedCriteria;
  final TimePeriod todayTime;
  final bool isToday;
  const BuildFloatingSearchBar(
      {super.key,
      required this.centerMap,
      required this.groups,
      required this.selectedCriteria,
      required this.todayTime,
      required this.isToday,
      required this.currentPosition});

  @override
  State<BuildFloatingSearchBar> createState() => _BuildFloatingSearchBarState();
}

class _BuildFloatingSearchBarState extends State<BuildFloatingSearchBar> {
  String queryNameGroup = '';
  List<GroupsAA> _groups = [];
  final GroupSearchService groupSearchService = GroupSearchService();
  FloatingSearchBarController panelController = FloatingSearchBarController();
  late Position? _currentPosition;

  @override
  void initState() {
    _groups = widget.groups;
    _currentPosition = widget.currentPosition;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BuildFloatingSearchBar oldWidget) {
    _groups = widget.groups;
    _currentPosition = widget.currentPosition;
    super.didUpdateWidget(oldWidget);
  }

  // Фильтрация групп по близости
  List<GroupsAA> filterGroupsByProximity(double maxDistance) {
    List<GroupsAA> nearbyGroups = _groups
        .where((group) =>
            group.coordinates != null &&
            _currentPosition != null &&
            Geolocator.distanceBetween(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                        double.parse(group.coordinates!.lat),
                        double.parse(group.coordinates!.lon)) /
                    1000 <=
                maxDistance)
        .toList();
    return nearbyGroups;
  }

  Future<List<GroupsAA>> filterGroups(SearchCriteria searchCriteria) async {
    List<GroupsAA> filterGroups = _groups;
    switch (searchCriteria) {
      case SearchCriteria.name:
        filterGroups = filterGroups.where((group) {
          // Убираем префикс "Группа АА " из названия группы
          String groupName = group.nameOther.replaceFirst('Группа АА ', '');
          return groupName
              .toLowerCase()
              .startsWith(queryNameGroup.toLowerCase());
        }).toList();
      case SearchCriteria.metro:
        filterGroups = filterGroups
            .where((group) =>
                group.metro != null &&
                group.metro != [] &&
                group.metro!.any((station) => station
                    .toLowerCase()
                    .startsWith(queryNameGroup.toLowerCase() as Pattern)))
            .toList();
      case SearchCriteria.area:
        filterGroups = filterGroups
            .where((group) =>
                group.district != null &&
                group.district != '' &&
                group.district!
                    .toLowerCase()
                    .startsWith(queryNameGroup.toLowerCase() as Pattern))
            .toList();
      case SearchCriteria.address:
        filterGroups = filterGroups.where(
          (group) {
            if (group.address != null) {
              return group.address!
                  .toLowerCase()
                  .contains(queryNameGroup.toLowerCase() as Pattern);
            }
            return false;
          },
        ).toList();
      case SearchCriteria.proximity:
        filterGroups =
            filterGroupsByProximity(double.tryParse(queryNameGroup) ?? 0.0);
    }
    // if (_groups != []) {
    //   return await groupSearchService.filterGroupsByTime(
    //     widget.todayTime,
    //     filterGroups,
    //     widget.isToday,
    //   ); // утро, день, вечер
    // } else
    return filterGroups;
  }

  bool isAddingCharacter(String currentText, String previousText) {
    // Функция для проверки, был ли добавлен символ
    return currentText.length > previousText.length;
  }

  bool isRemovingOrChangingCharacter(String currentText, String previousText) {
    // Функция для проверки, был ли удален или изменен символ
    if (currentText.length < previousText.length) {
      return true; // Если длина текущего текста меньше предыдущего, символ был удален
    } else {
      // Проверяем каждый символ для определения, был ли изменен символ
      for (int i = 0; i < previousText.length; i++) {
        if (i >= currentText.length || currentText[i] != previousText[i]) {
          return true;
        }
      }
      return false;
    }
  }

  @override
  void dispose() {
    panelController.dispose();
    super.dispose();
  }

  String hintForSearchBar(SearchCriteria criteria) {
    switch (criteria) {
      case SearchCriteria.name:
        return 'Введите название группы...';
      case SearchCriteria.area:
        return 'Введите район поиска...';
      case SearchCriteria.metro:
        return 'Введите метро...';
      case SearchCriteria.address:
        return 'Введите адрес...';
      case SearchCriteria.proximity:
        return 'Введите радиус поиска в км..';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      automaticallyImplyDrawerHamburger: false,
      automaticallyImplyBackButton: false,
      debounceDelay: Duration(seconds: 1),
      hint: hintForSearchBar(widget.selectedCriteria),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      controller: panelController,
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      // debounceDelay: const Duration(milliseconds: 300),
      onQueryChanged: (query) {
        setState(() {
          queryNameGroup = query;
        });

        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: (queryNameGroup != '')
                ? FutureBuilder<List<GroupsAA>>(
                    future: filterGroups(widget.selectedCriteria),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Ошибка: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Нет данных'));
                      } else {
                        List<GroupsAA> groups = snapshot.data!;
                        return Column(
                          // shrinkWrap: true,
                          children: queryNameGroup == ''
                              ? List.empty()
                              : groups.map((group) {
                                  return Container(
                                    margin: EdgeInsets.all(8),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColor.cardColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        panelController.close();
                                        // Вызываем колбек-функцию с координатами выбранного маркера
                                        widget.centerMap(
                                          LatLng(
                                            double.parse(
                                                group.coordinates!.lat),
                                            double.parse(
                                                group.coordinates!.lon),
                                          ),
                                        );
                                      },
                                      title: Text(
                                        group.nameOther,
                                        style: AppTextStyle.valuesstyle,
                                      ),
                                      subtitle: Column(
                                        children: [
                                          Text(
                                            'Адрес: ${group.address}',
                                            style: AppTextStyle.spantextstyle,
                                          ),
                                          Text(
                                            'Время работы: \n ${groupSearchService.formatTiming(group.workingTime)}',
                                            style: AppTextStyle.spantextstyle,
                                          ),
                                          Text(
                                            'Телефон: \n ${groupSearchService.formatPhone(group.phone)}',
                                            style: AppTextStyle.spantextstyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                        );
                      }
                    },
                  )
                : null,
          ),
        );
      },
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

// Выбор критериев поиска
class ExpandableFab extends StatefulWidget {
  final List<SearchCriteria> searchCriteria;
  final Function(SearchCriteria) onSelected;
  const ExpandableFab(
      {super.key, required this.searchCriteria, required this.onSelected});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  SearchCriteria? _criteria;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFab(),
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: 1.0,
          child: Column(
            children: widget.searchCriteria.map((criteria) {
              // _criteria = criteria;
              return _buildFabOption(criteria);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      heroTag: "search_fab",
      onPressed: () {
        if (_controller.isDismissed) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      child: Column(
        children: [
          _criteria == null
              ? Text('Поиск')
              : Text(criteriaToString(_criteria!)),
          Icon(Icons.search),
        ],
      ),
    );
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

  Widget _buildFabOption(SearchCriteria criteria) {
    return ScaleTransition(
      scale: _expandAnimation,
      child: FloatingActionButton(
        heroTag: "search_fab_${criteria.toString()}",
        onPressed: () {
          setState(() {
            _criteria = criteria; // Обновляем выбранный критерий
          });
          widget.onSelected(criteria);
          _controller.reverse();
        },
        child: _getIconForCriteria(criteria),
      ),
    );
  }

  Widget _getIconForCriteria(SearchCriteria criteria) {
    switch (criteria) {
      case SearchCriteria.name:
        return Column(
          children: [
            Text('Группа'),
            Icon(Icons.person),
          ],
        );

      case SearchCriteria.area:
        return Column(
          children: [
            Text('Район'),
            Icon(Icons.location_city),
          ],
        );
      case SearchCriteria.metro:
        return Column(
          children: [
            Text('Метро'),
            Icon(Icons.train),
          ],
        );
      case SearchCriteria.address:
        return Column(
          children: [
            Text('Адрес'),
            Icon(Icons.home),
          ],
        );
      case SearchCriteria.proximity:
        return Column(
          children: [
            Text('Рядом'),
            Icon(Icons.location_on),
          ],
        );
    }
  }
}
