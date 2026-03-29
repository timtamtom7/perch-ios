# Perch R13 — Polish, App Store & Launch

## Overview
R13 focuses on polish, App Store preparation, and launch. All features complete, focus is on quality and readiness.

## App Store Preparation

### 1. App Store Assets

**Screenshots (Required):**
- 6.7" iPhone screenshots (1290 x 2796)
- 5.5" iPhone screenshots (1242 x 2208)
- iPad screenshots (2048 x 2732)
- App Store video preview (30 sec)

**Screenshot Content:**
1. Home screen with recent sightings
2. Map view with sighting pins
3. Species detail with photo
4. Life list progress
5. Add sighting flow
6. Community map layer

**App Icon:**
- 1024 x 1024 master icon
- All required sizes generated
- Design: Bird silhouette with leaf accent, forest green

### 2. App Store Copy

**Title:** Perch — Bird Watching Companion

**Subtitle:** Log sightings. Build your life list.

**Description:**
```
Perch is your personal bird watching companion.

📝 Log Sightings
Record birds you spot with photos, location, and notes. All data stays on your device.

🗺️ Explore Your World  
See all your sightings on a map. Discover where each species was found.

📋 Build Your Life List
Track every species you've ever seen. Progress through regions and families.

🔍 Species Database
300+ North American birds with detailed info, habitats, and migration patterns.

🎯 Seasonal Highlights
Know when and where to find each species based on migration predictions.

🔔 Rare Bird Alerts (R11)
Get notified when rare birds are spotted near you.

👥 Community Map (R12)
See aggregated sightings from other birders (anonymous).

📅 Bird Watching Events (R12)
Discover local tours, walks, and conservation events.

Privacy-first: All your data stays on your device.
```

**Keywords:**
```
bird watching, birding, bird identification, life list, ornithology,
sighting log, bird species, nature, wildlife, binoculars, field guide,
migratory birds, Audubon, bird calls, bird songs
```

**Category:** Reference → Education

**Age Rating:** 4+

### 3. Pre-Release Checklist

- [ ] TestFlight beta with 50+ external testers
- [ ] Beta feedback incorporated
- [ ] Privacy Policy URL ready
- [ ] Support URL ready
- [ ] Marketing URL ready (optional)
- [ ] All 300+ species data verified
- [ ] No placeholder content
- [ ] Crash reporting enabled (Firebase/CloudKit)
- [ ] Analytics enabled (optional)
- [ ] App Store Connect account configured
- [ ] Banking/tax info complete for paid apps
- [ ] Export Compliance documentation ready

## Polish & Quality

### 1. Performance Optimization
- Lazy loading for all lists
- Image caching and compression
- Database query optimization
- Smooth 60fps scrolling

### 2. Accessibility
- VoiceOver labels on all interactive elements
- Dynamic Type support
- Minimum touch target 44x44pt
- Color contrast ratios > 4.5:1

### 3. Localization Ready
- All strings in Localizable.strings
- RTL layout support
- Date/time localization
- Spanish translation (Phase 1)

### 4. Error Handling
- Graceful offline mode
- Network error states
- Empty state designs
- Retry mechanisms

## Launch Strategy

### Week 1: Soft Launch
- Release to TestFlight external
- Announce on social media
- Submit to Product Hunt

### Week 2: App Store Submit
- Submit for App Store review
- Prepare press release
- Line up initial reviews

### Week 3: Launch Day
- Release to App Store
- Announce across channels
- Monitor crash reports
- Respond to initial reviews

### Week 4: Post-Launch
- Address any critical bugs
- Gather user feedback
- Plan first content update

## Metrics to Track
- Downloads
- DAU/MAU
- Sightings logged per user
- Life list completion rates
- Crash-free sessions
- App Store rating
- Review sentiment

## File Structure Final

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
    ├── species_database.json
    └── Assets.xcassets

PerchMac/
├── main.swift
├── App/
│   └── AppDelegate.swift
├── Views/
│   ├── PopoverContentView.swift
│   ├── MenuBarView.swift
│   ├── BirdSightingsView.swift
│   ├── SpeciesDetailView.swift
│   ├── LifeListView.swift
│   └── MapView.swift
├── ViewModels/
│   ├── SightingsViewModel.swift
│   └── LifeListViewModel.swift
├── Components/
│   └── Theme.swift
└── Resources/
    └── Assets.xcassets
```

## Post-Launch Roadmap
- R14: Social sharing, challenges, achievements
- R15: Apple Watch companion
- R16: iPad optimization, widgets
