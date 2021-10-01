import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
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

  @override
  void initState() {
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
              featureType: 'poi',
              stylers: [
                {'visibility': 'off'},
              ],
            ),
            GoogleMapThemeFeature(
              featureType: 'transit',
              stylers: [
                {'visibility': 'off'},
              ],
            ),
            // GoogleMapThemeFeature(
            //   featureType: 'water',
            //   stylers: [
            //     {'color': '#00ff00'}
            //   ],
            // ),
            // GoogleMapThemeFeature(
            //   featureType: 'road',
            //   stylers: [
            //     {'color': '#000000'}
            //   ],
            // )
          ],
        ),
        startPosition: const Marker(
          markerId: MarkerId('Start locatie'),
          position: LatLng(52.356057, 4.897540),
        ),
        destinationPosition: const Marker(
          markerId: MarkerId('Bestemming Locatie'),
          position: LatLng(52.364709, 4.877157),
        ),
        googleAPIKey: 'AIzaSyDaxZX8TeQeVf5tW-D6A66WLl20arbWV6c',
        travelMode: TravelMode.walking,
        mapType: MapType.normal,
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
        position: LatLng(
          controller!.route!.line[step].latitude,
          controller!.route!.line[step].longitude,
        ),
      );
      step++;
      routeLength = controller!.route!.distance;
    }
  }
}

void main() {
  runApp(const MaterialApp(home: TrackTraceDemo()));
}
