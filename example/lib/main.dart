import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_track_trace/google_track_trace.dart';

class TrackTraceDemo extends StatefulWidget {
  const TrackTraceDemo({Key? key}) : super(key: key);

  @override
  State<TrackTraceDemo> createState() => _TrackTraceDemoState();
}

class _TrackTraceDemoState extends State<TrackTraceDemo> {
  TrackTraceController? controller;
  int step = 1;
  int routeLength = 0;
  late final Timer timer;
  BitmapDescriptor? startMarkerIcon;
  BitmapDescriptor? destinationMarkerIcon;

  @override
  void initState() {
    loadBitmapImages();
    timer = Timer.periodic(const Duration(seconds: 2), (_) {
      moveAlongRoute();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (controller == null || controller!.route == null)
            ? const Text('TrackTrace example')
            : Text(
                '${controller!.route!.duration} seconds, afstand: '
                '${controller!.route!.distance / 1000} km',
              ),
      ),
      body: GoogleTrackTraceMap(
        mapStylingTheme: GoogleTrackTraceMapTheme(
          themes: [
            GoogleMapThemeFeature(
              featureType: 'all',
              stylers: [
                {'saturation': '-50'},
                //{'invert_lightness': 'true'},
              ],
            ),
            GoogleMapThemeFeature(
              featureType: 'landscape.natural.landcover',
              stylers: [
                {'color': '#00ff00'},
              ],
            ),
            GoogleMapThemeFeature(
              featureType: 'poi',
              stylers: [
                {'visibility': 'off'},
              ],
            ),
            GoogleMapThemeFeature(
              featureType: 'poi.park',
              stylers: [
                {'visibility': 'on'},
              ],
            ),
            GoogleMapThemeFeature(
              featureType: 'transit',
              stylers: [
                {'visibility': 'off'},
              ],
            ),
          ],
        ),
        startPosition: Marker(
          markerId: MarkerId('Start locatie'),
          anchor: Offset(0.5, 0.5),
          position: LatLng(52.356057, 4.897540),
          icon: startMarkerIcon ?? BitmapDescriptor.defaultMarker,
        ),
        destinationPosition: Marker(
          markerId: MarkerId('Bestemming Locatie'),
          anchor: Offset(0.5, 0.5),
          position: LatLng(52.364709, 4.877157),
          icon: destinationMarkerIcon ?? BitmapDescriptor.defaultMarker,
        ),
        buildingsEnabled: false,
        googleAPIKey: 'AIzaSyDaxZX8TeQeVf5tW-D6A66WLl20arbWV6c',
        travelMode: TravelMode.walking,
        mapType: MapType.normal,
        indoorViewEnabled: false,
        routeUpdateInterval: Duration(seconds: 30),
        timerPrecision: TimePrecision.everySecond,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        line: const Polyline(
          jointType: JointType.bevel,
          polylineId: PolylineId('test route'),
          color: Color(0xFFFF7884),
          width: 3,
        ),
        onArrived: () {
          timer.cancel();
          debugPrint('stopping simulation');
        },
        onTap: (value) {
          debugPrint(value.toString());
        },
        onLongPress: (value) {
          debugPrint(value.toString());
        },
        onCameraMove: (value) {
          debugPrint(value.toString());
        },
        onMapCreated: (ctr) => {
          controller = ctr,
          ctr.addListener(() {
            setState(() {
              if (ctr.route != null && ctr.route!.distance != routeLength) {
                step = 1;
              }
            });
          }),
        },
      ),
    );
  }

  Future<void> loadBitmapImages() async {
    var loadedPicture = await rootBundle.load('assets/profile_picture.png');
    var bitmap = await convertBytesToCustomBitmapDescriptor(
      loadedPicture.buffer.asUint8List(),
      size: 80,
      addBorder: true,
      borderColor: Colors.grey,
      title: 'Alex',
      titleBackgroundColor: Color(0xffff7884),
    );

    startMarkerIcon = bitmap;
    var bitmapDescriptor = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(100, 100)),
      'assets/ic_location_on.png',
    );
    setState(() {
      destinationMarkerIcon = bitmapDescriptor;
      controller?.end = Marker(
        anchor: Offset(0.5, 0.5),
        markerId: MarkerId('Bestemming Locatie'),
        position: LatLng(52.364709, 4.877157),
        icon: bitmapDescriptor,
      );
    });
  }

  void getRandomPointOnMap() {
    // 51.989909, 6.234950 NW
    // 51.939909, 6.314950 SE
    if (controller != null) {
      controller!.start = Marker(
        markerId: const MarkerId('Start Locatie'),
        position: LatLng(
          51.93 + Random().nextDouble() * 0.06,
          6.23 + Random().nextDouble() * 0.08,
        ),
      );
    }
  }

  void moveAlongRoute() {
    if (controller != null &&
        controller!.route != null &&
        controller!.route!.line.length > 1) {
      controller!.start = Marker(
        markerId: const MarkerId('Start Locatie'),
        anchor: Offset(0.5, 0.5),
        position: LatLng(
          controller!.route!.line[step].latitude,
          controller!.route!.line[step].longitude,
        ),
        icon: startMarkerIcon ?? BitmapDescriptor.defaultMarker,
      );
      step++;
      routeLength = controller!.route!.distance;
    }
  }
}

void main() {
  runApp(const MaterialApp(home: TrackTraceDemo()));
}
