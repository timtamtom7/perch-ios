# Perch R12 — Community, Events & Expert Guides

## Overview
R12 adds social features: an anonymized community sightings map, bird watching events integration, and expert-authored species guides.

## Features

### 1. Community Sightings Map (Anonymized)
**Description:** See aggregate sighting data from other Perch users without revealing individual identities.

**Implementation:**
- Aggregate sightings by geographic grid (1km x 1km cells)
- Show only species presence (not exact locations or counts)
- No user-identifiable data ever leaves device
- Weekly data sync when on WiFi

**Privacy Model:**
```
Grid Cell Data:
{
  cellId: "lat_lng_hash",  // hashed coordinates
  speciesIds: ["amro", "rthu"],  // species present
  weekOfYear: 14,
  totalSightings: 47  // aggregate only
}
```

**UI:**
- Toggle layer on/off in Map view
- Species presence shown as subtle heat map
- "Community Sightings" distinct from personal sightings
- Privacy badge: "Aggregated & Anonymous"

### 2. Bird Watching Events
**Description:** Discover local bird watching events and tours.

**Implementation:**
- Curated list of events (Nature Conservancy, Audubon, local clubs)
- Integration with Eventbrite API for public events
- Calendar view of upcoming events
- RSVP/reminder functionality

**Data Source:**
- Pre-seeded list of major events
- RSS/API feeds from partner organizations
- User can submit event suggestions

**UI:**
- Events tab on Home screen
- Map pins for event locations
- Event cards with date, location, species highlight
- "Add to Calendar" integration

**Event Types:**
- Audubon Society Walks
- Christmas Bird Counts
- Nature Photography Tours
- Conservation Workdays
- Expert-Led Field Trips

### 3. Expert Species Guides
**Description:** Rich, expert-authored content for top 100 most-watched species.

**Implementation:**
- Partner with ornithologists and birding experts
- Structured guide format:
  - Identification tips
  - Voice & calls
  - Behavior notes
  - Best viewing locations
  - Photography tips
  - Similar species comparison
- Content stored locally, updated periodically

**Guide Structure:**
```swift
struct ExpertGuide {
    let speciesId: String
    let author: String
    let lastUpdated: Date
    let sections: [GuideSection]
    let tips: [String]  // Quick tips
    let similarSpecies: [String]  // IDs
    let bestLocations: [BestLocation]
}

struct GuideSection {
    let title: String
    let content: String
    let images: [String]  // Asset names
}
```

**UI:**
- "Guide" button on Species Detail
- Expandable sections
- Audio player for calls/songs
- Share guide functionality

## File Structure Changes

```
Perch/
├── Views/
│   ├── EventsView.swift              // NEW
│   ├── CommunityMapView.swift        // NEW - layer on existing map
│   └── ExpertGuideView.swift         // NEW
├── Models/
│   ├── Event.swift                   // NEW
│   ├── CommunitySighting.swift       // NEW
│   └── ExpertGuide.swift             // NEW
├── Services/
│   ├── CommunityDataService.swift    // NEW - sync logic
│   └── EventsService.swift           // NEW
└── Resources/
    └── expert_guides.json             // NEW - bundled guides
```

## Dependencies
- EventKit (calendar integration) - system
- No new external dependencies

## API Design (Future Backend)

**Community Data Sync:**
```
POST /api/v1/sightings/aggregate
Body: { sightings: [...], gridCells: [...] }
Response: { updates: { cellId: CommunityCell } }
```

**Events:**
```
GET /api/v1/events?lat=&lng=&radius=50
Response: { events: [...] }
```

## Testing Plan
1. Verify anonymity in community data
2. Test calendar integration
3. Review all expert guide content
4. Load test community sync

## Success Metrics
- 100+ expert guides available
- 50+ events per major metro area
- Community data covers 1000+ grid cells
- Zero PII in community data
