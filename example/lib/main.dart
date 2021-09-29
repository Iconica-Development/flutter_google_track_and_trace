import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_track_trace/google_track_trace.dart';

class TrackTraceDemo extends StatefulWidget {
  const TrackTraceDemo({Key? key}) : super(key: key);

  @override
  State<TrackTraceDemo> createState() => _TrackTraceDemoState();
}

class _TrackTraceDemoState extends State<TrackTraceDemo> {
  TrackTraceController? controller;

  @override
  void initState() {
    // TODO: implement initState
    Timer.periodic(const Duration(seconds: 10), (_) {
      print('updating marker');
      getRandomPointOnMap();
    });

    Timer.periodic(const Duration(seconds: 60), (_) {
      print('updating route');
      getRandomRoute();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: (controller == null)
              ? const Text('TrackTrace example')
              : Text(controller!.duration.toString() + ' seconds')),
      body: GoogleTrackTraceMap(
        startPosition: const Marker(
          markerId: MarkerId('Start locatie'),
          position: LatLng(51.965578, 6.293439),
        ),
        destinationPosition: const Marker(
          markerId: MarkerId('Eind locatie'),
          position: LatLng(51.958996, 6.296520),
        ),
        googleAPIKey: 'AIzaSyDaxZX8TeQeVf5tW-D6A66WLl20arbWV6c',
        travelMode: TravelMode.walking,
        routeUpdateInterval: 60,
        routeLabel: 'Test route',
        timerPrecision: TimePrecision.everySecond,
        zoomGesturesEnabled: true,
        onMapCreated: (ctr) => {
          controller = ctr,
          ctr.addListener(() {
            setState(() {});
          }),
        },
      ),
    );
  }

  void updateMap() {
    controller!.current = const Marker(
      markerId: MarkerId('Huidige locatie'),
      position: LatLng(51.962578, 6.294439),
    );
  }

  void getRandomPointOnMap() {
    // 51.989909, 6.234950

    // 51.939909, 6.314950
    if (controller != null) {
      controller!.current = Marker(
          markerId: MarkerId('Huidige Locatie'),
          position: LatLng(51.93 + Random().nextDouble() * 0.06,
              6.23 + Random().nextDouble() * 0.08));
    }
  }

  void getRandomRoute() {
    // if (route != null) {
    //   print('removing point');
    //   PointLatLng point = route!.polylinePoints[1];
    //   trackTraceController.startMarker = Marker(
    //       markerId: MarkerId('Start locatie'),
    //       position: LatLng(point.latitude, point.longitude));
    // }
    if (controller != null) {
      controller!.start = Marker(
          markerId: MarkerId('Start Locatie'),
          position: LatLng(51.93 + Random().nextDouble() * 0.06,
              6.23 + Random().nextDouble() * 0.08));
      controller!.end = Marker(
          markerId: MarkerId('Bestemming Locatie'),
          position: LatLng(51.93 + Random().nextDouble() * 0.06,
              6.23 + Random().nextDouble() * 0.08));
    }
  }
}

void main() {
  runApp(const MaterialApp(home: TrackTraceDemo()));
}
