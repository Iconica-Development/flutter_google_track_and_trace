part of google_track_trace;

class TrackTraceController {
  late final Completer<GoogleMapController> _mapController;

  // get the duration

  // get the distance

  // listen to updates on the source marker

  // listen to updates on the route


  void dispose() {}

  void setController(Completer<GoogleMapController> controller) {
    _mapController = controller;
  }

  Completer<GoogleMapController> getController() {
    return _mapController;
  }
}
