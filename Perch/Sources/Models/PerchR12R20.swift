import Foundation

// MARK: - Perch R12-R20: Social Travel, Shared Adventures

struct SharedTrip: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var ownerID: String
    var memberIDs: [String]
    var destination: String
    var startDate: Date
    var endDate: Date
    var locationIDs: [UUID]
    var isPublic: Bool
    var inviteCode: String
    
    init(id: UUID = UUID(), name: String, ownerID: String, memberIDs: [String] = [], destination: String = "", startDate: Date, endDate: Date, locationIDs: [UUID] = [], isPublic: Bool = false, inviteCode: String = "") {
        self.id = id
        self.name = name
        self.ownerID = ownerID
        self.memberIDs = memberIDs
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.locationIDs = locationIDs
        self.isPublic = isPublic
        self.inviteCode = inviteCode.isEmpty ? String(UUID().uuidString.prefix(8)).uppercased() : inviteCode
    }
}

struct TravelCommunity: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var memberIDs: [String]
    var postIDs: [UUID]
    var isPublic: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, description: String = "", memberIDs: [String] = [], postIDs: [UUID] = [], isPublic: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.memberIDs = memberIDs
        self.postIDs = postIDs
        self.isPublic = isPublic
        self.createdAt = createdAt
    }
}

struct CommunityPost: Identifiable, Codable, Equatable {
    let id: UUID
    var authorID: String
    var authorName: String
    var content: String
    var locationTag: String?
    var imageURLs: [String]
    var likes: Int
    var commentCount: Int
    var createdAt: Date
    
    init(id: UUID = UUID(), authorID: String, authorName: String, content: String, locationTag: String? = nil, imageURLs: [String] = [], likes: Int = 0, commentCount: Int = 0, createdAt: Date = Date()) {
        self.id = id
        self.authorID = authorID
        self.authorName = authorName
        self.content = content
        self.locationTag = locationTag
        self.imageURLs = imageURLs
        self.likes = likes
        self.commentCount = commentCount
        self.createdAt = createdAt
    }
}

struct CollaborativePlanning: Identifiable, Codable, Equatable {
    let id: UUID
    var tripID: UUID
    var participantIDs: [String]
    var suggestions: [PlanningSuggestion]
    var votes: [String: [String]] // suggestionID: [voterID]
    
    struct PlanningSuggestion: Identifiable, Codable, Equatable {
        let id: UUID
        var text: String
        var suggestedBy: String
        var category: Category
        var voteCount: Int
        
        enum Category: String, Codable {
            case activity, restaurant, hotel, transport, other
        }
    }
    
    init(id: UUID = UUID(), tripID: UUID, participantIDs: [String] = [], suggestions: [PlanningSuggestion] = [], votes: [String: [String]] = [:]) {
        self.id = id
        self.tripID = tripID
        self.participantIDs = participantIDs
        self.suggestions = suggestions
        self.votes = votes
    }
}

struct PerchSubscriptionTier: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var displayName: String
    var monthlyPrice: Decimal
    var annualPrice: Decimal
    var lifetimePrice: Decimal
    var features: [String]
    var isMostPopular: Bool
    
    static let free = PerchSubscriptionTier(id: UUID(), name: "free", displayName: "Free", monthlyPrice: 0, annualPrice: 0, lifetimePrice: 0, features: ["3 trips", "Basic tracking", "Simple maps"], isMostPopular: false)
    static let explorer = PerchSubscriptionTier(id: UUID(), name: "explorer", displayName: "Explorer", monthlyPrice: 5.99, annualPrice: 59.99, lifetimePrice: 119, features: ["Unlimited trips", "Shared trips", "Community access", "Offline maps"], isMostPopular: true)
    static let adventurer = PerchSubscriptionTier(id: UUID(), name: "adventurer", displayName: "Adventurer", monthlyPrice: 9.99, annualPrice: 95.88, lifetimePrice: 0, features: ["Everything in Explorer", "Travel planning", "Collaborative planning", "Priority support"], isMostPopular: false)
}

struct SupportedLocale: Identifiable, Codable, Equatable {
    let id: UUID
    var code: String
    var displayName: String
    
    static let supported: [SupportedLocale] = [
        SupportedLocale(id: UUID(), code: "en", displayName: "English"),
        SupportedLocale(id: UUID(), code: "es", displayName: "Spanish"),
        SupportedLocale(id: UUID(), code: "fr", displayName: "French"),
    ]
}

struct CrossPlatformDevice: Identifiable, Codable, Equatable {
    let id: UUID
    var deviceName: String
    var platform: Platform
    
    enum Platform: String, Codable { case ios, android, web }
    
    init(id: UUID = UUID(), deviceName: String, platform: Platform) {
        self.id = id
        self.deviceName = deviceName
        self.platform = platform
    }
}

struct AwardSubmission: Identifiable, Codable, Equatable {
    let id: UUID
    var awardName: String
    var category: String
    var status: Status
    
    enum Status: String, Codable { case draft, submitted, inReview, won, rejected }
    
    init(id: UUID = UUID(), awardName: String, category: String, status: Status = .draft) {
        self.id = id
        self.awardName = awardName
        self.category = category
        self.status = status
    }
}

struct PlatformIntegration: Identifiable, Codable, Equatable {
    let id: UUID
    var platform: String
    var isEnabled: Bool
    
    init(id: UUID = UUID(), platform: String, isEnabled: Bool = false) {
        self.id = id
        self.platform = platform
        self.isEnabled = isEnabled
    }
}

struct PerchAPI: Codable, Equatable {
    var clientID: String
    var tier: APITier
    
    enum APITier: String, Codable { case free, paid }
    
    init(clientID: String = UUID().uuidString, tier: APITier = .free) {
        self.clientID = clientID
        self.tier = tier
    }
}
