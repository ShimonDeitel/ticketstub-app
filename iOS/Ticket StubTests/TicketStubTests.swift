import XCTest
@testable import TicketStub

@MainActor
final class TicketStubTests: XCTestCase {

    func makeStore() -> Store {
        let store = Store()
        return store
    }

    func testSeedDataLoadsBelowFreeLimit() {
        let store = makeStore()
        XCTAssertLessThan(store.items.count, Store.freeLimit)
    }

    func testAddIncreasesCount() {
        let store = makeStore()
        let before = store.items.count
        store.add(.blank())
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testDeleteDecreasesCount() {
        let store = makeStore()
        store.add(.blank())
        let before = store.items.count
        if let first = store.items.first {
            store.delete(first)
        }
        XCTAssertEqual(store.items.count, before - 1)
    }

    func testCanAddMoreWhenUnderLimit() {
        let store = makeStore()
        store.isPro = false
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreWhenAtLimitAndNotPro() {
        let store = makeStore()
        store.isPro = false
        while store.items.count < Store.freeLimit {
            store.add(.blank())
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testCanAddMoreWhenProEvenAtLimit() {
        let store = makeStore()
        store.isPro = true
        while store.items.count < Store.freeLimit {
            store.add(.blank())
        }
        XCTAssertTrue(store.canAddMore)
    }

    func testUpdateReplacesItem() {
        let store = makeStore()
        store.add(.blank())
        guard var first = store.items.first else { return XCTFail("no item") }
        first.eventName = "Updated Name"
        store.update(first)
        XCTAssertEqual(store.items.first?.eventName, "Updated Name")
    }

    func testAddBeyondLimitIsNoOpForFreeUsers() {
        let store = makeStore()
        store.isPro = false
        while store.items.count < Store.freeLimit {
            store.add(.blank())
        }
        let countAtLimit = store.items.count
        store.add(.blank())
        XCTAssertEqual(store.items.count, countAtLimit)
    }
}
