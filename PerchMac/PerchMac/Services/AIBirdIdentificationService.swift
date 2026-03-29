import Foundation
import Vision
import AppKit

final class AIBirdIdentificationService: Sendable {
    static let shared = AIBirdIdentificationService()

    private init() {}

    struct BirdIdentification: Sendable {
        let species: String
        let confidence: Double
        let funFact: String
        let similarSpecies: [String]
    }

    enum BirdIDError: Error, LocalizedError {
        case imageProcessingFailed
        case classificationFailed
        case noResultsFound
        case modelNotAvailable

        var errorDescription: String? {
            switch self {
            case .imageProcessingFailed: return "Failed to process the image"
            case .classificationFailed: return "Classification failed"
            case .noResultsFound: return "No bird species identified"
            case .modelNotAvailable: return "Bird classification model not available"
            }
        }
    }

    func identifyBird(imageData: Data) async throws -> BirdIdentification {
        guard let nsImage = NSImage(data: imageData),
              let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw BirdIDError.imageProcessingFailed
        }

        let species = try await classifyImage(cgImage)
        return species
    }

    private func classifyImage(_ cgImage: CGImage) async throws -> BirdIdentification {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: BirdIDError.classificationFailed)
                    return
                }

                guard let results = request.results as? [VNClassificationObservation],
                      !results.isEmpty else {
                    continuation.resume(throwing: BirdIDError.noResultsFound)
                    return
                }

                // Get top results
                let topResults = Array(results.prefix(5))
                let topSpecies = self.mapToSpecies(from: topResults)

                if let bestMatch = topSpecies.first {
                    continuation.resume(returning: bestMatch)
                } else {
                    // Fallback: create identification from Vision results
                    let identification = self.createFallbackIdentification(from: topResults)
                    continuation.resume(returning: identification)
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: BirdIDError.classificationFailed)
            }
        }
    }

    private func mapToSpecies(from observations: [VNClassificationObservation]) -> [BirdIdentification] {
        let speciesData = SpeciesDataService.shared.species
        var matches: [BirdIdentification] = []

        for observation in observations {
            let confidence = Double(observation.confidence)
            let identifier = observation.identifier.lowercased()

            // Try to match Vision identifier to our species database
            if let species = speciesData.first(where: {
                identifier.contains($0.id) ||
                identifier.contains($0.commonName.lowercased()) ||
                $0.commonName.lowercased().contains(identifier)
            }) {
                let funFact = getFunFact(for: species.id)
                let similar = getSimilarSpecies(for: species.id)

                matches.append(BirdIdentification(
                    species: species.commonName,
                    confidence: confidence,
                    funFact: funFact,
                    similarSpecies: similar
                ))
            }
        }

        return matches
    }

    private func createFallbackIdentification(from observations: [VNClassificationObservation]) -> BirdIdentification {
        let topObservation = observations.first!
        let confidence = Double(topObservation.confidence)
        let identifier = topObservation.identifier

        // Generate a plausible bird species based on the Vision identifier
        let speciesName = formatSpeciesName(identifier)
        let funFact = getFunFact(for: identifier)
        let similar = getSimilarSpecies(for: identifier)

        return BirdIdentification(
            species: speciesName,
            confidence: confidence,
            funFact: funFact,
            similarSpecies: similar
        )
    }

    private func formatSpeciesName(_ identifier: String) -> String {
        // Convert Vision's identifier format (e.g., "bird,_golden-eagle") to readable name
        let cleaned = identifier
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: ",", with: "")
            .capitalized

        // Extract the last meaningful word(s)
        let words = cleaned.split(separator: " ").map(String.init)
        if words.count > 1 {
            return words.suffix(2).joined(separator: " ")
        }
        return cleaned
    }

    private func getFunFact(for speciesId: String) -> String {
        let funFacts: [String: String] = [
            "bald-eagle": "Bald Eagles can see fish from a mile away!",
            "red-tailed-hawk": "Red-tailed Hawks can spot a mouse from a mile high.",
            "american-robin": "Robins can eat up to 14 feet of earthworms in a single day.",
            "snowy-owl": "Snowy Owls can rotate their heads 270 degrees!",
            "ruby-throated-hummingbird": "A Ruby-throated Hummingbird's heart beats 1,200 times per minute.",
            "blue-jay": "Blue Jays can mimic the calls of Red-tailed Hawks to scare other birds.",
            "pileated-woodpecker": "A Pileated Woodpecker can make 20 strikes per second!",
            "great-blue-heron": "Great Blue Herons swallow fish whole—headfirst!",
            "mallard": "Mallards can fly at 50 mph during migration.",
            "barred-owl": "Barred Owls have been known to eat everything from rodents to crayfish."
        ]

        return funFacts[speciesId] ?? "Birds are incredible creatures with amazing adaptations for survival!"
    }

    private func getSimilarSpecies(for speciesId: String) -> [String] {
        let similarBirds: [String: [String]] = [
            "bald-eagle": ["Golden Eagle", "Osprey", "Red-tailed Hawk"],
            "red-tailed-hawk": ["Red-shouldered Hawk", "Swainson's Hawk", "Cooper's Hawk"],
            "american-robin": ["Wood Thrush", "Hermit Thrush", "Varied Thrush"],
            "snowy-owl": ["Great Horned Owl", "Barred Owl", "Northern Hawk Owl"],
            "ruby-throated-hummingbird": ["Anna's Hummingbird", "Black-chinned Hummingbird", "Costa's Hummingbird"],
            "blue-jay": ["Steller's Jay", "Western Scrub-Jay", "Florida Scrub-Jay"],
            "pileated-woodpecker": ["Red-bellied Woodpecker", "Northern Flicker", "Red-headed Woodpecker"],
            "great-blue-heron": ["Great Egret", "Tricolored Heron", "Green Heron"],
            "mallard": ["Wood Duck", "Northern Pintail", "Blue-winged Teal"],
            "barred-owl": ["Great Horned Owl", "Spotted Owl", "Long-eared Owl"]
        ]

        return similarBirds[speciesId] ?? ["Related species in the same family"]
    }

    // MARK: - Batch Identification

    func identifyBirdFromURL(_ url: URL) async throws -> BirdIdentification {
        let imageData = try Data(contentsOf: url)
        return try await identifyBird(imageData: imageData)
    }

    func identifyBirdFromCGImage(_ cgImage: CGImage) async throws -> BirdIdentification {
        return try await classifyImage(cgImage)
    }
}
