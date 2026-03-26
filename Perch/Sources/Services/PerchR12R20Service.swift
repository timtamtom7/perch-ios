import Foundation
import Combine

final class PerchR12R20Service: ObservableObject, @unchecked Sendable {
    static let shared = PerchR12R20Service()
    
    @Published var sharedTrips: [SharedTrip] = []
    @Published var communities: [TravelCommunity] = []
    @Published var posts: [CommunityPost] = []
    @Published var collaborativePlannings: [CollaborativePlanning] = []
    @Published var currentTier: PerchSubscriptionTier = .free
    @Published var crossPlatformDevices: [CrossPlatformDevice] = []
    @Published var awardSubmissions: [AwardSubmission] = []
    @Published var apiCredentials: PerchAPI?
    
    private let userDefaults = UserDefaults.standard
    
    private init() { loadFromDisk() }
    
    func createSharedTrip(name: String, ownerID: String, destination: String, startDate: Date, endDate: Date) -> SharedTrip {
        let trip = SharedTrip(name: name, ownerID: ownerID, destination: destination, startDate: startDate, endDate: endDate)
        sharedTrips.append(trip)
        saveToDisk()
        return trip
    }
    
    func joinTrip(viaCode: String, userID: String) -> SharedTrip? {
        guard let index = sharedTrips.firstIndex(where: { $0.inviteCode == viaCode }) else { return nil }
        if !sharedTrips[index].memberIDs.contains(userID) {
            sharedTrips[index].memberIDs.append(userID)
        }
        saveToDisk()
        return sharedTrips[index]
    }
    
    func createCommunity(name: String, description: String) -> TravelCommunity {
        let community = TravelCommunity(name: name, description: description)
        communities.append(community)
        saveToDisk()
        return community
    }
    
    func createPost(authorID: String, authorName: String, content: String, locationTag: String? = nil) -> CommunityPost {
        let post = CommunityPost(authorID: authorID, authorName: authorName, content: content, locationTag: locationTag)
        posts.append(post)
        saveToDisk()
        return post
    }
    
    func createPlanning(tripID: UUID, participantIDs: [String]) -> CollaborativePlanning {
        let planning = CollaborativePlanning(tripID: tripID, participantIDs: participantIDs)
        collaborativePlannings.append(planning)
        saveToDisk()
        return planning
    }
    
    func addSuggestion(to planningID: UUID, text: String, suggestedBy: String, category: CollaborativePlanning.PlanningSuggestion.Category) {
        guard let index = collaborativePlannings.firstIndex(where: { $0.id == planningID }) else { return }
        let suggestion = CollaborativePlanning.PlanningSuggestion(id: UUID(), text: text, suggestedBy: suggestedBy, category: category, voteCount: 0)
        collaborativePlannings[index].suggestions.append(suggestion)
        saveToDisk()
    }
    
    func subscribe(to tier: PerchSubscriptionTier) async -> Bool {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run { currentTier = tier; saveToDisk() }
        return true
    }
    
    private func saveToDisk() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(sharedTrips) { userDefaults.set(data, forKey: "perch_trips") }
        if let data = try? encoder.encode(communities) { userDefaults.set(data, forKey: "perch_communities") }
        if let data = try? encoder.encode(posts) { userDefaults.set(data, forKey: "perch_posts") }
        if let data = try? encoder.encode(collaborativePlannings) { userDefaults.set(data, forKey: "perch_planning") }
        if let data = try? encoder.encode(crossPlatformDevices) { userDefaults.set(data, forKey: "perch_devices") }
        if let data = try? encoder.encode(awardSubmissions) { userDefaults.set(data, forKey: "perch_awards") }
    }
    
    private func loadFromDisk() {
        let decoder = JSONDecoder()
        if let data = userDefaults.data(forKey: "perch_trips"),
           let decoded = try? decoder.decode([SharedTrip].self, from: data) { sharedTrips = decoded }
        if let data = userDefaults.data(forKey: "perch_communities"),
           let decoded = try? decoder.decode([TravelCommunity].self, from: data) { communities = decoded }
        if let data = userDefaults.data(forKey: "perch_posts"),
           let decoded = try? decoder.decode([CommunityPost].self, from: data) { posts = decoded }
        if let data = userDefaults.data(forKey: "perch_planning"),
           let decoded = try? decoder.decode([CollaborativePlanning].self, from: data) { collaborativePlannings = decoded }
        if let data = userDefaults.data(forKey: "perch_devices"),
           let decoded = try? decoder.decode([CrossPlatformDevice].self, from: data) { crossPlatformDevices = decoded }
        if let data = userDefaults.data(forKey: "perch_awards"),
           let decoded = try? decoder.decode([AwardSubmission].self, from: data) { awardSubmissions = decoded }
    }
}
