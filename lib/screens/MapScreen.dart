import 'dart:async';
import 'package:arquicart/widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-37.6482898, -63.535327),
    zoom: 5,
  );
  Completer<GoogleMapController> _controller = Completer();
  bool _myLocationEnabled = false;
  final Set<Marker> _markers = Set();
  BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    _getLocationPermision();

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/img/point.png',
    ).then((onValue) {
      pinLocationIcon = onValue;

      _markers.add(
        Marker(
          markerId: MarkerId('newyork'),
          position: LatLng(-37.6482898, -63.535327),
          infoWindow: InfoWindow(
            title: 'New York',
            snippet: 'Welcome to New York',
          ),
          icon: pinLocationIcon,
        ),
      );
    });

    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) =>
      _controller.complete(controller);

  Future<void> _getLocationPermision() async {
    if (await Permission.location.isUndetermined ||
        await Permission.location.isDenied) {
      PermissionStatus _permissionStatus = await Permission.location.request();
      setState(() => _myLocationEnabled = _permissionStatus.isGranted);
    } else if (await Permission.location.isGranted) {
      setState(() => _myLocationEnabled = true);
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
