part of google_track_trace;

class TrackTraceController extends ChangeNotifier {
  TrackTraceController(Marker start, Marker destination)
      : _startPosition = start,
        _destinationPosition = destination;

  GoogleMapController? mapController;
  Marker _startPosition;
  Marker _destinationPosition;
  TrackTraceRoute? _route;

  set start(Marker start) {
    _startPosition = start;
    notifyListeners();
  }

  set end(Marker end) {
    _destinationPosition = end;
    notifyListeners();
  }

  Marker get start => _startPosition;

  Marker get end => _destinationPosition;

  TrackTraceRoute? get route => _route;

  set route(TrackTraceRoute? newRoute) {
    _route = newRoute;
    notifyListeners();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}

class TrackTraceRoute {
TrackTraceRoute(
      int durationValue, int distanceValue, List<PointLatLng> lineValue,)
      : duration = durationValue,
        distance = distanceValue,
        line = lineValue;
  /// route duration in seconds
  int duration = 0;

  /// route distance in meters
  int distance = 0;

  /// route edge points
  final List<PointLatLng> line;
}
