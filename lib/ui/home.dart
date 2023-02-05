import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "HOme";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    streamSubscription?.cancel();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  double defLat = 30.0358148;
  double defLong = 31.1989854;
  static CameraPosition RouteLocation = CameraPosition(
    target: LatLng(30.0358148, 31.1989854),
    zoom: 17.4746,
  );

  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: permissionStatus == PermissionStatus.deniedForever
            ? Text('please open loction')
            : Text("GPS Monday"),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition:
            MyCurrentLocation == null ? RouteLocation : MyCurrentLocation!,
        markers: markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

//AIzaSyCrZ4Wn4UiwJm0VqrVTKB77LgZD74yiuxw
  Location location = Location();

  PermissionStatus? permissionStatus;

  bool serviceEnabled = false;
  CameraPosition? MyCurrentLocation;
  LocationData? locationData;
  StreamSubscription<LocationData>? streamSubscription;

  void getCurrentLocation() async {
    bool permission = await IsPermissionGranted();
    if (permission == false) return;
    bool service = await IsServiceEnabled();
    if (!service) return;
    print("Hello Permission");
    locationData = await location.getLocation();
    print(
        "My Location > lat:${locationData?.latitude} long: ${locationData?.longitude}");

    streamSubscription = location.onLocationChanged.listen((event) {
      locationData = event;
      updateUserLocation();
      print(
          "My Location > lat:${locationData?.latitude} long: ${locationData?.longitude}");
    });
    print(
        "My Location > lat:${locationData?.latitude} long: ${locationData?.longitude}");

    Marker userMarker = Marker(
      markerId: MarkerId("UserLocation"),
      position: LatLng(
          locationData?.latitude ?? defLat, locationData?.longitude ?? defLong),
    );
    markers.add(userMarker);
    MyCurrentLocation = CameraPosition(
        target: LatLng(locationData!.latitude!, locationData!.longitude!),
        zoom: 16.151926040649414);
    final GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(MyCurrentLocation!));
    setState(() {});
  }

  void updateUserLocation() async {
    Marker userMarker = Marker(
      markerId: MarkerId("UserLocation"),
      position: LatLng(locationData!.latitude!, locationData!.longitude!),
    );
    markers.add(userMarker);
    final GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(MyCurrentLocation!));
    print('Event');
    setState(() {});
  }

  Future<bool> IsServiceEnabled() async {
    serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled == false) {
      serviceEnabled = await location.requestService();
      return serviceEnabled;
    }
    return serviceEnabled;
  }

  Future<bool> IsPermissionGranted() async {
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      return permissionStatus == PermissionStatus.granted;
    } else if (permissionStatus == PermissionStatus.deniedForever) {
      return false;
    } else {
      return permissionStatus == PermissionStatus.granted;
    }
  }
}
