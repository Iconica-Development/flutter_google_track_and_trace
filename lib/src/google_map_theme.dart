part of google_track_trace;

/// Styling object for the Google maps Style
/// 
/// Contains a List of features with stylers applied to them
/// Full documentation on all the possible style:
/// https://developers.google.com/maps/documentation/javascript/style-reference
/// ```dart
///  GoogleTrackTraceMapTheme(
///          themes: [
///            GoogleMapThemeFeature(
///              featureType: 'poi',
///              stylers: [
///                {'visibility': 'off'},
///              ],
///            ),
///           ],
///  ),
/// ```
class GoogleTrackTraceMapTheme {
  GoogleTrackTraceMapTheme({
    required this.themes,
  });
  final List<GoogleMapThemeFeature> themes;
  
  String getJson() {
    var sb = StringBuffer('[');
    for (var property in themes) {
      sb..write(jsonEncode(property.toJson()))
      ..write(',');
    }
    sb.write(']');
    return sb.toString();
  }
}

class GoogleMapThemeFeature {
  GoogleMapThemeFeature({
    required this.stylers,
    this.featureType,
    this.elementType,
  });
  final String? featureType;
  final String? elementType;
  final List<Map<String, String>> stylers;

  Map toJson() {
    return {
      if(featureType != null) 'featureType': featureType,
      if(elementType != null) 'elementType': elementType,
      'stylers': stylers,
    };
  }
}
