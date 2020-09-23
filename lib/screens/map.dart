import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:travego/providers/auth.dart';
import 'package:travego/providers/places.dart';

import 'details.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map';

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with ChangeNotifier {
  final Location _userLocation = Location();
  LocationData _locationData;
  PermissionStatus _permissionGranted;
  bool _serviceEnabled;
  bool _gettingLocation = true;
  var _height;
  List<Marker> markers = [];

  Future<void> _requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final PermissionStatus permissionRequestedResult =
          await _userLocation.requestPermission();
      setState(() {
        _permissionGranted = permissionRequestedResult;
      });
      if (permissionRequestedResult != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<void> _requestService() async {
    if (_serviceEnabled == null || !_serviceEnabled) {
      final bool serviceRequestedResult = await _userLocation.requestService();
      setState(() {
        _serviceEnabled = serviceRequestedResult;
      });
      if (!serviceRequestedResult) {
        return;
      }
    }
  }

  Future<void> _getLocation() async {
    try {
      final LocationData _locationResult = await _userLocation.getLocation();
      setState(() {
        _locationData = _locationResult;
      });
    } on PlatformException catch (err) {
      throw err;
    }
  }

  @override
  void initState() {
    _requestPermission().then((_) =>
        _requestService().then((_) => _getLocation().then((_) => setState(() {
              _gettingLocation = false;
            }))));
    Provider.of<Places>(context, listen: false).fetchPlaces().then((_) {
      markers = Provider.of<Places>(context, listen: false).places.map((place) {
        return Marker(
          markerId: MarkerId(place.name),
          onTap: () => _placeDetails(
            id: place.id,
            category: place.category,
          ),
          position: LatLng(
            place.latitude,
            place.longitude,
          ),
        );
      }).toList();
    });
    super.initState();
  }

  void _placeDetails({
    @required int id,
    @required String category,
  }) {
    Navigator.of(context).pushNamed(DetailsScreen.routeName, arguments: {
      'id': id,
      'category': category,
    });
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: _gettingLocation
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: _height / 39.885714285714285,
                  ),
                  Text('جارٍ الحصول على موقعك'),
                ],
              ),
            )
          : Stack(
              children: <Widget>[
                GoogleMap(
                  markers: {...markers},
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _locationData.latitude,
                      _locationData.longitude,
                    ),
                    zoom: 16,
                  ),
                ),
                Positioned(
                    top: 40,
                    right: 0,
                    child: RawMaterialButton(
                      onPressed: () {
                        Provider.of<Auth>(context, listen: false)
                            .logout(context);
                      },
                      elevation: 2.0,
                      fillColor: Colors.deepPurple,
                      child: Icon(
                        Icons.exit_to_app,
                        size: 15.0,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(15.0),
                      shape: CircleBorder(),
                    ))
              ],
            ),
    );
  }
}
