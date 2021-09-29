<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# Track and Trace with Google Maps For Flutter

A Flutter packages that provides a wrapper around a [Google Maps](https://developers.google.com/maps/) widget.


## Features

* Show a Google Map with 2 markers on it
* Calculate a Route between the two markers
* Update the route and route information with a set time interval
* Retrieve the travel distance and time
* Use custom styling for the map, markers and line
* Automatically center the view between the two markers
* Make all Google Maps settings available through the GoogleTrackTraceMap


## Getting started

Because this package uses Google Maps for the Map and the route calculation you need to follow the Flutter Google Maps guide:

* Get an API key at <https://cloud.google.com/maps-platform/>.

* Enable Google Map SDK for each platform.
  * Go to [Google Developers Console](https://console.cloud.google.com/).
  * Choose the project that you want to enable Google Maps on.
  * Select the navigation menu and then select "Google Maps".
  * Select "APIs" under the Google Maps menu.
  * To enable Google Maps for Android, select "Maps SDK for Android" in the "Additional APIs" section, then select "ENABLE".
  * To enable Google Maps for iOS, select "Maps SDK for iOS" in the "Additional APIs" section, then select "ENABLE".
  * Make sure the APIs you enabled are under the "Enabled APIs" section.

For more details, see [Getting started with Google Maps Platform](https://developers.google.com/maps/gmp-get-started).

### Android

1. Set the `minSdkVersion` in `android/app/build.gradle`:

```groovy
android {
    defaultConfig {
        minSdkVersion 20
    }
}
```

This means that app will only be available for users that run Android SDK 20 or higher.

2. Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
```

### iOS

This plugin requires iOS 9.0 or higher. To set up, specify your API key in the application delegate `ios/Runner/AppDelegate.m`:

```objectivec
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"YOUR KEY HERE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```

Or in your swift code, specify your API key in the application delegate `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR KEY HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```
## Usage


```dart
class TrackTraceDemo extends StatefulWidget {
  const TrackTraceDemo({Key? key}) : super(key: key);

  @override
  State<TrackTraceDemo> createState() => _TrackTraceDemoState();
}

class _TrackTraceDemoState extends State<TrackTraceDemo> {
  TrackTraceController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: (controller == null || controller!.route == null)
              ? const Text('TrackTrace example')
              : Text(controller!.route!.duration.toString() +
                  ' seconds, distance: ' +
                  (controller!.route!.distance / 1000).toString() +
                  ' km')),
      body: GoogleTrackTraceMap(
        startPosition: const Marker(
          markerId: MarkerId('Start location'),
          position: LatLng(52.356057, 4.897540),
        ),
        destinationPosition: const Marker(
            markerId: MarkerId('Destination location'),
            position: LatLng(52.364709, 4.877157)),
        googleAPIKey: '', // put your own API key here
        travelMode: TravelMode.bicycling,
        routeUpdateInterval: 60,
        timerPrecision: TimePrecision.everySecond,
        zoomGesturesEnabled: true,
        line: const Polyline(
          polylineId: PolylineId('test route'),
          color: Colors.purple,
          width: 7,
        ),
        onMapCreated: (ctr) => {
          controller = ctr,
          ctr.addListener(() {
            setState(() {});
          }),
        },
      ),
    );
  }
}
```

See the `example` directory for a complete sample app.