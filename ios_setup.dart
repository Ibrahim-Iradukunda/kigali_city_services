// ============================================================
// iOS Setup for Google Maps + Location (for NearYou distances)
// ============================================================
//
// 1. Add to ios/Runner/AppDelegate.swift:
//
//    import GoogleMaps
//
//    @UIApplicationMain
//    @objc class AppDelegate: FlutterAppDelegate {
//      override func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//      ) -> Bool {
//        GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
//        GeneratedPluginRegistrant.register(with: self)
//        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//      }
//    }
//
// 2. Add to ios/Runner/Info.plist:
//
//    <key>NSLocationWhenInUseUsageDescription</key>
//    <string>This app needs access to your location to show nearby services (NearYou).</string>
//    <key>NSLocationAlwaysUsageDescription</key>
//    <string>This app needs access to your location to notify you about nearby services.</string>
//
// ============================================================