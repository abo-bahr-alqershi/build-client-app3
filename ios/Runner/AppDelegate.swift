import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Initialize Swift runtime
    CustomPluginRegistrant.ensureSwiftRuntimeInitialized()
    
    // Configure Firebase
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
      print("✅ Firebase configured")
    }
    
    // Delay plugin registration to ensure everything is ready
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      GeneratedPluginRegistrant.register(with: self)
      print("✅ Plugins registered")
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}