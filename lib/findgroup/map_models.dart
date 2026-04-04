import 'package:aahelp/helper/utils.dart';
import 'package:geolocator/geolocator.dart';

const defaultMapPoint = MapPointData(
  latitude: 55.751453,
  longitude: 37.618737,
);

class MapPointData {
  const MapPointData({
    required this.latitude,
    required this.longitude,
  });

  factory MapPointData.fromCoordinates(Coordinates coordinates) {
    return MapPointData(
      latitude: double.parse(coordinates.lat),
      longitude: double.parse(coordinates.lon),
    );
  }

  factory MapPointData.fromPosition(Position position) {
    return MapPointData(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  final double latitude;
  final double longitude;
}

class MapCameraRequest {
  const MapCameraRequest({
    required this.token,
    required this.point,
    required this.zoom,
  });

  final int token;
  final MapPointData point;
  final double zoom;
}

MapPointData? pointForGroup(GroupsAA group) {
  final coordinates = group.coordinates;
  if (coordinates == null) {
    return null;
  }

  return MapPointData.fromCoordinates(coordinates);
}
