# Perch R11 — AI Bird ID, Rare Bird Alerts & Migration Predictions

## Overview
R11 adds intelligent features: AI-powered bird identification from photos, real-time rare bird alerts, and ML-based seasonal migration predictions.

## Features

### 1. AI Bird Identification from Photos
**Description:** Use Apple's Vision framework to identify birds from camera photos.

**Implementation:**
- Add `Vision` framework integration
- Create `BirdClassifier` service using Core ML
- Train/deploy bird classification model (MobileNet-based)
- Show top 3 matches with confidence scores
- Allow user to confirm or correct identification

**UI Flow:**
1. User takes/selects photo
2. App analyzes image with Vision + Core ML
3. Shows identification results with confidence
4. User confirms → creates sighting automatically

**Technical Details:**
- Use `VNClassifyImageRequest` with custom bird classifier
- Bundle pre-trained bird species model (~50MB)
- Fallback to manual species selection if confidence < 60%

### 2. Rare Bird Alerts
**Description:** Push notifications when rare birds are spotted in user's region.

**Implementation:**
- Define "rarity score" per species (1-10 based on sighting frequency)
- User sets alert threshold (e.g., rarity > 7)
- When new sighting matches criteria → local notification
- Use location-based filtering (within 50km of user)

**Rarity Scoring:**
```
Rarity Score = 10 - log10(totalSightingsInRegion)
Cap at 10, floor at 1
```

**UI:**
- Settings screen to configure alert threshold
- Toggle alerts on/off per region
- Notification: "🚨 Rare Bird Alert: [Species] spotted at [Location]!"

### 3. Seasonal Migration Predictions
**Description:** ML-based predictions for when species will arrive/depart region.

**Implementation:**
- Train simple model on historical sighting dates per species
- Predict arrival/departure windows (first/last sighting dates)
- Show "Best Time to See" calendar view
- Display migration status: "Arriving", "Peak Season", "Departing", "Not Expected"

**Data Model:**
```swift
struct MigrationPrediction {
    let speciesId: String
    let typicalArrival: Date // median first sighting
    let typicalDeparture: Date // median last sighting
    let peakStart: Date
    let peakEnd: Date
    let confidence: Double // based on data availability
}
```

**UI:**
- Species detail shows migration timeline bar
- Home shows "Best Spots This Season" based on predictions
- Calendar view with color-coded migration status

## File Structure Changes

```
Perch/
├── Services/
│   ├── BirdClassifierService.swift  // NEW - Vision + Core ML
│   ├── RareBirdAlertService.swift   // NEW - Alert engine
│   └── MigrationPredictionService.swift // NEW - ML predictions
├── Resources/
│   └── BirdClassifier.mlmodel       // NEW - Core ML model
└── Models/
    └── MigrationPrediction.swift    // NEW
```

## Dependencies
- Vision framework (system)
- Core ML (system)
- UserNotifications framework (system)
- No external dependencies

## Testing Plan
1. Test AI classification with 50 test photos
2. Verify alert threshold filtering works
3. Validate migration predictions against historical data
4. Test notification permissions flow

## Success Metrics
- AI ID accuracy > 85% for top 50 common species
- Zero false rare bird alerts
- Migration predictions within ±5 days of actual
