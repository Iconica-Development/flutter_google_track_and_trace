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
    this.routeLabel = '',
    this.compassEnabled = false,
    this.zoomControlsEnabled = false,
    this.zoomGesturesEnabled = false,
    this.mapToolbarEnabled = false,
    this.mapType = MapType.normal,
    this.buildingsEnabled = false,
  })  : assert(true),
        super(key: key);

  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [TrackTraceController] for this [GoogleTrackTraceMap].
  /// this [TrackTraceController] also contains the [GoogleMapController]
  final void Function(TrackTraceController) onMapCreated;

  final TravelMode travelMode;

  final String routeLabel;

  final int routeUpdateInterval;

  final TimePrecision timerPrecision;

  final Marker startPosition;
  final Marker destinationPosition;

  final bool compassEnabled;
  final bool zoomControlsEnabled;
  final bool zoomGesturesEnabled;
  final bool mapToolbarEnabled;
  final bool buildingsEnabled;
  final MapType mapType;

  CameraPosition initialCameraPosition = const CameraPosition(
      // doetinchem default initialCamera
      target: LatLng(51.965578, 6.293439),
      zoom: 12.0);

  final String googleAPIKey;

  @override
  State createState() => _GoogleTrackTraceMapState();
}

class _GoogleTrackTraceMapState extends State<GoogleTrackTraceMap> {
  late final TrackTraceController trackTraceController;

  Directions? route;
  DateTime lastRouteUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    trackTraceController =
        TrackTraceController(widget.startPosition, widget.destinationPosition);
    trackTraceController.addListener(_onChange);
    widget.onMapCreated(trackTraceController);
    startRouteUpdateTimer();
    startMarkerUpdateTimer();
  }

  @override
  void dispose() {
    trackTraceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        initialCameraPosition: calculateCameraPosition(
            trackTraceController.start.position,
            trackTraceController.end.position),
        onMapCreated: _onMapCreated,
        compassEnabled: widget.compassEnabled,
        zoomControlsEnabled: widget.zoomControlsEnabled,
        zoomGesturesEnabled: widget.zoomGesturesEnabled,
        mapToolbarEnabled: widget.mapToolbarEnabled,
        mapType: widget.mapType,
        buildingsEnabled: widget.buildingsEnabled,
        markers: {
          // style the markers
          trackTraceController.start,
          trackTraceController.end,
          if (trackTraceController.current != null)
            trackTraceController.current!,
        },
        polylines: {
          if (route != null)
            Polyline(
              polylineId: PolylineId(widget.routeLabel),
              color: Theme.of(context).primaryColor,
              width: 4,
              points: route!.polylinePoints
                  .map((e) => LatLng(e.latitude, e.longitude))
                  .toList(),
            ),
        });
  }

  void _onChange() {
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    if (mounted) {
      trackTraceController.mapController = controller;
      controller.setMapStyle(
          '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]'); // move to dart json file
    }
  }

  CameraPosition calculateCameraPosition(LatLng pointA, LatLng pointB) {
    LatLng target = LatLng((pointA.latitude + pointB.latitude) / 2,
        (pointA.longitude + pointB.longitude) / 2);
    double calculatedZoom = 13.0; // TODO calculate this zoom
    
    return CameraPosition(
        target: target, zoom: calculatedZoom, tilt: 0.0, bearing: 0.0);
  }

  void startRouteUpdateTimer() {
    calculateRoute(); // run at the start
    Timer.periodic(Duration(seconds: widget.routeUpdateInterval), (timer) {
      calculateRoute();
    });
  }

  void startMarkerUpdateTimer() {
    if (widget.timerPrecision != TimePrecision.updateOnly) {
      Timer.periodic(
          Duration(
              seconds: (widget.timerPrecision == TimePrecision.everyMinute)
                  ? 60
                  : 1), (timer) {
        updateDurationTimer();
      });
    }
  }

  void updateDurationTimer() {
    if (route != null) {
      trackTraceController.duration = route!.totalDuration -
          DateTime.now().difference(lastRouteUpdate).inSeconds;
    }
  }

  void calculateRoute() async {
    DirectionsRepository()
        .getDirections(
          origin: trackTraceController.start.position,
          destination: trackTraceController.end.position,
          mode: widget.travelMode,
          key: widget.googleAPIKey,
        )
        .then((value) => {
              trackTraceController.duration = value.totalDuration,
              trackTraceController.mapController.moveCamera(CameraUpdate.newCameraPosition(calculateCameraPosition(trackTraceController.start.position, trackTraceController.end.position))),
              setState(() {
                lastRouteUpdate = DateTime.now();
                route = value;
              })
            });
  }
}
