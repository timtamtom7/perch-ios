# Perch — Bird Watching Companion App

## 1. Project Overview

**Project Name:** Perch  
**iOS App:** Perch (iPhone/iPad companion for field bird watching)  
**macOS App:** PerchMac (Menu bar companion showing life list, recent sightings, quick access)

**Core Functionality:** A bird watching companion that helps users log sightings, build a life list of species, explore species details, and discover birds in their region.

**Target Users:** Bird enthusiasts, amateur ornithologists, nature photographers, casual bird watchers

---

## 2. UI/UX Specification

### Screen Structure

#### iOS App (Perch)
1. **HomeView** — Dashboard with recent sightings, life list progress, seasonal highlights
2. **BirdSightingsView** — List of all logged sightings with filters and search
3. **SpeciesDetailView** — Detailed info about a specific species
4. **LifeListView** — Life list of all spotted species grouped by taxonomy
5. **MapView** — Map showing sighting locations with species pins
6. **AddSightingView** — Quick-add form to log a new sighting

#### macOS App (PerchMac)
1. **MenuBarView** — Menu bar extra with recent sighting and life list count
2. **PopoverView** — Expanded view with recent sightings, life list summary, quick actions

### Visual Design

**Color Palette:**
- Primary: Forest Green `#2D5016`
- Secondary: Sky Blue `#87CEEB`
- Accent: Bark Brown `#8B4513`
- Background: Cream `#FFF8DC`
- Surface: Warm Gray `#F5F5F0`
- Card: White `#FFFFFF`
- Text Primary: Dark Brown `#3D2914`
- Text Secondary: Muted Brown `#8B7355`

**Typography:**
- Headers: System font (San Francisco), Bold, 24-32pt
- Body: System font, Regular, 14-16pt
- Captions: System font, Light, 11-12pt
- Accents: System font, Italic (for scientific names)

**Spacing System:**
- Base unit: 8pt
- Card padding: 16pt
- Section spacing: 24pt
- Grid gap: 12pt

**Design Aesthetic:** Nature field guide — cream backgrounds, botanical illustration style, bird photography placeholders, handwritten-style accents, warm earthy tones

### Views & Components

#### Shared Components
- **BirdCardView** — Photo placeholder, common name, scientific name, date, location
- **SpeciesRowView** — Compact species row with thumbnail, name, spotted/unspotted state
- **ProgressRingView** — Circular progress indicator for life list completion
- **FilterChipView** — Tappable filter pills for species, date, location
- **SearchBarView** — Search input with nature-themed styling
- **MapPinView** — Custom map pin showing bird icon

#### Reusable States
- Empty state: Illustration + "Start your bird watching journey" CTA
- Loading state: Animated bird silhouette
- Error state: Friendly message with retry button

---

## 3. Functionality Specification

### Core Features

**iOS App (Priority Order):**
1. Log bird sightings (photo, species, date, time, location, notes)
2. Browse species database (300+ North American birds)
3. View life list progress by region
4. Search and filter sightings
5. Map view of all sighting locations
6. Species detail with habitats, migration patterns, sounds

**macOS App (PerchMac) - Menu Bar:**
1. Menu bar icon showing life list count badge
2. Popover with recent sighting
3. Quick link to open main iOS app
4. Today's highlighted species

### User Interactions & Flows

1. **Add Sighting Flow:**
   - Tap + button → Select species (search/browse) → Auto-fill date/time → Drop pin or use current location → Add photo → Save

2. **Browse Life List Flow:**
   - View grouped list (by family) → Tap species → See detail + sighting history

3. **Filter Sightings Flow:**
   - Open filters → Select species/location/date range → Apply → View filtered list

### Data Handling

- **Local Storage:** SQLite.swift for sightings, species database bundled as JSON
- **No Cloud Sync:** All data local (privacy-first)
- **Export:** Share sightings as text/image

### Architecture Pattern
- **SwiftUI** with Observable pattern
- **MVVM** structure
- Models: BirdSpecies, Sighting, Location, Region
- ViewModels: SightingsViewModel, LifeListViewModel, SpeciesViewModel
- Services: DatabaseService, LocationService

---

## 4. Technical Specification

### Dependencies (Swift Package Manager)
- SQLite.swift (local database)
- No external UI dependencies (pure SwiftUI)

### Asset Requirements
- App icon (nature-themed, bird silhouette)
- Species photos (placeholder illustrations)
- SF Symbols for UI icons (bird, location, calendar, camera)

### Platform Targets
- iOS: 17.0+
- macOS: 15.0+ (for menu bar apps)

### File Structure
```
Perch/
├── App/
│   └── PerchApp.swift
├── Models/
│   ├── BirdSpecies.swift
│   ├── Sighting.swift
│   └── Region.swift
├── ViewModels/
│   ├── SightingsViewModel.swift
│   ├── LifeListViewModel.swift
│   └── SpeciesViewModel.swift
├── Views/
│   ├── HomeView.swift
│   ├── BirdSightingsView.swift
│   ├── SpeciesDetailView.swift
│   ├── LifeListView.swift
│   ├── MapView.swift
│   └── AddSightingView.swift
├── Components/
│   ├── BirdCardView.swift
│   ├── SpeciesRowView.swift
│   ├── ProgressRingView.swift
│   ├── FilterChipView.swift
│   └── Theme.swift
├── Services/
│   ├── DatabaseService.swift
│   └── SpeciesDataService.swift
└── Resources/
    └── species_database.json

PerchMac/
├── main.swift
├── App/
│   └── PerchMacApp.swift
├── Views/
│   ├── MenuBarView.swift
│   ├── PopoverContentView.swift
│   ├── BirdSightingsView.swift
│   ├── SpeciesDetailView.swift
│   ├── LifeListView.swift
│   └── MapView.swift
├── Components/
│   └── Theme.swift
└── Resources/
    └── species_database.json
```

---

## 5. Iteration Roadmap

### R10 (Current)
- iOS app structure with all views
- Species database (300+ birds)
- Basic sighting logging
- Life list tracking

### R11 (Next)
- AI bird identification from photos (Vision framework)
- Rare bird alerts based on location
- Seasonal migration predictions

### R12 (Future)
- Community sightings map (anonymized)
- Bird watching events integration
- Expert species guides

### R13 (Polish)
- App Store listing
- Marketing assets
- Launch checklist
- User onboarding

---

## 6. Design Reference

### Nature Field Guide Aesthetic
- Background: Warm cream (#FFF8DC) reminiscent of aged paper
- Cards: White with subtle shadow, rounded corners (12pt)
- Typography: Clean sans-serif, scientific names in italic
- Icons: SF Symbols with nature theme (leaf, bird, camera)
- Accents: Handwritten-style annotations on photos
- Illustrations: Placeholder bird silhouettes in botanical style
