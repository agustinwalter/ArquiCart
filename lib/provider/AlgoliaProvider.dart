import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';

class AlgoliaProvider extends ChangeNotifier {
  Algolia algolia;
  final index =
      bool.fromEnvironment('dart.vm.product') ? 'buildings' : 'buildings-dev';

  init() {
    algolia = Algolia.init(
      applicationId: 'SHYON2W3LY',
      apiKey: 'a4d7e5b7648d20588233ed97ad112dff',
    );
  }

  Future<List<AlgoliaObjectSnapshot>> search(String param) async {
    AlgoliaQuerySnapshot snap = await algolia.instance
        .index(index)
        .search(param)
        .setPage(0)
        .setHitsPerPage(3)
        .getObjects();
    return snap.hits;
  }

  Future<List<Map<String, dynamic>>> buildingsInArea(visibleRegion) async {
    BoundingBox boundingBox = BoundingBox(
      p1Lat: visibleRegion.southwest.latitude,
      p1Lng: visibleRegion.northeast.longitude,
      p2Lat: visibleRegion.northeast.latitude,
      p2Lng: visibleRegion.southwest.longitude,
    );
    AlgoliaQuerySnapshot snap = await algolia.instance
        .index(index)
        .search('')
        .setInsideBoundingBox([boundingBox])
        .setHitsPerPage(1000)
        .getObjects();
    List<Map<String, dynamic>> res = [];
    for (var hit in snap.hits) {
      res.add({
        'objectID': hit.objectID,
        ...hit.data,
      });
    }
    return res;
  }
}
