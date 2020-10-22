import 'dart:async';
import 'dart:ui';
import 'package:algolia/algolia.dart';
import 'package:arquicart/models/Building.dart';
import 'package:arquicart/provider/AlgoliaProvider.dart';
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
import '../globals.dart';

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
  bool _showInfoCard = false, _loadingBuilding = false;
  LoadButtonStatus loadButtonStatus = LoadButtonStatus.hidden;
  Map<String, dynamic> _currentBuilding;
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
      if (_permissionStatus.isGranted) _goToCurrentLocation();
    } else if (await Permission.location.isGranted) {
      setState(() => _myLocationEnabled = true);
      _goToCurrentLocation();
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
  }

  _goToLocation(AlgoliaObjectSnapshot result) async {
    double lat = result.data['_geoloc']['lat'];
    double lng = result.data['_geoloc']['lng'];
    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, lng),
        zoom: 15,
      )),
    );
    _markers.add(
      Marker(
        markerId: MarkerId(result.objectID),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
        onTap: () => _showPrevBuilding({
          'objectID': result.objectID,
          ...result.data,
        }),
      ),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      _showPrevBuilding({
        'objectID': result.objectID,
        ...result.data,
      });
    });
  }

  _getBuildingsInArea() async {
    setState(() => loadButtonStatus = LoadButtonStatus.loading);

    LatLngBounds visibleRegion = await _mapController.getVisibleRegion();
    List<Map<String, dynamic>> snaps = await Provider.of<AlgoliaProvider>(
      context,
      listen: false,
    ).buildingsInArea(visibleRegion);

    snaps.forEach((snap) {
      final double lat = snap['_geoloc']['lat'];
      final double lng = snap['_geoloc']['lng'];
      _markers.add(
        Marker(
          markerId: MarkerId(snap['objectID']),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          onTap: () => _showPrevBuilding(snap),
        ),
      );
    });

    setState(() => loadButtonStatus = LoadButtonStatus.hidden);
  }

  _showPrevBuilding(prevData) {
    setState(() {
      _currentBuilding = prevData;
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
            onCameraMoveStarted: () => setState(
              () => loadButtonStatus = LoadButtonStatus.visible,
            ),
          ),
          // Building prev dialog
          _buildingPrevDialog(),
          // AppBar
          CustomAppBar(
            onResultTap: (result) => _goToLocation(result),
            onLoadButtonTap: _getBuildingsInArea,
            loadButtonStatus: loadButtonStatus,
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
          onTap: () async {
            setState(() => _loadingBuilding = true);
            Building building = await BuildingModel().getBuilding(
              _currentBuilding['objectID'],
            );
            setState(() => _loadingBuilding = false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(building: building),
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
              child: Stack(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: _currentBuilding['image'],
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
                                _currentBuilding['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _currentBuilding['description'],
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_loadingBuilding)
                    Positioned(
                      right: 8,
                      top: 0,
                      child: Container(
                        width: width - 140,
                        height: 3,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    )
                  else
                    SizedBox.shrink()
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
