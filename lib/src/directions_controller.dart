part of google_track_trace;

enum TravelMode { driving, walking, bicycling, transit }

class DirectionsRepository {
  static const String _baseUrl = '/maps/api/directions/json';

  /// get the route between the two coordinates
  Future<Directions> getDirections({
    required LatLng origin,
    required LatLng destination,
    required TravelMode mode,
    required String key,
  }) async {
    try {
      final queryParameters = {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key':
            key, // get this key from the controller
        'mode': <TravelMode, String>{
          TravelMode.driving: 'driving',
          TravelMode.bicycling: 'bicycling',
          TravelMode.transit: 'transit',
          TravelMode.walking: 'walking',
        }[mode],
      };
      final uri = Uri.https('maps.googleapis.com', _baseUrl, queryParameters);
      final response = await http.get(uri, headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      if (response.statusCode == 200) {
        return Directions.fromMap(jsonDecode(response.body));
      }
    } on HttpException catch (e) {
      print(e.message);
    }
    throw GoogleMapsException('Unable to retrieve directions from Google Maps API');
  }
}

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final int totalDistance;
  final int totalDuration;

  const Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  /// map the json response to a [Directions] object
  factory Directions.fromMap(Map<String, dynamic> map) {
    if ((map['routes'] as List).isEmpty) {
      throw GoogleMapsException('No Routes available');
    }

    final data = Map<String, dynamic>.from(map['routes'][0]);

    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      southwest: LatLng(southwest['lat'], southwest['lng']),
      northeast: LatLng(northeast['lat'], northeast['lng']),
    );

    int distance = 0;
    int duration = 0;
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['value'];
      duration = leg['duration']['value'];
    }

    return Directions(
      bounds: bounds,
      polylinePoints:
          PolylinePoints().decodePolyline(data['overview_polyline']['points']),
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}

class GoogleMapsException implements Exception {
  GoogleMapsException(this.message);

  /// The unhandled [error] object.
  final String message;

  @override
  String toString() {
    return 'Error occurred in Track&Trace package:\n'
        '$message';
  }
}
