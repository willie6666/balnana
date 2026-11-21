import Flutter
import StoreKit
import UIKit

/// StoreKit 2 for lib/core/app_store.dart. Transactions go to Dart as the JWS
/// Apple signed, which the server checks for itself: the app only passes
/// them on, so nothing here decides what anyone paid for.
final class StoreBridge {
  private let channel: FlutterMethodChannel
  private var updates: Task<Void, Never>?

  private init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  deinit {
    updates?.cancel()
  }

  static func register(with messenger: FlutterBinaryMessenger) -> StoreBridge {
    let bridge = StoreBridge(
      channel: FlutterMethodChannel(name: "balnana/app_store", binaryMessenger: messenger)
    )
    bridge.channel.setMethodCallHandler { [weak bridge] call, result in
      guard let bridge else {
        result(FlutterMethodNotImplemented)
        return
      }
      bridge.handle(call, result)
    }
    bridge.listen()
    return bridge
  }

  private func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "products":
      let ids = args["products"] as? [String] ?? []
      Task { @MainActor in result(await Self.products(ids)) }
    case "buy":
      guard let id = args["product"] as? String else {
        result(FlutterError(code: "failed", message: "no product", details: nil))
        return
      }
      let account = (args["account"] as? String).flatMap(UUID.init(uuidString:))
      Task { @MainActor in result(await Self.buy(id, account: account)) }
    case "purchases":
      let sync = args["sync"] as? Bool ?? false
      Task { @MainActor in result(await Self.purchases(sync: sync)) }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Renewals, Ask to Buy approvals and purchases from other devices arrive
  /// here while the app runs; StoreKit replays unfinished ones at launch.
  private func listen() {
    updates = Task.detached { [weak self] in
      for await update in Transaction.updates {
        if case .verified(let transaction) = update {
          await transaction.finish()
        }
        let signed = update.jwsRepresentation
        await MainActor.run {
          self?.channel.invokeMethod("purchased", arguments: [signed])
        }
      }
    }
  }

  private static func products(_ ids: [String]) async -> Any {
    do {
      let found = try await Product.products(for: ids)
      return found.filter { $0.type == .autoRenewable }.map { product -> [String: String] in
        [
          "productId": product.id,
          "name": product.displayName,
          "price": product.displayPrice,
          "period": product.subscription.map { iso8601($0.subscriptionPeriod) } ?? "",
        ]
      }
    } catch {
      return FlutterError(code: "unavailable", message: error.localizedDescription, details: nil)
    }
  }

  /// P1M, P1Y and so on, as Google Play says it too.
  private static func iso8601(_ period: Product.SubscriptionPeriod) -> String {
    switch period.unit {
    case .day: return "P\(period.value)D"
    case .week: return "P\(period.value)W"
    case .month: return "P\(period.value)M"
    case .year: return "P\(period.value)Y"
    @unknown default: return ""
    }
  }

  @MainActor
  private static func buy(_ id: String, account: UUID?) async -> Any {
    do {
      guard let product = try await Product.products(for: [id]).first else {
        return FlutterError(code: "unavailable", message: "unknown product", details: nil)
      }
      var options: Set<Product.PurchaseOption> = []
      if let account {
        options.insert(.appAccountToken(account))
      }
      let outcome: Product.PurchaseResult
      if #available(iOS 17.0, *), let scene = activeScene() {
        outcome = try await product.purchase(confirmIn: scene, options: options)
      } else {
        outcome = try await product.purchase(options: options)
      }
      switch outcome {
      case .success(let verification):
        // The server checks the signature again; finishing only says the
        // app has it, and the subscription stays among currentEntitlements.
        if case .verified(let transaction) = verification {
          await transaction.finish()
        }
        return [verification.jwsRepresentation]
      case .pending:
        return FlutterError(code: "pending", message: nil, details: nil)
      case .userCancelled:
        return [String]()
      @unknown default:
        return [String]()
      }
    } catch {
      return FlutterError(code: "failed", message: error.localizedDescription, details: nil)
    }
  }

  /// The subscriptions this Apple ID holds now. With sync, Apple is asked
  /// again first, which may ask the person to sign in to the App Store.
  private static func purchases(sync: Bool) async -> Any {
    if sync {
      do {
        try await AppStore.sync()
      } catch {
        return FlutterError(code: "unavailable", message: error.localizedDescription, details: nil)
      }
    }
    var signed: [String] = []
    for await entitlement in Transaction.currentEntitlements {
      if entitlement.unsafePayloadValue.productType == .autoRenewable {
        signed.append(entitlement.jwsRepresentation)
      }
    }
    return signed
  }
}

/// The scene in front, for sheets that need one to show in.
@MainActor
func activeScene() -> UIWindowScene? {
  let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
  return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
}

/// The window sheets are shown over.
@MainActor
func presentationWindow() -> UIWindow {
  if let scene = activeScene() {
    if let key = scene.windows.first(where: \.isKeyWindow) ?? scene.windows.first {
      return key
    }
    return UIWindow(windowScene: scene)
  }
  return UIWindow(frame: UIScreen.main.bounds)
}
