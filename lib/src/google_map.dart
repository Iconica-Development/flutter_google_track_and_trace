part of google_track_trace;

// typedef void MapCreatedCallback(TrackTraceController controller);
enum TimePrecision { updateOnly, everySecond, everyMinute }

class GoogleTrackTraceMap extends StatefulWidget {
  GoogleTrackTraceMap({
    Key? key,
    required this.onMapCreated,
    required this.startPosition,
    required this.destinationPosition,
    required this.googleAPIKey,
    required this.routeUpdateInterval,
    this.timerPrecision = TimePrecision.everyMinute,
    this.travelMode = TravelMode.driving,
    this.compassEnabled = false,
    this.zoomControlsEnabled = false,
    this.zoomGesturesEnabled = false,
    this.mapToolbarEnabled = false,
    this.mapType = MapType.normal,
    this.buildingsEnabled = false,
    this.mapMarkations =
        '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]',
    this.line,
  })  : assert(true),
        super(key: key);

  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [TrackTraceController] for this [GoogleTrackTraceMap].
  /// this [TrackTraceController] also contains the [GoogleMapController]
  final void Function(TrackTraceController) onMapCreated;

  final TravelMode travelMode;

  final int routeUpdateInterval;

  final TimePrecision timerPrecision;

  final Marker startPosition;
  final Marker destinationPosition;

  Polyline? line;

  final bool compassEnabled;
  final bool zoomControlsEnabled;
  final bool zoomGesturesEnabled;
  final bool mapToolbarEnabled;
  final bool buildingsEnabled;
  final MapType mapType;

  final String mapMarkations;

  CameraPosition initialCameraPosition = const CameraPosition(
      // doetinchem default initialCamera
      target: LatLng(51.965578, 6.293439),
      zoom: 12.0);

  final String googleAPIKey;

  @override
  State createState() => _GoogleTrackTraceMapState();
}

class _GoogleTrackTraceMapState extends State<GoogleTrackTraceMap> {
  late final TrackTraceController controller;

  DateTime lastRouteUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    controller =
        TrackTraceController(widget.startPosition, widget.destinationPosition);
    controller.addListener(_onChange);
    widget.onMapCreated(controller);
    startRouteUpdateTimer();
    startMarkerUpdateTimer();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        initialCameraPosition: calculateCameraPosition(
            controller.start.position, controller.end.position),
        onMapCreated: _onMapCreated,
        compassEnabled: widget.compassEnabled,
        zoomControlsEnabled: widget.zoomControlsEnabled,
        zoomGesturesEnabled: widget.zoomGesturesEnabled,
        mapToolbarEnabled: widget.mapToolbarEnabled,
        mapType: widget.mapType,
        buildingsEnabled: widget.buildingsEnabled,
        markers: {
          controller.start,
          controller.end,
        },
        polylines: {
          if (controller.route != null)
            (widget.line != null)
                ? widget.line!.copyWith(
                    pointsParam: controller.route!.line
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList())
                : Polyline(
                    // default PolyLine if none is provided
                    polylineId: const PolylineId('track&trace route'),
                    color: Theme.of(context).primaryColor,
                    width: 4,
                    points: controller.route!.line
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  ),
        });
  }

  void _onChange() {
    setState(() {});
  }

  void _onMapCreated(GoogleMapController ctr) {
    if (mounted) {
      controller.mapController = ctr;
      ctr.setMapStyle(widget.mapMarkations); // move to dart json file
    }
  }

  CameraPosition calculateCameraPosition(LatLng pointA, LatLng pointB) {
    LatLng target = LatLng((pointA.latitude + pointB.latitude) / 2,
        (pointA.longitude + pointB.longitude) / 2);
    double calculatedZoom = 13.0; // TODO calculate this zoom

    return CameraPosition(
        target: target, zoom: calculatedZoom, tilt: 0.0, bearing: 0.0);
  }

  CameraUpdate moveCameraToCenter(LatLng pointA, LatLng pointB) {
    return CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            min(pointA.latitude, pointB.latitude),
            min(pointA.longitude, pointB.longitude),
          ),
          northeast: LatLng(
            max(pointA.latitude, pointB.latitude),
            max(pointA.longitude, pointB.longitude),
          ),
        ),
        50);
  }

  void startRouteUpdateTimer() {
    calculateRoute(); // run at the start
    Timer.periodic(Duration(seconds: widget.routeUpdateInterval), (timer) {
      calculateRoute();
    });
  }

  void startMarkerUpdateTimer() {
    if (widget.timerPrecision != TimePrecision.updateOnly) {
      int updateInterval =
          (widget.timerPrecision == TimePrecision.everyMinute) ? 60 : 1;
      Timer.periodic(Duration(seconds: updateInterval), (timer) {
        if (controller.route != null) {
          controller.route = TrackTraceRoute(
              controller.route!.duration - updateInterval,
              controller.route!.distance,
              controller.route!.line);
        }
      });
    }
  }

  void calculateRoute() async {
    DirectionsRepository() //TODO refactor this away
        .getDirections(
          origin: controller.start.position,
          destination: controller.end.position,
          mode: widget.travelMode,
          key: widget.googleAPIKey,
        )
        .then((value) => {
              controller.route = TrackTraceRoute(value.totalDuration,
                  value.totalDistance, value.polylinePoints),
              if (controller.mapController != null)
                {
                  controller.mapController!.moveCamera(moveCameraToCenter(
                      controller.start.position, controller.end.position)),
                },
              setState(() {
                lastRouteUpdate = DateTime.now();
              })
            });
  }
}
