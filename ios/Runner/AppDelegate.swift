import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // CRITICAL FIX: The GeneratedPluginRegistrant registers FirebaseAnalyticsPlugin
    // BEFORE FLTFirebaseCorePlugin, which causes a crash because Analytics
    // tries to access Firebase before it's initialized.
    
    // Step 1: Configure Firebase FIRST before ANY plugin registration
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    
    // Step 2: Register all plugins
    // Firebase is now configured, so FirebaseAnalyticsPlugin won't crash
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
