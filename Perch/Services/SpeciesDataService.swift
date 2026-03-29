import Foundation

final class SpeciesDataService: Sendable {
    static let shared = SpeciesDataService()

    nonisolated let species: [BirdSpecies]

    private init() {
        species = Self.generateSpeciesDatabase()
    }

    private static func generateSpeciesDatabase() -> [BirdSpecies] {
        var birds: [BirdSpecies] = []

        // MARK: - Waterfowl
        let waterfowl: [(String, String, String)] = [
            ("Mallard", "Anas platyrhynchos", "Common in ponds, lakes, and marshes."),
            ("Wood Duck", "Aix sponsa", "One of the most colorful North American waterfowl."),
            ("Canada Goose", "Branta canadensis", "Familiar goose seen in parks."),
            ("Snow Goose", "Anser caerulescens", "Breeds in Arctic, winters south."),
            ("Tundra Swan", "Cygnus columbianus", "Breeds in Arctic tundra."),
            ("Northern Pintail", "Anas acuta", "Elegant duck with long tail."),
            ("Blue-winged Teal", "Spatula discors", "Small dabbling duck."),
            ("Green-winged Teal", "Anas crecca", "Smallest North American duck."),
            ("Canvasback", "Aythya valisineria", "Diving duck with sloping profile."),
            ("Redhead", "Aythya americana", "Diving duck with rusty-red head."),
            ("Ring-necked Duck", "Aythya collaris", "Diving duck with distinctive ring."),
            ("Greater Scaup", "Aythya marila", "Diving duck of large waters."),
            ("Lesser Scaup", "Aythya affinis", "Smallest diving duck."),
            ("Bufflehead", "Bucephala albeola", "Small diving duck."),
            ("Common Goldeneye", "Bucephala clangula", "Diving duck with odd head shape."),
            ("Hooded Merganser", "Lophodytes cucullatus", "Small diving duck."),
            ("Common Merganser", "Mergus merganser", "Large diving duck."),
            ("Red-breasted Merganser", "Mergus serrator", "Coastal diving duck."),
            ("Ruddy Duck", "Oxyura jamaicensis", "Small diving duck with spiky tail."),
            ("Muscovy Duck", "Cairina moschata", "Large duck of Central America."),
        ]

        // MARK: - Hawks & Eagles
        let hawks: [(String, String, String)] = [
            ("Bald Eagle", "Haliaeetus leucocephalus", "Iconic American raptor."),
            ("Golden Eagle", "Aquila chrysaetos", "Large dark eagle of the West."),
            ("Red-tailed Hawk", "Buteo jamaicensis", "Most common North American hawk."),
            ("Red-shouldered Hawk", "Buteo lineatus", "Woodland hawk."),
            ("Broad-winged Hawk", "Buteo platypterus", "Hawk that migrates in flocks."),
            ("Swainson's Hawk", "Buteo swainsoni", "Prairie hawk."),
            ("Cooper's Hawk", "Accipiter cooperii", "Woodland hunting hawk."),
            ("Sharp-shinned Hawk", "Accipiter striatus", "Smallest accipiter."),
            ("Northern Goshawk", "Accipiter gentilis", "Large woodland hawk."),
            ("Osprey", "Pandion haliaetus", "Fish-eating raptor."),
            ("American Kestrel", "Falco sparverius", "Smallest North American falcon."),
            ("Merlin", "Falco columbarius", "Small fast falcon."),
            ("Peregrine Falcon", "Falco peregrinus", "Fastest animal on Earth."),
            ("Gyrfalcon", "Falco rusticolus", "Large Arctic falcon."),
            ("Prairie Falcon", "Falco mexicanus", "Falcon of western prairies."),
            ("Northern Harrier", "Circus hudsonius", "Low-flying marsh hawk."),
            ("White-tailed Kite", "Elanus leucurus", "Elegant open-country hawk."),
            ("Swallow-tailed Kite", "Elanoides forficatus", "Stunning black-and-white kite."),
        ]

        // MARK: - Herons
        let herons: [(String, String, String)] = [
            ("Great Blue Heron", "Ardea herodias", "Large heron of wetlands."),
            ("Great Egret", "Ardea alba", "Large white heron."),
            ("Snowy Egret", "Egretta thula", "Small white heron."),
            ("Little Blue Heron", "Egretta caerulea", "Dark heron of southern coasts."),
            ("Tricolored Heron", "Egretta tricolor", "Slender coastal heron."),
            ("Reddish Egret", "Egretta rufescens", "Heron with two color morphs."),
            ("Cattle Egret", "Bubulcus ibis", "Heron that follows cattle."),
            ("Green Heron", "Butorides virescens", "Small heron of wooded ponds."),
            ("Black-crowned Night-Heron", "Nycticorax nycticorax", "Nocturnal heron."),
            ("Yellow-crowned Night-Heron", "Nyctanassa violacea", "Coastal night heron."),
            ("American Bittern", "Botaurus lentiginosus", "Secretive marsh heron."),
            ("Least Bittern", "Ixobrychus exilis", "Smallest North American heron."),
        ]

        // MARK: - Shorebirds
        let shorebirds: [(String, String, String)] = [
            ("Killdeer", "Charadrius vociferus", "Plover with broken-wing display."),
            ("Semipalmated Plover", "Charadrius semipalmatus", "Small beach plover."),
            ("Piping Plover", "Charadrius melodus", "Endangered beach plover."),
            ("Snowy Plover", "Charadrius nivosus", "Small western beach plover."),
            ("Black-bellied Plover", "Pluvialis squatarola", "Large beach plover."),
            ("American Golden-Plover", "Pluvialis dominica", "Elegant Arctic plover."),
            ("Spotted Sandpiper", "Actitis macularius", "Tail-bobbing sandpiper."),
            ("Solitary Sandpiper", "Tringa solitaria", "Wooded pond sandpiper."),
            ("Greater Yellowlegs", "Tringa melanoleuca", "Large shorebird with yellow legs."),
            ("Willet", "Tringa semipalmata", "Large shorebird."),
            ("Lesser Yellowlegs", "Tringa flavipes", "Medium shorebird."),
            ("Marbled Godwit", "Limosa fedoa", "Large upcurved-bill shorebird."),
            ("Sanderling", "Calidris alba", "Wave-chasing sandpiper."),
            ("Western Sandpiper", "Calidris mauri", "Small sandpiper."),
            ("Least Sandpiper", "Calidris minutilla", "Smallest shorebird."),
            ("White-rumped Sandpiper", "Calidris fuscicollis", "Sandpiper with white rump."),
            ("Dunlin", "Calidris alpina", "Common decurved-bill sandpiper."),
            ("Stilt Sandpiper", "Calidris himantopus", "Long-legged sandpiper."),
            ("American Avocet", "Recurvirostra americana", "Elegant upcurved bill."),
            ("Black-necked Stilt", "Himantopus mexicanus", "Black-and-white shorebird."),
            ("Ruddy Turnstone", "Arenaria interpres", "Stone-turning shorebird."),
            ("Red Knot", "Calidris canutus", "Rufous-breasted shorebird."),
        ]

        // MARK: - Gulls & Terns
        let gulls: [(String, String, String)] = [
            ("Herring Gull", "Larus argentatus", "Common large gull."),
            ("Ring-billed Gull", "Larus delawarensis", "Most common urban gull."),
            ("Laughing Gull", "Leucophaeus atricilla", "Dark-headed coastal gull."),
            ("Bonaparte's Gull", "Chroicocephalus philadelphia", "Small forest-nesting gull."),
            ("Mew Gull", "Larus canus", "Medium-sized gull."),
            ("Lesser Black-backed Gull", "Larus fuscus", "Dark-backed European gull."),
            ("Glaucous Gull", "Larus hyperboreus", "Large pale Arctic gull."),
            ("Great Black-backed Gull", "Larus marinus", "Largest gull."),
            ("Black Tern", "Chlidonias niger", "Small dark tern."),
            ("Common Tern", "Sterna hirundo", "Typical medium tern."),
            ("Forster's Tern", "Sterna forsteri", "Marsh tern."),
            ("Caspian Tern", "Hydroprogne caspia", "Large red-billed tern."),
            ("Royal Tern", "Thalasseus maximus", "Large coastal tern."),
        ]

        // MARK: - Doves & Pigeons
        let doves: [(String, String, String)] = [
            ("Mourning Dove", "Zenaida macroura", "Slender-tailed dove."),
            ("Eurasian Collared-Dove", "Streptopelia decaocto", "Recent North American colonist."),
            ("Rock Pigeon", "Columba livia", "Common city bird."),
            ("White-winged Dove", "Zenaida asiatica", "Southwestern dove."),
            ("Inca Dove", "Columbina inca", "Scaled desert dove."),
            ("Common Ground-Dove", "Columbina passerina", "Tiny ground dove."),
            ("Band-tailed Pigeon", "Patagioenas fasciata", "Western forest pigeon."),
            ("European Turtle-Dove", "Streptopelia turtur", "Declining European dove."),
        ]

        // MARK: - Owls
        let owls: [(String, String, String)] = [
            ("Great Horned Owl", "Bubo virginianus", "Most common large owl."),
            ("Snowy Owl", "Bubo scandiacus", "Iconic white Arctic owl."),
            ("Eastern Screech-Owl", "Megascops asio", "Small ear-tufted owl."),
            ("Western Screech-Owl", "Megascops kennicottii", "Western small ear-tufted owl."),
            ("Barn Owl", "Tyto alba", "Heart-shaped face owl."),
            ("Barred Owl", "Strix varia", "Brown-striped woodland owl."),
            ("Great Gray Owl", "Strix nebulosa", "Largest owl by length."),
            ("Long-eared Owl", "Asio otus", "Ear-tufted dense forest owl."),
            ("Short-eared Owl", "Asio flammeus", "Open country ear-tufted owl."),
            ("Northern Saw-whet Owl", "Aegolius acadicus", "Tiny owl."),
            ("Burrowing Owl", "Athene cunicularia", "Ground-dwelling owl."),
            ("Northern Spotted Owl", "Strix occidentalis", "Old growth forest owl."),
        ]

        // MARK: - Hummingbirds
        let hummingbirds: [(String, String, String)] = [
            ("Ruby-throated Hummingbird", "Archilochus colubris", "Only eastern hummer."),
            ("Black-chinned Hummingbird", "Archilochus alexandri", "Western hummingbird."),
            ("Anna's Hummingbird", "Calypte anna", "Year-round West Coast hummer."),
            ("Costa's Hummingbird", "Calypte costae", "Desert southwestern hummer."),
            ("Broad-tailed Hummingbird", "Selasphorus platycercus", "Rocky Mountain hummer."),
            ("Rufous Hummingbird", "Selasphorus rufus", "Aggressive far-north migrating hummer."),
            ("Calliope Hummingbird", "Selasphorus calliope", "Smallest North American bird."),
            ("Broad-billed Hummingbird", "Cynanthus latirostris", "Brilliant blue southwestern hummer."),
            ("Violet-crowned Hummingbird", "Amazilia violiceps", "Southwestern hummer."),
        ]

        // MARK: - Woodpeckers
        let woodpeckers: [(String, String, String)] = [
            ("Downy Woodpecker", "Dryobates pubescens", "Smallest North American woodpecker."),
            ("Hairy Woodpecker", "Dryobates villosus", "Medium large woodpecker."),
            ("Pileated Woodpecker", "Dryocopus pileatus", "Crow-sized woodpecker."),
            ("Northern Flicker", "Colaptes auratus", "Ground-feeding woodpecker."),
            ("Red-bellied Woodpecker", "Melanerpes carolinus", "Eastern woodpecker."),
            ("Red-headed Woodpecker", "Melanerpes erythrocephalus", "Fully red-headed woodpecker."),
            ("Yellow-bellied Sapsucker", "Sphyrapicus varius", "Sapsucker with red crown."),
            ("American Three-toed Woodpecker", "Picoides dorsalis", "Northern mountain woodpecker."),
            ("Black-backed Woodpecker", "Picoides arcticus", "Fire-following woodpecker."),
            ("Gila Woodpecker", "Melanerpes uropygialis", "Southwestern desert woodpecker."),
            ("Lewis's Woodpecker", "Melanerpes lewis", "Crow-like western woodpecker."),
            ("Acorn Woodpecker", "Melanerpes formicivorus", "Acorn-storing woodpecker."),
        ]

        // MARK: - Thrushes
        let thrushes: [(String, String, String)] = [
            ("American Robin", "Turdus migratorius", "Familiar lawn bird."),
            ("Wood Thrush", "Hylocichla mustelina", "Flute-song forest thrush."),
            ("Hermit Thrush", "Catharus guttatus", "Pine-scented forest thrush."),
            ("Swainson's Thrush", "Catharus ustulatus", "Buffy-spectacled thrush."),
            ("Veery", "Catharus fuscescens", "Ringing song thrush."),
            ("Gray-cheeked Thrush", "Catharus minimus", "Northern forest thrush."),
            ("Bicknell's Thrush", "Catharus bicknalli", "Mountain peak thrush."),
            ("Varied Thrush", "Ixoreus naevius", "Pacific Northwest thrush."),
            ("Eastern Bluebird", "Sialia sialis", "Blue open-field bird."),
            ("Western Bluebird", "Sialia mexicana", "Western forest bluebird."),
            ("Mountain Bluebird", "Sialia currucoides", "Open western bluebird."),
            ("Townsend's Solitaire", "Myadestes townsendi", "Gray mountain thrush."),
            ("Brown Thrasher", "Toxostoma rufum", "1000+ song types."),
            ("Curve-billed Thrasher", "Toxostoma curvirostre", "Southwest desert thrasher."),
            ("Northern Mockingbird", "Mimus polyglottos", "Sound mimic."),
        ]

        // MARK: - Sparrows
        let sparrows: [(String, String, String)] = [
            ("House Sparrow", "Passer domesticus", "Common urban sparrow."),
            ("Song Sparrow", "Melospiza melodia", "Variable song sparrow."),
            ("White-throated Sparrow", "Zonotrichia albicollis", "Bold head-striped sparrow."),
            ("White-crowned Sparrow", "Zonotrichia leucophrys", "Pink-billed sparrow."),
            ("Golden-crowned Sparrow", "Zonotrichia atricapilla", "Golden-crowned sparrow."),
            ("Fox Sparrow", "Passerella iliaca", "Large reddish sparrow."),
            ("Lincoln's Sparrow", "Melospiza lincolnii", "Finely streaked sparrow."),
            ("Swamp Sparrow", "Melospiza georgiana", "Wetland sparrow."),
            ("Chipping Sparrow", "Spizella passerina", "Rufous-capped sparrow."),
            ("Clay-colored Sparrow", "Spizella pallida", "Prairie edge sparrow."),
            ("Field Sparrow", "Spizella pusilla", "Pink-billed field sparrow."),
            ("Vesper Sparrow", "Pooecetes gramineus", "White-tailed sparrow."),
            ("Savannah Sparrow", "Passerculus sandwichensis", "Yellow-eyebrowed sparrow."),
            ("Dark-eyed Junco", "Junco hyemalis", "Winter slate sparrow."),
            ("Yellow-eyed Junco", "Junco phaeonotus", "Southern mountain junco."),
            ("Harris's Sparrow", "Zonotrichia querula", "Black-bibbed sparrow."),
        ]

        // MARK: - Finches
        let finches: [(String, String, String)] = [
            ("House Finch", "Haemorhous mexicanus", "Red-crowned western finch."),
            ("Purple Finch", "Haemorhous purpureus", "Raspberry-capped finch."),
            ("Red Crossbill", "Loxia curvirostra", "Crossed-bill finch."),
            ("White-winged Crossbill", "Loxia leucoptera", "White-barred crossbill."),
            ("Common Redpoll", "Acanthis flammea", "Far northern finch."),
            ("Pine Siskin", "Spinus pinus", "Yellow-winged siskin."),
            ("American Goldfinch", "Spinus tristis", "Black-capped yellow finch."),
            ("Lesser Goldfinch", "Spinus psaltria", "Small western finch."),
            ("Evening Grosbeak", "Hesperiphona vespertina", "Huge-billed finch."),
            ("Pine Grosbeak", "Pinicola enucleator", "Northern forest grosbeak."),
        ]

        // MARK: - Blackbirds & Orioles
        let blackbirds: [(String, String, String)] = [
            ("Red-winged Blackbird", "Agelaius phoeniceus", "Red-shouldered blackbird."),
            ("Tricolored Blackbird", "Agelaius tricolor", "California marsh blackbird."),
            ("Yellow-headed Blackbird", "Xanthocephalus xanthocephalus", "Yellow-headed marsh bird."),
            ("Rusty Blackbird", "Euphagus carolinus", "Northern wetland blackbird."),
            ("Brewer's Blackbird", "Euphagus cyanocephalus", "Western common blackbird."),
            ("Common Grackle", "Quiscalus quiscula", "Iridescent eastern blackbird."),
            ("Great-tailed Grackle", "Quiscalus mexicanus", "Large-tailed grackle."),
            ("Orchard Oriole", "Icterus spurius", "Chestnut oriole."),
            ("Bullock's Oriole", "Icterus bullockii", "Western orange oriole."),
            ("Baltimore Oriole", "Icterus galbula", "Eastern orange oriole."),
            ("Scott's Oriole", "Icterus parisorum", "Southwestern desert oriole."),
            ("Bobolink", "Dolichonyx oryzivorus", "White-rumped summer blackbird."),
            ("Eastern Meadowlark", "Sturnella magna", "Yellow-breasted field bird."),
            ("Western Meadowlark", "Sturnella neglecta", "Western field bird."),
        ]

        // MARK: - Warblers
        let warblers: [(String, String, String)] = [
            ("Yellow Warbler", "Setophaga petechia", "Bright yellow wetland warbler."),
            ("Magnolia Warbler", "Setophaga magnolia", "Black-necklaced warbler."),
            ("Yellow-rumped Warbler", "Setophaga coronata", "Most common warbler."),
            ("Black-throated Blue Warbler", "Setophaga caerulescens", "Blue upperparts warbler."),
            ("Palm Warbler", "Setophaga palmarum", "Tail-wagging warbler."),
            ("Pine Warbler", "Setophaga pinus", "Pine forest warbler."),
            ("Yellow-throated Warbler", "Setophaga dominica", "Yellow-throated treetop warbler."),
            ("Black-throated Green Warbler", "Setophaga virens", "Green-backed warbler."),
            ("Blackburnian Warbler", "Setophaga fusca", "Orange-throated warbler."),
            ("Black-and-white Warbler", "Mniotilta varia", "Striped creeping warbler."),
            ("American Redstart", "Setophaga ruticilla", "Orange-patched warbler."),
            ("Prothonotary Warbler", "Protonotaria citrea", "Brilliant golden warbler."),
            ("Common Yellowthroat", "Geothlypis trichas", "Black-masked warbler."),
            ("Hooded Warbler", "Setophaga citrina", "Yellow-hooded warbler."),
            ("Wilson's Warbler", "Cardellina pusilla", "Black-capped warbler."),
            ("Canada Warbler", "Cardellina canadensis", "Necklaced warbler."),
            ("Ovenbird", "Seiurus aurocapilla", "Ground-nesting warbler."),
            ("Northern Waterthrush", "Parkesia noveboracensis", "Bobbing wetland warbler."),
        ]

        // MARK: - Kingfishers & Others
        let otherBirds: [(String, String, String)] = [
            ("Belted Kingfisher", "Megaceryle alcyon", "Diving fish-eating bird."),
            ("Pied-billed Grebe", "Podilymbus podiceps", "Chicken-billed grebe."),
            ("Horned Grebe", "Podiceps auritus", "Golden head-plumed grebe."),
            ("American Coot", "Fulica americana", "Rail-like wetland bird."),
            ("Killdeer", "Charadrius vociferus", "Plover with broken-wing display."),
            ("American Woodcock", "Scolopax minor", "Dusk field bird."),
            ("Common Nighthawk", "Chordeiles minor", "Dusk insect hunter."),
            ("Chimney Swift", "Chaetura pelagica", "Tube-tailed aerial bird."),
            ("Ruby-throated Hummingbird", "Archilochus colubris", "Only eastern hummer."),
            ("Northern Rough-winged Swallow", "Stelgidopteryx serripennis", "Brownish swallow."),
            ("Purple Martin", "Progne subis", "Largest swallow."),
            ("Tree Swallow", "Tachycineta bicolor", "Iridescent blue swallow."),
            ("Barn Swallow", "Hirundo rustica", "Forked-tail swallow."),
            ("Cliff Swallow", "Petrochelidon pyrrhonota", "Gourd-nest swallow."),
            ("House Wren", "Troglodytes aedon", "Small singing bird."),
            ("Winter Wren", "Troglodytes hiemalis", "Tiny rounded wren."),
            ("Carolina Wren", "Thryothorus ludovicianus", "Large southern wren."),
            ("White-breasted Nuthatch", "Sitta carolinensis", "Upside-down tree bird."),
            ("Red-breasted Nuthatch", "Sitta canadensis", "Small nuthatch with eyeline."),
            ("Brown Creeper", "Certhia americana", "Tree-spiraling bird."),
            ("Blue-gray Gnatcatcher", "Polioptila caerulea", "Tiny blue-gray bird."),
            ("Golden-crowned Kinglet", "Regulus satrapa", "Tiny crested kinglet."),
            ("Ruby-crowned Kinglet", "Corthylio calendula", "Tiny kinglet with red crown."),
            ("Black-capped Chickadee", "Poeciles atricapillus", "Familiar black-capped bird."),
            ("Mountain Chickadee", "Poeciles gambeli", "Western mountain chickadee."),
            ("Bohemian Waxwing", "Bombycilla garrulus", "Northern silky bird."),
            ("Cedar Waxwing", "Bombycilla cedrorum", "Fruity silky bird."),
            ("Loggerhead Shrike", "Lanius ludovicianus", "Butcher bird."),
            ("Northern Shrike", "Lanius borealis", "Northern predatory shrike."),
            ("Red-eyed Vireo", "Vireo olivaceus", "Persistent singer vireo."),
            ("Yellow-throated Vireo", "Vireo flavifrons", "Yellow-throated vireo."),
            ("Warbling Vireo", "Vireo gilvus", "Melodious tree-top vireo."),
            ("Northern Cardinal", "Cardinalis cardinalis", "Crested red bird."),
            ("Rose-breasted Grosbeak", "Pheucticus ludovicianus", "Rose-breasted songbird."),
            ("Black-headed Grosbeak", "Pheucticus melanocephalus", "Western counterpart."),
            ("Blue Jay", "Cyanocitta cristata", "Blue crested jay."),
            ("Steller's Jay", "Cyanocitta stelleri", "Western blue crested jay."),
            ("California Scrub-Jay", "Aphelocoma californica", "Western scrub jay."),
            ("American Crow", "Corvus brachyrhynchos", "Common black bird."),
            ("Common Raven", "Corvus corax", "Large black bird with wedge tail."),
            ("Tree Swallow", "Tachycineta bicolor", "Iridescent blue swallow."),
        ]

        // Combine all with families
        let familyMappings: [([(String, String, String)], String)] = [
            (waterfowl, "Waterfowl"),
            (hawks, "Hawks & Eagles"),
            (herons, "Herons & Bitterns"),
            (shorebirds, "Shorebirds"),
            (gulls, "Gulls & Terns"),
            (doves, "Doves & Pigeons"),
            (owls, "Owls"),
            (hummingbirds, "Hummingbirds"),
            (woodpeckers, "Woodpeckers"),
            (thrushes, "Thrushes"),
            (sparrows, "Sparrows & Finches"),
            (finches, "Sparrows & Finches"),
            (blackbirds, "Blackbirds & Orioles"),
            (warblers, "Warblers"),
            (otherBirds, "Other Birds"),
        ]

        for (birdsList, family) in familyMappings {
            for (name, scientific, desc) in birdsList {
                let id = name.lowercased()
                    .replacingOccurrences(of: " ", with: "-")
                    .replacingOccurrences(of: "'", with: "")

                birds.append(BirdSpecies(
                    id: id,
                    commonName: name,
                    scientificName: scientific,
                    family: family,
                    description: desc,
                    habitat: "Various habitats",
                    migrationPattern: "Varies by species",
                    region: "North America",
                    imageName: "bird_placeholder"
                ))
            }
        }

        return birds
    }
}
