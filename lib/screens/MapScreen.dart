import 'dart:async';
import 'dart:ui';
import 'package:arquicart/models/Building.dart';
import 'package:arquicart/provider/BuildingModel.dart';
import 'package:arquicart/provider/UserModel.dart';
import 'package:arquicart/screens/DetailsScreen.dart';
import 'package:arquicart/screens/SetBuildingScreen.dart';
import 'package:arquicart/widgets/CustomAppBar.dart';
import 'package:arquicart/widgets/LoginDialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

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
  GoogleMapController _mapController;
  bool _showInfoCard = false;
  Building _currentBuilding;
  List<Building> buildings;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _getLocationPermision();
    _mapCompleter.complete(controller);
    _mapController = controller;
    _mapController.setMapStyle(
      '[{"featureType":"poi","stylers":[{"visibility":"off"}]}]',
    );
  }

  Future<void> _getLocationPermision() async {
    // Si no pedi permiso, lo pido
    if (await Permission.location.isUndetermined ||
        await Permission.location.isDenied) {
      PermissionStatus _permissionStatus = await Permission.location.request();
      setState(() => _myLocationEnabled = _permissionStatus.isGranted);
      if (_permissionStatus.isGranted) {
        _goToCurrentLocation();
      } else {
        _getAllBuildings();
      }
    } else if (await Permission.location.isGranted) {
      setState(() => _myLocationEnabled = true);
      _goToCurrentLocation();
    } else {
      _getAllBuildings();
    }
  }

  _goToCurrentLocation() async {
    try {
      Position position = await getLastKnownPosition();
      if (position == null) {
        position = await getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }
      _mapController
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      )));
    } catch (e) {}
    _getAllBuildings();
  }

  _goToLocation(double lat, double lon, String buildingId) async {
    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, lon),
        zoom: 15,
      )),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      _showPrevBuilding(
        buildings.firstWhere((building) => building.uid == buildingId),
      );
    });
  }

  _getAllBuildings() async {
    buildings = await BuildingModel().getAllBuildings();
    buildings.forEach((building) {
      final double lat = building.location.latitude;
      final double lon = building.location.longitude;
      _markers.add(
        Marker(
          markerId: MarkerId(building.uid),
          position: LatLng(lat, lon),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          onTap: () => _showPrevBuilding(building),
        ),
      );
    });
    setState(() {});
  }

  _showPrevBuilding(Building building) {
    setState(() {
      _currentBuilding = building;
      _showInfoCard = true;
    });
  }

  _goToAddBuilding() {
    if (Provider.of<UserModel>(context, listen: false).currentUser == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => LoginDialog(
          fromFab: true,
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SetBuildingScreen()),
      );
    }
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
            padding: EdgeInsets.only(top: 100, bottom: _showInfoCard ? 120 : 0),
            markers: _markers,
            onTap: (argument) => setState(() => _showInfoCard = false),
          ),
          // Building prev dialog
          _buildingPrevDialog(),
          // AppBar
          CustomAppBar(
            onResultTap: (lat, lon, buildingId) =>
                _goToLocation(lat, lon, buildingId),
          ),
        ],
      ),
      floatingActionButton: !_showInfoCard
          ? FloatingActionButton(
              onPressed: _goToAddBuilding,
              backgroundColor: Color(0xFF3c8bdc),
              tooltip: 'Agregar edificio',
              child: Icon(
                Icons.add_location,
                size: 32,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildingPrevDialog() {
    double width = MediaQuery.of(context).size.width;
    if (_currentBuilding != null) {
      return AnimatedPositioned(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
        bottom: _showInfoCard ? 20 : -130,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(building: _currentBuilding),
              ),
            );
          },
          child: Container(
            width: width,
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 16),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: _currentBuilding.images[0],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: width - 148,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentBuilding.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _currentBuilding.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
