import 'dart:io';

import 'package:arquicart/models/Building.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class BuildingModel extends ChangeNotifier {
  List<Building> buildings = [];

  // Get all buildings
  Future<List<Building>> getAllBuildings() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('buildings')
        .where('approved', isEqualTo: true)
        .get();
    // if (querySnapshot.size > 0) {
      for (var doc in querySnapshot.docs) {
        buildings.add(Building(
          uid: doc.id,
          name: doc.data()['name'],
          description: doc.data()['description'],
          address: doc.data()['address'],
          location: doc.data()['location'],
          architects: doc.data()['architects'],
          extraData: doc.data()['extraData'],
          images: doc.data()['images'],
          publishedBy: doc.data()['publishedBy'],
        ));
      }
      notifyListeners();
      return buildings;
    // }
  }

  // Create or update a building
  Future<String> setBuilding(Building building) async {
    // Map<String, dynamic> data = {
    //   'direction': building.direction,
    //   'lat': building.lat,
    //   'lon': building.lon,
    //   'approved': false,
    //   'publishedBy': building.publishedBy,
    //   'geohash': building.geohash,
    // };
    // if (building.name != '') data['name'] = building.name;
    // if (building.architect != '') data['architect'] = building.architect;
    // if (building.studio != '') data['studio'] = building.studio;
    // if (building.yearBegin != '') data['yearBegin'] = building.yearBegin;
    // if (building.yearEnd != '') data['yearEnd'] = building.yearEnd;
    // if (building.yearOpen != '') data['yearOpen'] = building.yearOpen;
    // if (building.description != '') data['description'] = building.description;
    // DocumentReference docRef =
    //     await FirebaseFirestore.instance.collection('buildings').add(data);
    // return docRef.id;
  }

  Future<void> uploadImages(String docId, List<File> images) async {
    final FirebaseStorage storage = FirebaseStorage(
      storageBucket: 'gs://arquicart-1568227470001.appspot.com/',
    );
    for (int i = 0; i < images.length; i++) {
      String path = 'buildings/$docId-$i.jpg';
      StorageUploadTask uploadTask =
          storage.ref().child(path).putFile(images[i]);
      StorageTaskSnapshot snap = await uploadTask.onComplete;
      String url = await snap.ref.getDownloadURL();
      await FirebaseFirestore.instance.doc('buildings/$docId').update({
        'images': FieldValue.arrayUnion([url]),
      });
    }
    return null;
  }
}
