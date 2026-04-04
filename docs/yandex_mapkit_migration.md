# Проверка проекта и замена OSM на Yandex MapKit

Дата проверки: 2026-04-03

## Что есть сейчас

- Карта используется только в `lib/findgroup/find_map.dart`.
- Текущая реализация построена на `flutter_map` + `flutter_map_marker_cluster`.
- Источник тайлов: OpenStreetMap `https://tile.openstreetmap.org/{z}/{x}/{y}.png`.
- Данные групп, поиск, фильтрация по времени и расстоянию не зависят от картографической библиотеки.

## Найденные проблемы в текущем экране карты

- В `lib/findgroup/find_map.dart` маркер текущей позиции добавляется до завершения `_determinePosition()`, поэтому он создаётся с координатами `(0, 0)` и потом не пересоздаётся.
- В `lib/findgroup/find_map.dart` контроллер карты не освобождается: используется `_mapController.dispose;`, а не вызов метода.
- В `lib/findgroup/find_map.dart` выбор группы привязан к `nameOther`, а не к `companyId`. При совпадающих названиях карточка группы будет открываться неоднозначно.
- В `lib/findgroup/find_map.dart` и `lib/helper/utils.dart` есть проверки вида `list != []`. Для Dart это почти всегда логическая ошибка, потому что сравниваются ссылки, а не содержимое.

## Ограничения перед миграцией

- В репозитории уже есть локальные изменения в `lib/findgroup/find_map.dart`, `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml` и `lib/helper/utils.dart`.
- В проекте отсутствует `ios/Podfile`, поэтому iOS-интеграция любого MapKit SDK сейчас не доведена до состояния "готово к правке".
- Пакет `yandex_mapkit` поддерживает только Android и iOS. Для `web`, `windows`, `linux`, `macos` потребуется оставить текущий OSM fallback или делать отдельную реализацию.

## Что рекомендую по выбору SDK

- Если нужен именно пакет `yandex_mapkit`, его можно внедрять в этот экран без переработки модели данных.
- Если нужен путь с официальной текущей Flutter-документацией Yandex, стоит смотреть в сторону `yandex_maps_mapkit_lite` или `yandex_maps_mapkit`.
- Для этого проекта прагматичный вариант такой: мобильные платформы перевести на Yandex, а для остальных оставить OSM-экран.

## Схема замены в коде

### 1. Зависимости

В `pubspec.yaml`:

```yaml
dependencies:
  yandex_mapkit: ^4.2.1
```

Если нужен fallback для `web` и desktop, `flutter_map` пока не убирать.

### 2. Замена контроллера и маркеров

В `lib/findgroup/find_map.dart` заменить:

- `MapController` на `YandexMapController`
- `Marker` на `PlacemarkMapObject`
- `MarkerClusterLayerWidget` на `ClusterizedPlacemarkCollection`
- `LatLng` на `Point`

Правильная привязка объекта карты:

```dart
PlacemarkMapObject(
  mapId: MapObjectId(group.companyId),
  point: Point(
    latitude: double.parse(group.coordinates!.lat),
    longitude: double.parse(group.coordinates!.lon),
  ),
  onTap: (_, __) {
    setState(() {
      selectedGroupId = group.companyId;
    });
    panelController.open();
  },
)
```

Это убирает проблему с коллизиями `nameOther`.

### 3. Центрирование карты

Текущий `centerMap(LatLng coordinates)` заменить на асинхронное перемещение камеры:

```dart
Future<void> centerMap(Point point) async {
  await _mapController.moveCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(target: point, zoom: 18.5),
    ),
  );
}
```

### 4. Текущая геопозиция

Маркер пользователя нужно строить только после получения координат и хранить отдельно от списка групп.

Рекомендуемая схема:

- `_groupMapObjects` только для групп
- `_userLocationObject` только для текущей позиции
- итоговый список `mapObjects = [..._groupMapObjects, if (_userLocationObject != null) _userLocationObject!]`

### 5. Кластеризация

Для режима "Группировать" использовать `ClusterizedPlacemarkCollection`.
Для режима без группировки отдавать обычный список `PlacemarkMapObject`.

### 6. Поиск

Поиск можно оставить почти без изменений:

- `BuildFloatingSearchBar` продолжает фильтровать `GroupsAA`
- при выборе элемента вызывается `centerMap(Point(...))`
- открытие панели лучше делать по `companyId`

## Android

Для `yandex_mapkit` нужен нативный SDK и API-ключ.

### `android/gradle.properties`

```properties
yandexMapkit.variant=lite
```

### `android/app/build.gradle.kts`

Нужна зависимость native SDK в секции `dependencies`:

```kotlin
dependencies {
    implementation("com.yandex.android:maps.mobile:4.22.0-lite")
}
```

### `android/app/src/main/kotlin/.../MainApplication.kt`

Нужен собственный `Application`, где задаются `locale` и `apiKey`.

Рекомендация:

- не хардкодить ключ в репозитории
- читать его из `BuildConfig`, `manifestPlaceholders` или из отдельного локального файла, который игнорируется Git

### `android/app/src/main/AndroidManifest.xml`

В теге `<application>` заменить `android:name` на свой `MainApplication`.

## iOS

Для iOS в текущем состоянии сначала нужно вернуть `ios/Podfile` в репозиторий или сгенерировать его заново.

После этого:

- выставить платформу не ниже `12.0`
- задать `ENV['YANDEX_MAPKIT_VARIANT'] = 'lite'`
- в `ios/Runner/AppDelegate.swift` импортировать `YandexMapsMobile`
- вызвать `YMKMapKit.setLocale(...)`
- вызвать `YMKMapKit.setApiKey(...)`

## Что менять в проекте в первую очередь

1. Исправить текущие логические ошибки экрана карты.
2. Принять решение по платформам: только Android/iOS или нужен fallback.
3. Определиться с пакетом: `yandex_mapkit` или официальный `yandex_maps_mapkit_lite`.
4. После этого уже переносить `find_map.dart`.

## Рекомендуемый путь для этого проекта

- Если приложение реально целится только в телефон, можно полностью убрать OSM и перейти на Yandex.
- Если нужно сохранить сборки для web и desktop, лучше сделать платформенное ветвление:
  мобильные платформы используют Yandex, остальные остаются на OSM.
- Перед миграцией имеет смысл сначала вернуть идентификацию группы по `companyId` и починить маркер текущей позиции.
