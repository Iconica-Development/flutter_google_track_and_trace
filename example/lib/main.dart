import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_track_trace/google_track_trace.dart';

class TrackTraceDemo extends StatefulWidget {
  const TrackTraceDemo({Key? key}) : super(key: key);

  @override
  State<TrackTraceDemo> createState() => _TrackTraceDemoState();
}

class _TrackTraceDemoState extends State<TrackTraceDemo> {
  late final TrackTraceController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TrackTrace example')),
      body: GoogleTrackTraceMap(
        startPosition: const Marker(
          markerId: MarkerId('Start locatie'),
          position: LatLng(51.965578, 6.293439),
        ),
        destinationPosition: const Marker(
          markerId: MarkerId('Eind locatie'),
          position: LatLng(51.958996, 6.296520),
        ),
        travelMode: TravelMode.bicycling,
        onMapCreated: (ctr) => {controller = ctr},
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: TrackTraceDemo(
  )));
}
