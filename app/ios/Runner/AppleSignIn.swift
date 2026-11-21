import AuthenticationServices
import Flutter
import UIKit

/// Sign in with Apple for lib/features/account/apple_sign_in.dart. Hands Dart
/// the identity token, which the server checks against Apple's keys, and the
/// name Apple gives only the first time.
final class AppleSignIn: NSObject, ASAuthorizationControllerDelegate,
  ASAuthorizationControllerPresentationContextProviding
{
  private var reply: FlutterResult?

  static func register(with messenger: FlutterBinaryMessenger) -> AppleSignIn {
    let signIn = AppleSignIn()
    FlutterMethodChannel(name: "balnana/apple_sign_in", binaryMessenger: messenger)
      .setMethodCallHandler { [weak signIn] call, result in
        guard let signIn, call.method == "signIn" else {
          result(FlutterMethodNotImplemented)
          return
        }
        let nonce = (call.arguments as? [String: Any])?["nonce"] as? String
        signIn.start(nonce: nonce, result)
      }
    return signIn
  }

  private func start(nonce: String?, _ result: @escaping FlutterResult) {
    guard reply == nil else {
      result(FlutterError(code: "busy", message: nil, details: nil))
      return
    }
    reply = result
    let request = ASAuthorizationAppleIDProvider().createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = nonce
    let controller = ASAuthorizationController(authorizationRequests: [request])
    controller.delegate = self
    controller.presentationContextProvider = self
    controller.performRequests()
  }

  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
      let data = credential.identityToken,
      let token = String(data: data, encoding: .utf8)
    else {
      finish(FlutterError(code: "failed", message: "no identity token", details: nil))
      return
    }
    var out: [String: Any] = ["identityToken": token]
    if let components = credential.fullName {
      let name = PersonNameComponentsFormatter().string(from: components)
      if !name.isEmpty {
        out["name"] = name
      }
    }
    finish(out)
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    let cancelled = (error as? ASAuthorizationError)?.code == .canceled
    finish(FlutterError(code: cancelled ? "cancelled" : "failed", message: error.localizedDescription, details: nil))
  }

  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    MainActor.assumeIsolated { presentationWindow() }
  }

  private func finish(_ value: Any) {
    let result = reply
    reply = nil
    result?(value)
  }
}

/// ASWebAuthenticationSession for lib/features/account/oauth.dart: a provider's
/// sign-in in a browser sheet that hands the way back to the app, instead of
/// leaving for Safari.
final class WebAuth: NSObject, ASWebAuthenticationPresentationContextProviding {
  private var session: ASWebAuthenticationSession?

  static func register(with messenger: FlutterBinaryMessenger) -> WebAuth {
    let auth = WebAuth()
    FlutterMethodChannel(name: "balnana/web_auth", binaryMessenger: messenger)
      .setMethodCallHandler { [weak auth] call, result in
        let args = call.arguments as? [String: Any]
        guard let auth, call.method == "authenticate",
          let url = (args?["url"] as? String).flatMap(URL.init(string:)),
          let scheme = args?["scheme"] as? String
        else {
          result(FlutterMethodNotImplemented)
          return
        }
        auth.start(url: url, scheme: scheme, result)
      }
    return auth
  }

  private func start(url: URL, scheme: String, _ result: @escaping FlutterResult) {
    guard session == nil else {
      result(FlutterError(code: "busy", message: nil, details: nil))
      return
    }
    let session = ASWebAuthenticationSession(url: url, callbackURLScheme: scheme) {
      [weak self] callback, error in
      DispatchQueue.main.async {
        self?.session = nil
        if let callback {
          result(callback.absoluteString)
        } else if (error as? ASWebAuthenticationSessionError)?.code == .canceledLogin {
          result(FlutterError(code: "cancelled", message: nil, details: nil))
        } else {
          result(FlutterError(code: "failed", message: error?.localizedDescription, details: nil))
        }
      }
    }
    session.presentationContextProvider = self
    self.session = session
    if !session.start() {
      self.session = nil
      result(FlutterError(code: "failed", message: "could not start", details: nil))
    }
  }

  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    MainActor.assumeIsolated { presentationWindow() }
  }
}
