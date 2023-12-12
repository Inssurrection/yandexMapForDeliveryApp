//import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_map_example/examples/widgets/control_button.dart';
import 'package:yandex_map_example/examples/widgets/map_page.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class DrivingPage extends MapPage {
  const DrivingPage() : super('Движение');

  @override
  Widget build(BuildContext context) {
    return _DrivingExample();
  }
}

class _DrivingExample extends StatefulWidget {
  @override
  _DrivingExampleState createState() => _DrivingExampleState();
}

class _DrivingExampleState extends State<_DrivingExample> {
  TextEditingController addressController = TextEditingController();
  String latitude = '';
  String longitude = '';
  late List<MapObject> mapObjects = [];
  late PlacemarkMapObject startPlacemark;
  late PlacemarkMapObject stopByPlacemark;
  late PlacemarkMapObject endPlacemark;

  @override
  void initState() {
    super.initState();

    _initializePlacemarks();
  }

  Future<void> _initializePlacemarks() async {
    Position currentPosition = await getCurrentLocation();

    startPlacemark = PlacemarkMapObject(
        mapId: MapObjectId('start_placemark'),
        point: Point(
            latitude: currentPosition.latitude,
            longitude: currentPosition.longitude),
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage(
              'lib/assets/route_start.png',
            ),
            scale: 0.7,
          ),
        ));
    stopByPlacemark = PlacemarkMapObject(
      mapId: MapObjectId('stop_by_placemark'),
      point: Point(latitude: 45.0360, longitude: 38.9746),
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image:
              BitmapDescriptor.fromAssetImage('lib/assets/route_stop_by.png'),
          scale: 0.3,
        ),
      ),
    );
    // endPlacemark = PlacemarkMapObject(
    //   mapId: MapObjectId('end_placemark'),
    //   point: Point(latitude: lat, longitude: longitude),
    //   icon: PlacemarkIcon.single(
    //     PlacemarkIconStyle(
    //       image: BitmapDescriptor.fromAssetImage('lib/assets/route_end.png'),
    //       scale: 0.3,
    //     ),
    //   ),
    // );

    setState(() {
      mapObjects = [startPlacemark, stopByPlacemark, endPlacemark];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        YandexMap(mapObjects: mapObjects),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: TextField(
                          controller: addressController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Введите адрес',
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        searchAddress();
                        _requestRoutes();
                      },
                      icon: Icon(Icons.search),
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.0), // Уменьшил высоту SizedBox
              Text(latitude),
              Text(longitude),
            ],
          ),
        ),
      ],
    );
  }


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

  Future<void> searchAddress() async {
    String address = addressController.text;

    List<Location> locations = await locationFromAddress(address);
    if (locations.isEmpty) {
      setState(() {
        latitude = 'Широта не найдена';
        longitude = 'Долгота не найдена';
      });
      return;
    }

    Location location = locations.first;
    double lat = location.latitude;
    double lon = location.longitude;

    setState(() {
      latitude = 'Широта: $lat';
      longitude = 'Долгота: $lon';

      endPlacemark = PlacemarkMapObject(
        mapId: MapObjectId('end_placemark'),
        point: Point(latitude: lat, longitude: lon),
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('E:/StudioProject/yandex_map_example/lib/assets/route_end.png'),
            scale: 0.3,
          ),
        ),
      );

      mapObjects = [startPlacemark, stopByPlacemark, endPlacemark];
    });
  }

  Future<void> _requestRoutes() async {
    print(
        'Points: ${startPlacemark.point},${stopByPlacemark.point},${endPlacemark.point}');

    var resultWithSession = YandexDriving.requestRoutes(
        points: [
          RequestPoint(
              point: startPlacemark.point,
              requestPointType: RequestPointType.wayPoint),
          RequestPoint(
              point: stopByPlacemark.point,
              requestPointType: RequestPointType.viaPoint),
          RequestPoint(
              point: endPlacemark.point,
              requestPointType: RequestPointType.wayPoint),
        ],
        drivingOptions: DrivingOptions(
            initialAzimuth: 0, routesCount: 5, avoidTolls: true));

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => _SessionPage(
                startPlacemark,
                endPlacemark,
                resultWithSession.session,
                resultWithSession.result)));
  }
}

class _SessionPage extends StatefulWidget {
  final Future<DrivingSessionResult> result;
  final DrivingSession session;
  final PlacemarkMapObject startPlacemark;
  final PlacemarkMapObject endPlacemark;

  _SessionPage(
      this.startPlacemark, this.endPlacemark, this.session, this.result);

  @override
  _SessionState createState() => _SessionState();
}

class _SessionState extends State<_SessionPage> {
  late final List<MapObject> mapObjects = [
    widget.startPlacemark,
    widget.endPlacemark
  ];

  final List<DrivingSessionResult> results = [];
  bool _progress = true;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void dispose() {
    super.dispose();

    _close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Маршрут № ${widget.session.id+1}')),
        body: Container(
            padding: EdgeInsets.all(8),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 500,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        YandexMap(mapObjects: mapObjects),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(children: <Widget>[
                    SizedBox(
                        height: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            !_progress
                                ? Container()
                                : TextButton.icon(
                                    icon: CircularProgressIndicator(),
                                    label: Text('Cancel'),
                                    onPressed: _cancel)
                          ],
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _getList(),
                              )),
                        ),
                      ],
                    ),
                  ])))
                ])));
  }

  List<Widget> _getList() {
    final list = <Widget>[];

    if (results.isEmpty) {
      list.add((Text('Nothing found')));
    }

    for (var r in results) {
      list.add(Container(height: 5));

      r.routes!.asMap().forEach((i, route) {
        list.add(
            Text('Маршрут № ${i+1}: ${route.metadata.weight.timeWithTraffic.text}', style: TextStyle(
              fontSize: 16.0,
            ),));
      });

      list.add(Container(height: 20));
    }

    return list;
  }

  Future<void> _cancel() async {
    await widget.session.cancel();

    setState(() {
      _progress = false;
    });
  }

  Future<void> _close() async {
    await widget.session.close();
  }

  Future<void> _init() async {
    await _handleResult(await widget.result);
  }

  Future<void> _handleResult(DrivingSessionResult result) async {
    setState(() {
      _progress = false;
    });

    if (result.error != null) {
      print('Error: ${result.error}');
      return;
    }

    setState(() {
      results.add(result);
    });
    setState(() {
      result.routes!.asMap().forEach((i, route) {
        mapObjects.add(PolylineMapObject(
          mapId: MapObjectId('route_${i}_polyline'),
          polyline: Polyline(points: route.geometry),
          strokeColor:
              Colors.primaries[Random().nextInt(Colors.primaries.length)],
          strokeWidth: 3,
        ));
      });
    });
  }
}
