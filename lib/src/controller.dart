part of google_track_trace;

class TrackTraceController extends ChangeNotifier {
  late final GoogleMapController _mapController;
  Marker startPosition;
  Marker destinationPosition;
  Marker? currentPosition;

  int durationInSeconds = 0;

  TrackTraceController(Marker start, Marker destination)
      : startPosition = start,
        destinationPosition = destination;

  set start(Marker start) {
    startPosition = start;
    notifyListeners();
  }

  set current(Marker? current) {
    currentPosition = current;
    notifyListeners();
  }

  set end(Marker end) {
    destinationPosition = end;
    notifyListeners();
  }

  Marker get start => startPosition;

  Marker? get current => currentPosition;

  Marker get end => destinationPosition;

  set duration(int duration) {
    durationInSeconds = duration;
    notifyListeners();
  }

  int get duration => durationInSeconds;

  set mapController(GoogleMapController controller) {
    _mapController = controller;
  }

  GoogleMapController get mapController => _mapController;
}
