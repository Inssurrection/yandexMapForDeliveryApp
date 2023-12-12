import 'package:geolocator/geolocator.dart';

final Geolocator geolocator = Geolocator();

Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Проверка, включены ли службы геолокации
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw 'Службы геолокации отключены.';
  }

  // Проверка разрешения на использование местоположения
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Разрешение на использование местоположения отклонено.';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw 'Разрешение на использование местоположения отклонено навсегда.';
  }

  // Получение текущего местоположения
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
