import 'package:arquicart/models/Building.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';

class BuildingModel extends ChangeNotifier {
  List<Building> buildings = [];
  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage(
    storageBucket: 'gs://arquicart-1568227470001.appspot.com/',
  );
  
  // Get all buildings
  Future<List<Building>> getAllBuildings() async {
    QuerySnapshot querySnapshot = await db
        .collection('buildings')
        .where('approved', isEqualTo: true)
        .get();
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
  }

  // Create or update a building
  Future<String> setBuilding(Building building) async {
    DocumentReference docRef = await db.collection('buildings').add({
      'name': building.name,
      'architects': building.architects,
      'address': building.address,
      'description': building.description,
      'location': building.location,
      'publishedBy': building.publishedBy,
      'approved': building.approved,
      'extraData': building.extraData,
    });
    return docRef.id;
  }

  Future<void> uploadImages(String docId, List<Asset> images) async {
    for (int i = 0; i < images.length; i++) {
      List<String> a = images[i].name.split('.');
      String ext = a[a.length - 1];
      String name = Uuid().v4(); 
      String path = 'buildings/$name.$ext';
      ByteData byteData = await images[i].getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      StorageUploadTask uploadTask =
          storage.ref().child(path).putData(imageData);
      StorageTaskSnapshot snap = await uploadTask.onComplete;
      String url = await snap.ref.getDownloadURL();
      await db.doc('buildings/$docId').update({
        'images': FieldValue.arrayUnion([url]),
      });
    }
    return null;
  }
}
