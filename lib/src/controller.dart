part of google_track_trace;

class TrackTraceController extends ChangeNotifier {
  GoogleMapController? _mapController;
  Marker _startPosition;
  Marker _destinationPosition;
  TrackTraceRoute? _route;

  TrackTraceController(Marker start, Marker destination)
      : _startPosition = start,
        _destinationPosition = destination;

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

  set mapController(GoogleMapController? controller) {
    _mapController = controller;
  }

  GoogleMapController? get mapController => _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class TrackTraceRoute {
  /// route duration in seconds
  int _duration = 0;

  /// route distance in meters
  int _distance = 0;

  /// route edge points
  final List<PointLatLng> line;

  TrackTraceRoute(
      int durationValue, int distanceValue, List<PointLatLng> lineValue)
      : _duration = durationValue,
        _distance = distanceValue,
        line = lineValue;

  int get distance => _distance;

  int get duration => _duration;

  set distance(int distance) {
    _distance = distance;
  }

  set duration(int duration) {
    _duration = duration;
  }
}
