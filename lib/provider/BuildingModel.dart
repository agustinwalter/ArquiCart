import 'package:arquicart/models/Building.dart';
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
  setBuilding(Building building) {}
}
