import Foundation

struct StubItem: Identifiable, Codable, Equatable {
    var id: UUID
    var dateAdded: Date
    var eventName: String
    var venue: String
    var eventDate: String
    var category: String

    init(id: UUID = UUID(), dateAdded: Date = Date(), eventName: String, venue: String, eventDate: String, category: String) {
        self.id = id
        self.dateAdded = dateAdded
        self.eventName = eventName
        self.venue = venue
        self.eventDate = eventDate
        self.category = category
    }

    static func blank() -> StubItem {
        StubItem(eventName: "", venue: "", eventDate: "", category: "")
    }
}
