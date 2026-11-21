import CoreLocation
import Security
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {
  func testLocationIgnoresFixesFromBeforeTheLookup() {
    let start = Date()
    let cached = location(at: start.addingTimeInterval(-1), accuracy: 10)
    let fresh = location(at: start.addingTimeInterval(1), accuracy: 25)
    let invalid = location(at: start.addingTimeInterval(2), accuracy: -1)

    XCTAssertNil(ExpenseLocation.currentFix(in: [cached, invalid], since: start))
    XCTAssertEqual(ExpenseLocation.currentFix(in: [cached, fresh, invalid], since: start), fresh)
  }

  func testSessionTokensMigrateAndRemainServerScopedOnSignOut() throws {
    let suite = "balnana.tests.\(UUID().uuidString)"
    let preferences = try XCTUnwrap(UserDefaults(suiteName: suite))
    let sessions = SessionKeychain(service: suite, preferences: preferences)
    defer {
      preferences.removePersistentDomain(forName: suite)
      SecItemDelete([
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: suite,
      ] as CFDictionary)
    }

    let a = "https://a.example.com"
    let b = "https://b.example.com"
    let legacyKey = "flutter.session.tokens"
    let legacy = String(decoding: try JSONEncoder().encode([a: "old-a", b: "old-b"]), as: UTF8.self)
    preferences.set(legacy, forKey: legacyKey)
    XCTAssertEqual(try sessions.load(), [a: "old-a", b: "old-b"])
    XCTAssertNil(preferences.object(forKey: legacyKey))

    try sessions.set("new-b", for: b)
    try sessions.set(nil, for: a)
    preferences.set(legacy, forKey: legacyKey)
    XCTAssertEqual(try sessions.load(), [b: "new-b"])
    XCTAssertNil(preferences.object(forKey: legacyKey))

    preferences.set([b], forKey: "sessionsPendingRemoval")
    XCTAssertEqual(try sessions.load(), [:], "An interrupted sign-out must hide its old token")
    try sessions.set("signed-in-a", for: a)
    XCTAssertEqual(try sessions.load(), [a: "signed-in-a"])

    preferences.removePersistentDomain(forName: suite)
    XCTAssertEqual(try sessions.load(), [:], "A reinstall must not revive Keychain sessions")
  }

  func testOfflineDatabaseMigrationResumesAfterMovingTheJournal() throws {
    let files = FileManager.default
    let root = files.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    let documents = root.appendingPathComponent("Documents", isDirectory: true)
    let support = root.appendingPathComponent("Application Support", isDirectory: true)
    try files.createDirectory(at: documents, withIntermediateDirectories: true)
    defer { try? files.removeItem(at: root) }

    let database = Data([1, 2, 3])
    let journal = Data([4, 5, 6])
    let legacy = documents.appendingPathComponent("balnana_cache.sqlite")
    let destination = try DeviceStorage.offlineDatabaseURL(documents: documents, support: support)
    let directory = destination.deletingLastPathComponent()
    let movedWAL = directory.appendingPathComponent("balnana_cache.sqlite-wal")
    try database.write(to: legacy)
    try journal.write(to: movedWAL)

    XCTAssertEqual(try DeviceStorage.offlineDatabaseURL(documents: documents, support: support), destination)
    XCTAssertEqual(try Data(contentsOf: destination), database)
    XCTAssertEqual(try Data(contentsOf: movedWAL), journal)
    XCTAssertFalse(files.fileExists(atPath: legacy.path))
    let attributes = try directory.resourceValues(forKeys: [.isExcludedFromBackupKey])
    XCTAssertEqual(attributes.isExcludedFromBackup, true)
  }

  private func location(at date: Date, accuracy: CLLocationAccuracy) -> CLLocation {
    CLLocation(
      coordinate: CLLocationCoordinate2D(latitude: 25, longitude: 121),
      altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: date
    )
  }
}
