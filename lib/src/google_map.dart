part of flutter_google_track_and_trace;

enum TimePrecision { updateOnly, everySecond, everyMinute }

class GoogleTrackTraceMap extends StatefulWidget {
  const GoogleTrackTraceMap({
    required this.onMapCreated,
    required this.startPosition,
    required this.destinationPosition,
    required this.googleAPIKey,
    required this.routeUpdateInterval,
    Key? key,
    this.markerUpdatePrecision = 50,
    this.timerPrecision = TimePrecision.everyMinute,
    this.travelMode = TravelMode.driving,
    this.cameraTargetBounds,
    this.compassEnabled = false,
    this.rotateGesturesEnabled = false,
    this.scrollGesturesEnabled = false,
    this.zoomControlsEnabled = false,
    this.zoomGesturesEnabled = false,
    this.liteModeEnabled = false,
    this.tiltGesturesEnabled = false,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.mapToolbarEnabled = false,
    this.mapType = MapType.normal,
    this.buildingsEnabled = false,
    this.indoorViewEnabled = false,
    this.trafficEnabled = false,
    this.retrieveDirections = true,
    this.mapStylingTheme,
    this.onTap,
    this.onArrived,
    this.onLongPress,
    this.onCameraMove,
    this.line,
  }) : super(key: key);

  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [TrackTraceController] for this [GoogleTrackTraceMap].
  /// this [TrackTraceController] also contains the [GoogleMapController]
  final void Function(TrackTraceController) onMapCreated;

  final TravelMode travelMode;

  final Duration routeUpdateInterval;

  /// amount of meter the marker needs to move to update
  final int markerUpdatePrecision;
  final TimePrecision timerPrecision;

  final Marker startPosition;
  final Marker destinationPosition;

  final Polyline? line;

  final bool compassEnabled;
  final bool rotateGesturesEnabled;
  final bool scrollGesturesEnabled;
  final bool liteModeEnabled;
  final bool tiltGesturesEnabled;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool retrieveDirections;
  final bool zoomControlsEnabled;
  final bool zoomGesturesEnabled;
  final bool mapToolbarEnabled;
  final bool buildingsEnabled;
  final bool indoorViewEnabled;
  final bool trafficEnabled;
  final CameraTargetBounds? cameraTargetBounds;
  final MapType mapType;
  final GoogleTrackTraceMapTheme? mapStylingTheme;

  final ArgumentCallback<LatLng>? onTap;
  final void Function()? onArrived;
  final ArgumentCallback<LatLng>? onLongPress;
  final CameraPositionCallback? onCameraMove;
  final String googleAPIKey;

  @override
  State createState() => _GoogleTrackTraceMapState();
}

class _GoogleTrackTraceMapState extends State<GoogleTrackTraceMap> {
  late final TrackTraceController controller;

  DateTime lastRouteUpdate = DateTime.now();

  Timer? routeCalculateTimer;
  Timer? markerUpdateTimer;

  @override
  void initState() {
    super.initState();
    controller =
        TrackTraceController(widget.startPosition, widget.destinationPosition);
    controller.addListener(
      () => setState(() {}),
    );
    widget.onMapCreated(controller);
    startRouteUpdateTimer();
    startMarkerUpdateTimer();
  }

  @override
  void dispose() {
    routeCalculateTimer?.cancel();
    markerUpdateTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      gestureRecognizers: {
        Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())
      },
      initialCameraPosition: calculateCameraPosition(
        controller.start.position,
        controller.end.position,
      ),
      onMapCreated: _onMapCreated,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onCameraMove: widget.onCameraMove,
      compassEnabled: widget.compassEnabled,
      rotateGesturesEnabled: widget.rotateGesturesEnabled,
      scrollGesturesEnabled: widget.scrollGesturesEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      zoomGesturesEnabled: widget.zoomGesturesEnabled,
      liteModeEnabled: widget.liteModeEnabled,
      tiltGesturesEnabled: widget.tiltGesturesEnabled,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      mapToolbarEnabled: widget.mapToolbarEnabled,
      mapType: widget.mapType,
      buildingsEnabled: widget.buildingsEnabled,
      indoorViewEnabled: widget.indoorViewEnabled,
      trafficEnabled: widget.trafficEnabled,
      markers: <Marker>{
        controller.start,
        controller.end,
      },
      polylines: <Polyline>{
        if (controller.route != null)
          (widget.line != null)
              ? widget.line!.copyWith(
                  pointsParam: controller.route!.line
                      .map((PointLatLng e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                )
              : Polyline(
                  // default PolyLine if none is provided
                  polylineId: const PolylineId('track&trace route'),
                  color: Theme.of(context).primaryColor,
                  width: 4,
                  points: controller.route!.line
                      .map((PointLatLng e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
      },
    );
  }

  void _onMapCreated(GoogleMapController ctr) {
    if (mounted) {
      controller.mapController = ctr;
      if (widget.mapStylingTheme != null) {
        ctr.setMapStyle(widget.mapStylingTheme!.getJson()).onError(
          (error, stackTrace) async {
            throw GoogleMapsException(error.toString());
          },
        );
      } else {
        // No theme provided so switching to default
        ctr.setMapStyle(
          '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]',
        );
      }
      controller.recenterCamera();
    }
  }

  CameraPosition calculateCameraPosition(LatLng pointA, LatLng pointB) {
    var target = LatLng(
      (pointA.latitude + pointB.latitude) / 2,
      (pointA.longitude + pointB.longitude) / 2,
    );
    return CameraPosition(
      target: target,
      zoom: 13.0,
      tilt: 0.0,
      bearing: 0.0,
    );
  }

  void startRouteUpdateTimer() {
    calculateRoute(); // run at the start
    routeCalculateTimer =
        Timer.periodic(widget.routeUpdateInterval, (Timer timer) {
      calculateRoute();
    });
  }

  void startMarkerUpdateTimer() {
    if (widget.timerPrecision != TimePrecision.updateOnly) {
      var updateInterval =
          (widget.timerPrecision == TimePrecision.everyMinute) ? 60 : 1;
      markerUpdateTimer =
          Timer.periodic(Duration(seconds: updateInterval), (timer) {
        if (mounted) {
          timer.cancel();
          return;
        }
        if (controller.route != null) {
          checkDestinationCloseBy();
          controller.route = TrackTraceRoute(
            (controller.route!.duration != 0)
                ? controller.route!.duration - updateInterval
                : 0,
            controller.route!.distance,
            controller.route!.line,
          );
        }
      });
    }
  }

  Future<void> calculateRoute() async {
    if (!widget.retrieveDirections) {
      return;
    }
    if (controller.route == null || checkTargetMoved()) {
      var directions =
          await DirectionsRepository() // TODO(freek): refactor this away
              .getDirections(
        origin: controller.start.position,
        destination: controller.end.position,
        mode: widget.travelMode,
        key: widget.googleAPIKey,
      );
      if (directions != null) {
        controller.route = TrackTraceRoute(
          directions.totalDuration,
          directions.totalDistance,
          directions.polylinePoints,
        );
        checkDestinationCloseBy();
        controller.recenterCamera();
        setState(() {
          lastRouteUpdate = DateTime.now();
        });
      }
    }
  }

  void checkDestinationCloseBy() {
    if (calculatePointProximity(
          controller.start.position,
          controller.end.position,
        ) <
        widget.markerUpdatePrecision) {
      routeCalculateTimer?.cancel();
      markerUpdateTimer?.cancel();
      if (controller.route != null) {
        controller.route!.line = <PointLatLng>[controller.route!.line[1]];
        controller.route!.distance = 0;
        controller.route!.duration = 0;
      }
      widget.onArrived?.call();
    }
  }

  bool checkTargetMoved() {
    return calculatePointProximity(
          controller.start.position,
          LatLng(
            controller.route!.line[0].latitude,
            controller.route!.line[0].longitude,
          ),
        ) >=
        widget.markerUpdatePrecision;
  }

  double calculatePointProximity(LatLng pointA, LatLng pointB) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c(
              (pointA.latitude - pointB.latitude) * p,
            ) /
            2 +
        c(controller.route!.line[0].latitude * p) *
            c(pointA.latitude * p) *
            (1 -
                c(
                  (pointA.longitude - pointB.longitude) * p,
                )) /
            2;
    return 12742 * asin(sqrt(a)) * 1000;
  }
}
