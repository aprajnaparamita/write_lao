import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    // Bridge the gap between launch screen dismissal and Flutter's first frame.
    // Must be set after super so UIWindow exists.
    window?.backgroundColor = UIColor(red: 30.0/255.0, green: 0.0, blue: 79.0/255.0, alpha: 1.0)
    return result
  }
}
