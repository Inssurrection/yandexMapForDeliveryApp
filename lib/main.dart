import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_map_example/examples/widgets/map_page.dart';
import 'package:yandex_map_example/examples/circle_map_object_page.dart';
import 'package:yandex_map_example/examples/clusterized_placemark_collection_page.dart';
import 'package:yandex_map_example/examples/bicycle_page.dart';
import 'package:yandex_map_example/examples/driving_page.dart';
import 'package:yandex_map_example/examples/map_controls_page.dart';
import 'package:yandex_map_example/examples/map_object_collection_page.dart';
import 'package:yandex_map_example/examples/placemark_map_object_page.dart';
import 'package:yandex_map_example/examples/polyline_map_object_page.dart';
import 'package:yandex_map_example/examples/polygon_map_object_page.dart';
import 'package:yandex_map_example/examples/reverse_search_page.dart';
import 'package:yandex_map_example/examples/search_page.dart';
import 'package:yandex_map_example/examples/suggest_page.dart';
import 'package:yandex_map_example/examples/user_layer_page.dart';

void main() {
  runApp(MaterialApp(home: MainPage()));
}

const List<MapPage> _allPages = <MapPage>[
 /* MapControlsPage(),
  ClusterizedPlacemarkCollectionPage(),
  MapObjectCollectionPage(),
  PlacemarkMapObjectPage(),
  PolylineMapObjectPage(),
  PolygonMapObjectPage(),
  CircleMapObjectPage(),
  UserLayerPage(),
  SuggestionsPage(),
  SearchPage(),
  ReverseSearchPage(),
  BicyclePage(),*/
  DrivingPage(),
];

class MainPage extends StatelessWidget {
  void _pushPage(BuildContext context, MapPage page) {
    Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) =>
            Scaffold(
                appBar: AppBar(title: Text(page.title)),
                body: Container(
                    padding: const EdgeInsets.all(8),
                    child: page
                )
            )
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Доставка продукции')),
        body: Column(
            children: <Widget>[
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const YandexMap()
                  )
              ),
              Expanded(
                  child: ListView.builder(
                    itemCount: _allPages.length,
                    itemBuilder: (_, int index) => ListTile(
                      title: Text(_allPages[index].title),
                      onTap: () => _pushPage(context, _allPages[index]),
                    ),
                  )
              )
            ]
        )
    );
  }
}

