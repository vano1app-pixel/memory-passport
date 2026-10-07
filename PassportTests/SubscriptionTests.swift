import XCTest
import StoreKitTest
@testable import MemoryPassport

@MainActor final class SubscriptionTests: XCTestCase {
    func session() throws -> SKTestSession {
        let session = try SKTestSession(configurationFileNamed: "PassportPro")
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
        return try XCTUnwrap(session.disableDialogs ? session : nil, "Local StoreKit test service rejected configuration; do not start an interactive purchase.")
    }
    func testPurchaseRestoreExpiry() async throws {
        let session = try session()
        defer { session.clearTransactions() }
        let store = PassportPro()
        await store.load()
        _ = try XCTUnwrap(store.product)
        XCTAssertFalse(store.active)
        await store.purchase()
        XCTAssertTrue(store.active, store.message ?? "No access")
        let fresh = PassportPro()
        await fresh.load()
        await fresh.restore()
        XCTAssertTrue(fresh.active)
        try session.expireSubscription(productIdentifier: PassportPro.monthlyID)
        await fresh.refresh()
        XCTAssertFalse(fresh.active)
    }
    func testPendingDoesNotUnlock() async throws {
        let session = try session()
        defer { session.clearTransactions() }
        session.askToBuyEnabled = true
        let store = PassportPro()
        await store.load()
        _ = try XCTUnwrap(store.product)
        await store.purchase()
        XCTAssertFalse(store.active)
        XCTAssertTrue(store.message?.contains("awaiting approval") == true)
    }
    func testRefundRemovesAccess() async throws {
        let session = try session()
        defer { session.clearTransactions() }
        let store = PassportPro()
        await store.load()
        _ = try XCTUnwrap(store.product)
        await store.purchase()
        XCTAssertTrue(store.active)
        let transaction = try XCTUnwrap(session.allTransactions().first)
        try session.refundTransaction(identifier: transaction.identifier)
        await store.refresh()
        XCTAssertFalse(store.active)
    }
}
