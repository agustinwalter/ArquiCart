import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';

class AlgoliaProvider extends ChangeNotifier {
  Algolia algolia;

  init() {
    algolia = Algolia.init(
      applicationId: 'SHYON2W3LY',
      apiKey: 'a4d7e5b7648d20588233ed97ad112dff',
    );
  }

  Future<List<AlgoliaObjectSnapshot>> search(String param) async {
    AlgoliaQuerySnapshot snap = await algolia.instance
        .index('buildings')
        .search(param)
        .setPage(0)
        .setHitsPerPage(3)
        .getObjects();
    return snap.hits;
  }
}
