part of google_track_trace;

typedef void MapCreatedCallback(TrackTraceController controller);

class GoogleTrackTraceMap extends StatefulWidget {
  GoogleTrackTraceMap({
    Key? key,
    this.initialCameraPosition = const CameraPosition(
        target: LatLng(51.965578, 6.293439),
        zoom: 15.0), // doetinchem default initialCamera
    this.onMapCreated,
    required this.startPosition,
    required this.destinationPosition,
    this.currentPosition,
    this.travelMode = TravelMode.Driving,
  })  : assert(true),
        super(key: key);

  CameraPosition initialCameraPosition;

  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [TrackTraceController] for this [GoogleTrackTraceMap].
  /// this [TrackTraceController] also contains the [GoogleMapController]
  final MapCreatedCallback? onMapCreated;

  final TravelMode travelMode;
  Marker? startPosition;
  Marker? destinationPosition;
  Marker? currentPosition;

  @override
  State createState() => _GoogleTrackTraceMapState();
}

class _GoogleTrackTraceMapState extends State<GoogleTrackTraceMap> {
  final Completer<TrackTraceController> _controller =
      Completer<TrackTraceController>();
  late final GoogleMapController _mapController;
  bool mapLoading = true;

  Directions? route; // this needs to be in the controller

  void _onMapCreated(GoogleMapController controller) {
    if (mounted) {
      _mapController = controller;
      controller.setMapStyle(
          '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
    }
  }

  CameraPosition calculateCameraPosition(LatLng pointA, LatLng pointB) {
    LatLng target = LatLng((pointA.latitude + pointB.latitude) / 2,
        (pointA.longitude + pointB.longitude) / 2);
    double calculatedZoom = 16.0;
    return CameraPosition(
        target: target, zoom: calculatedZoom, tilt: 0.0, bearing: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return (!mapLoading)
        ? GoogleMap(
            initialCameraPosition: calculateCameraPosition(
                widget.startPosition!.position,
                widget.destinationPosition!.position),
            onMapCreated: _onMapCreated,
            compassEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            mapType: MapType.normal,
            buildingsEnabled: false,
            markers: {
                // style the markers
                if (widget.startPosition != null) widget.startPosition!,
                if (widget.destinationPosition != null)
                  widget.destinationPosition!,
                if (widget.currentPosition != null) widget.currentPosition!,
              },
            polylines: {
                if (route != null)
                  Polyline(
                    polylineId: const PolylineId('Route van verzorger'),
                    color: const Color(0xFFFF7884),
                    width: 3,
                    points: route!.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  ),
              })
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              Text('Map is Loading'),
            ],
          );
  }

  @override
  void initState() {
    super.initState();
    updateMaps();
  }

  @override
  void dispose() async {
    super.dispose();
    TrackTraceController controller = await _controller.future;
    controller.dispose();
  }

  void updateMaps() async {
    if (route == null) {
      calculateRoute();
    }
    // get the current GPS data from the user
    // getLocationMarker().then((value) => {
    //       setState(() {
    //         _current = Marker(
    //           markerId: MarkerId('Huidige locatie'),
    //           position: LatLng(value.latitude, value.longitude),
    //         );
    //       })
    //     });
  }

  void calculateRoute() async {
    print('calculating route');
    if (widget.startPosition != null && widget.destinationPosition != null) {
      DirectionsRepository()
          .getDirections(
            origin: widget.startPosition!.position,
            destination: widget.destinationPosition!.position,
            mode: widget.travelMode,
            key: 'AIzaSyDaxZX8TeQeVf5tW-D6A66WLl20arbWV6c',
          )
          .then((value) => setState(() {
                route = value;
                mapLoading = false;
              }));
      // setState(() {
      //   route = directions;
      //   mapLoading = true;
      // });
    }
  }
}
