import 'dart:async';
import 'package:arquicart/models/Building.dart';
import 'package:arquicart/provider/BuildingModel.dart';
import 'package:arquicart/screens/DetailsScreen.dart';
import 'package:arquicart/widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-37.6482898, -63.535327),
    zoom: 5,
  );
  Completer<GoogleMapController> _mapCompleter = Completer();
  bool _myLocationEnabled = false;
  final Set<Marker> _markers = Set();
  BitmapDescriptor pinLocationIcon;
  GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapCompleter.complete(controller);
    _mapController = controller;
    _getLocationPermision();
  }

  Future<void> _getLocationPermision() async {
    if (await Permission.location.isUndetermined ||
        await Permission.location.isDenied) {
      PermissionStatus _permissionStatus = await Permission.location.request();
      setState(() => _myLocationEnabled = _permissionStatus.isGranted);
      if (_permissionStatus.isGranted) {
        _goToCurrentLocation();
      } else {
        _get50Buildings('geohash');
      }
    } else if (await Permission.location.isGranted) {
      setState(() => _myLocationEnabled = true);
      _goToCurrentLocation();
    } else {
      _get50Buildings('geohash');
    }
  }

  _goToCurrentLocation() async {
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15,
    )));
    _get50Buildings('geohash');
  }

  _get50Buildings(String geohash) async {
    List<Building> buildings = await BuildingModel().get50Buildings(geohash);

    BitmapDescriptor pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/img/point.png',
    );
    buildings.forEach((building) {
      _markers.add(
        Marker(
          markerId: MarkerId(building.uid),
          position: LatLng(building.lat, building.lon),
          infoWindow: InfoWindow(
            title: building.name,
            snippet: building.direction,
          ),
          icon: pinLocationIcon,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(
                  building: building,
                ),
              ),
            );
          },
        ),
      );
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            myLocationEnabled: _myLocationEnabled,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            padding: EdgeInsets.only(top: 100),
            markers: _markers,
          ),
          // AppBar
          CustomAppBar(),
        ],
      ),
    );
  }
}
