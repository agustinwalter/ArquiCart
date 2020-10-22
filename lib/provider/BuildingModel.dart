import 'package:arquicart/models/Building.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';

class BuildingModel extends ChangeNotifier {
  List<Building> buildings = [];
  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage(
    storageBucket: 'gs://arquicart-1568227470001.appspot.com/',
  );
  final buildingsColl =
      bool.fromEnvironment('dart.vm.product') ? 'buildings' : 'buildings-dev';

  // Create or update a building
  Future<String> setBuilding(Building building) async {
    DocumentReference docRef = await db.collection(buildingsColl).add({
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

  Future<Building> getBuilding(String buildingId) async {
    DocumentSnapshot snap =
        await db.collection(buildingsColl).doc(buildingId).get();
    return Building(
      uid: snap.id,
      name: snap.data()['name'],
      architects: snap.data()['architects'],
      address: snap.data()['address'],
      description: snap.data()['description'],
      extraData: snap.data()['extraData'],
      location: snap.data()['location'],
      images: snap.data()['images'],
      publishedBy: snap.data()['publishedBy'],
    );
  }

  Future<void> uploadImages(String docId, List<Asset> images) async {
    for (int i = 0; i < images.length; i++) {
      List<String> a = images[i].name.split('.');
      String ext = a[a.length - 1];
      String name = Uuid().v4();
      String path = '$buildingsColl/$name.$ext';
      ByteData byteData = await images[i].getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      StorageUploadTask uploadTask =
          storage.ref().child(path).putData(imageData);
      StorageTaskSnapshot snap = await uploadTask.onComplete;
      String url = await snap.ref.getDownloadURL();
      await db.doc('$buildingsColl/$docId').update({
        'images': FieldValue.arrayUnion([url]),
      });
    }
    return null;
  }

  Future<String> getAndSetAddress(String buildingId, GeoPoint location) async {
    String address = '';
    final coordinates = Coordinates(location.latitude, location.longitude);
    List<Address> addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    address = addresses.first.addressLine;
    await db.doc('$buildingsColl/$buildingId').update({
      'address': address,
    });
    return address;
  }
}
