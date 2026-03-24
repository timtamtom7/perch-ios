import Foundation

/// Sample trip data for previews and demo purposes
struct SampleTrips {
    static let tokyo = Trip(
        id: -1,
        name: "Tokyo",
        startDate: Calendar.current.date(byAdding: .day, value: -9, to: Date())!,
        endDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        isActive: false,
        visits: [
            Visit(id: -1, tripId: -1, city: "Tokyo", country: "Japan", latitude: 35.6762, longitude: 139.6503, arrivalDate: Calendar.current.date(byAdding: .day, value: -9, to: Date())!, departureDate: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, order: 0),
            Visit(id: -2, tripId: -1, city: "Kyoto", country: "Japan", latitude: 35.0116, longitude: 135.7681, arrivalDate: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, departureDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, order: 1)
        ]
    )

    static let paris = Trip(
        id: -2,
        name: "Paris",
        startDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
        endDate: Calendar.current.date(byAdding: .day, value: -27, to: Date())!,
        isActive: false,
        visits: [
            Visit(id: -3, tripId: -2, city: "Paris", country: "France", latitude: 48.8566, longitude: 2.3522, arrivalDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, departureDate: Calendar.current.date(byAdding: .day, value: -27, to: Date())!, order: 0)
        ]
    )

    static let lisbon = Trip(
        id: -3,
        name: "Lisbon",
        startDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
        endDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!.addingTimeInterval(86400 * 5),
        isActive: false,
        visits: [
            Visit(id: -4, tripId: -3, city: "Lisbon", country: "Portugal", latitude: 38.7223, longitude: -9.1393, arrivalDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!, departureDate: nil, order: 0)
        ]
    )

    static let all: [Trip] = [tokyo, paris, lisbon]
}

/// Sample travel insights based on real travel data patterns
struct TravelInsightExamples {
    static let insights: [String: String] = [
        "frequent_flyer": "You've visited 4 countries this year — that's more than the average traveler. Your passport is getting a workout.",
        "city_hopper": "12 cities in one trip to Japan. You don't do shallow.",
        "slow_travel": "Your average stay is 4.2 days per city. You prefer depth over a stamp-collection approach to travel.",
        "globe_trotter": "You've traveled the equivalent of 1.3x around the world. The atlas is filling up nicely.",
        "train_lover": "60% of your European trips were by train. Lower footprint, better views.",
        "long_stay": "Your longest trip was 12 days in Japan. You know how to settle into a place.",
        "coastal": "7 of your 12 cities were coastal. You have a thing for the sea.",
        "food_travel": "You spent 3 days in Lyon. Nobody goes to Lyon just once.",
        "return_visitor": "You've been to Paris twice this year. Some cities pull you back.",
        "new_year": "You started 2025 in a new country. No bad way to begin a year."
    ]

    static let sampleInsight: String = insights["frequent_flyer"]!
}

/// Compelling copy about travel and memory
struct TravelCopy {
    static let taglines = [
        "Know where you've been.",
        "Every trip, quietly remembered.",
        "Your personal atlas, building itself.",
        "Where did you go last year? Perch knows.",
        "A map with your stamps on it.",
        "Travel leaves marks. Perch records them."
    ]

    static let emptyStateCopy = "Your map is blank. That changes the moment you start your first trip."

    static let activeTripCopy = "Your trip is running. Live it — Perch is watching quietly."

    static let yearEndCopy = "Another year of where. Here's your map."

    static let travelReflection = [
        "The places you've been shape who you are.",
        "Every city leaves something. You just have to remember where to look.",
        "A stamp in a passport. A coffee in a café. A sunset you'll never forget. Perch remembers all of it.",
        "Your travel history is the most personal map you own."
    ]
}
