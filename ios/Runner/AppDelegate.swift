import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // CRITICAL: Configure Firebase BEFORE registering any plugins
    // This prevents crash in FirebaseAnalyticsPlugin.register(with:)
    // which tries to access Firebase instance before it's ready
    
    if FirebaseApp.app() == nil {
      // Use default configuration from GoogleService-Info.plist
      FirebaseApp.configure()
    }
    
    // Now safe to register all Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
