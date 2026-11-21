import Flutter
import Foundation
import Security

enum DeviceStorage {
  static func register(with messenger: FlutterBinaryMessenger) {
    let sessions = SessionKeychain(
      service: Bundle.main.bundleIdentifier ?? "com.balnana.app", preferences: .standard
    )
    let channel = FlutterMethodChannel(
      name: "balnana/storage", binaryMessenger: messenger,
      codec: FlutterStandardMethodCodec.sharedInstance(), taskQueue: messenger.makeBackgroundTaskQueue?()
    )
    channel.setMethodCallHandler { call, reply in
      do {
        switch call.method {
        case "sessionTokens":
          reply(try sessions.load())
        case "setSessionToken":
          guard let args = call.arguments as? [String: Any],
                let server = args["server"] as? String else {
            reply(FlutterError(code: "invalid_arguments", message: nil, details: nil))
            return
          }
          try sessions.set(args["token"] as? String, for: server)
          reply(nil)
        case "offlineDatabasePath":
          reply(try offlineDatabaseURL().path)
        default:
          reply(FlutterMethodNotImplemented)
        }
      } catch {
        reply(FlutterError(code: "device_storage", message: nil, details: (error as NSError).code))
      }
    }
  }

  private static func offlineDatabaseURL() throws -> URL {
    let files = FileManager.default
    let support = try files.url(
      for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true
    )
    let documents = try files.url(
      for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false
    )
    return try offlineDatabaseURL(documents: documents, support: support)
  }

  static func offlineDatabaseURL(documents: URL, support: URL) throws -> URL {
    let files = FileManager.default
    var directory = support.appendingPathComponent("Balnana Offline", isDirectory: true)
    try files.createDirectory(at: directory, withIntermediateDirectories: true)
    var resources = URLResourceValues()
    // Cached responses and pending edits can both contain private ledger
    // data. Keep them in a persistent directory on this device.
    resources.isExcludedFromBackup = true
    try directory.setResourceValues(resources)

    let name = "balnana_cache.sqlite"
    let destination = directory.appendingPathComponent(name)
    let legacy = documents.appendingPathComponent(name)
    if files.fileExists(atPath: legacy.path), !files.fileExists(atPath: destination.path) {
      // Move the database last so an interrupted migration can resume. The
      // sidecars can contain committed writes that have not been checkpointed.
      for suffix in ["-wal", "-shm", "-journal", ""] {
        let source = documents.appendingPathComponent(name + suffix)
        if files.fileExists(atPath: source.path) {
          try files.moveItem(at: source, to: directory.appendingPathComponent(name + suffix))
        }
      }
    }
    return destination
  }
}

/// Accessed in order on the storage channel's serial queue.
struct SessionKeychain {
  let service: String
  let preferences: UserDefaults

  private let legacyKey = "flutter.session.tokens"
  private let migratedKey = "sessionKeychainInitialized"
  private let signedOutKey = "sessionsPendingRemoval"
  private var pendingRemoval: Set<String> {
    Set(preferences.stringArray(forKey: signedOutKey) ?? [])
  }
  private var query: [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: "session.tokens",
    ]
  }

  func load() throws -> [String: String] {
    let signedOut = pendingRemoval
    if !preferences.bool(forKey: migratedKey) {
      // A reinstall has fresh preferences and can retain old Keychain
      // items. Start with this installation's legacy tokens, if any.
      let legacy = preferences.string(forKey: legacyKey)
      let object = legacy.flatMap { try? JSONSerialization.jsonObject(with: Data($0.utf8)) }
      let tokens = ((object as? [String: Any])?.compactMapValues { $0 as? String } ?? [:])
        .filter { !signedOut.contains($0.key) }
      try save(tokens)
      preferences.set(true, forKey: migratedKey)
      preferences.removeObject(forKey: legacyKey)
      return tokens
    }

    var request = query
    request[kSecReturnData as String] = true
    var item: CFTypeRef?
    let status = SecItemCopyMatching(request as CFDictionary, &item)
    if status == errSecItemNotFound {
      preferences.removeObject(forKey: legacyKey)
      return [:]
    }
    try check(status)
    guard let data = item as? Data else {
      throw CocoaError(.fileReadCorruptFile)
    }
    let tokens = try JSONDecoder().decode([String: String].self, from: data)
    // A stale preference may remain if the previous run stopped mid-migration.
    preferences.removeObject(forKey: legacyKey)
    return tokens.filter { !signedOut.contains($0.key) }
  }

  func set(_ token: String?, for server: String) throws {
    if token == nil {
      // A keychain error must not restore a signed-out session on next launch.
      // This records only the server address while the item is being removed.
      preferences.set(Array(pendingRemoval.union([server])), forKey: signedOutKey)
    }
    var tokens = try load()
    tokens[server] = token
    try save(tokens)
    preferences.removeObject(forKey: signedOutKey)
  }

  private func save(_ tokens: [String: String]) throws {
    let data = try JSONEncoder().encode(tokens)
    let attributes: [String: Any] = [
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
    ]
    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    if status == errSecItemNotFound {
      let item = query.merging(attributes) { _, attribute in attribute }
      try check(SecItemAdd(item as CFDictionary, nil))
    } else {
      try check(status)
    }
  }

  private func check(_ status: OSStatus) throws {
    guard status == errSecSuccess else {
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
    }
  }
}
