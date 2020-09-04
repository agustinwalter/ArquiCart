import 'dart:io';

import 'package:arquicart/models/Building.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class BuildingModel extends ChangeNotifier {
  List<Building> buildings = [];

  // Get 50 buildings nearby to that geohash
  Future<List<Building>> get50Buildings(String geohash) {
    return Future.delayed(const Duration(milliseconds: 500), () {
      buildings.addAll([
        Building(
          uid: '1',
          name: 'Edificio 1',
          direction: 'Dirección 1',
          lat: -32.784243,
          lon: -60.732185,
          images: [
            'https://i.pinimg.com/736x/97/c8/ae/97c8aead46d4911f32c1d98f942be1f8.jpg',
            'https://i.pinimg.com/736x/a0/6f/4c/a06f4cffd3a889ed3304324723e6f97b.jpg',
            'https://www.arkiplus.com/wp-content/uploads/2016/02/dise%C3%B1o-edificios-modernos.jpg',
            'https://i.ytimg.com/vi/2GLS-TsCpdY/maxresdefault.jpg',
            'https://images.adsttc.com/media/images/5cda/f8ec/284d/d10f/9600/000c/medium_jpg/4-4.jpg'
          ],
        ),
        Building(
          uid: '2',
          name: 'Edificio 2',
          direction: 'Dirección 2',
          lat: -32.794238,
          lon: -60.728980,
        ),
      ]);
      notifyListeners();
      return buildings;
    });
  }

  // Create or update a building
  Future<String> setBuilding(Building building) async {
    Map<String, dynamic> data = {
      'direction': building.direction,
      'lat': building.lat,
      'lon': building.lon,
      'approved': false,
      'publishedBy': building.publishedBy,
      'geohash': building.geohash,
    };
    if (building.name != '') data['name'] = building.name;
    if (building.architect != '') data['architect'] = building.architect;
    if (building.studio != '') data['studio'] = building.studio;
    if (building.yearBegin != '') data['yearBegin'] = building.yearBegin;
    if (building.yearEnd != '') data['yearEnd'] = building.yearEnd;
    if (building.yearOpen != '') data['yearOpen'] = building.yearOpen;
    if (building.description != '') data['description'] = building.description;
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('buildings').add(data);
    return docRef.id;
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
