import CoreLocation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let expenseLocation = ExpenseLocation()

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "balnana/location", binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [expenseLocation] call, result in
      guard call.method == "current" else {
        result(FlutterMethodNotImplemented)
        return
      }
      expenseLocation.current(result)
    }
  }
}

/// One foreground fix, requested only when the expense editor asks for it.
private final class ExpenseLocation: NSObject, CLLocationManagerDelegate {
  private lazy var manager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    return manager
  }()
  private var reply: FlutterResult?
  private var timeout: Timer?
  private var locating = false

  func current(_ result: @escaping FlutterResult) {
    guard reply == nil else {
      result(error("unavailable"))
      return
    }
    reply = result
    if manager.authorizationStatus == .notDetermined {
      // Leave time to look up the location before Dart's outer timeout.
      wait(upTo: 100)
      manager.requestWhenInUseAuthorization()
    } else {
      locationManagerDidChangeAuthorization(manager)
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard reply != nil else { return }
    switch manager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      guard !locating else { return }
      locating = true
      wait(upTo: 15)
      manager.startUpdatingLocation()
    case .denied, .restricted:
      finishDenied()
    case .notDetermined:
      break
    @unknown default:
      finish(error("unavailable"))
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }
    finish(["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude])
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError failure: Error) {
    switch (failure as? CLError)?.code {
    case .denied:
      finishDenied()
    case .locationUnknown:
      break // Core Location keeps trying until the timeout.
    default:
      finish(error("unavailable"))
    }
  }

  private func wait(upTo seconds: TimeInterval) {
    timeout?.invalidate()
    timeout = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
      guard let self else { return }
      self.finish(self.error("unavailable"))
    }
  }

  private func finishDenied() {
    guard let result = takeReply() else { return }
    // Checking the device-wide switch can block while Core Location responds.
    DispatchQueue.global(qos: .userInitiated).async {
      let code = CLLocationManager.locationServicesEnabled() ? "denied" : "off"
      DispatchQueue.main.async {
        result(FlutterError(code: code, message: nil, details: nil))
      }
    }
  }

  private func finish(_ value: Any) {
    takeReply()?(value)
  }

  private func takeReply() -> FlutterResult? {
    timeout?.invalidate()
    timeout = nil
    if locating {
      manager.stopUpdatingLocation()
      locating = false
    }
    defer { reply = nil }
    return reply
  }

  private func error(_ code: String) -> FlutterError {
    FlutterError(code: code, message: nil, details: nil)
  }
}
