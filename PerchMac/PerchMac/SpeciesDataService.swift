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
            ("Short-billed Dowitcher", "Limnodromus griseus", "Probing shorebird."),
            ("Long-billed Dowitcher", "Limnodromus scolopaceus", "Long-billed dowitcher."),
        ]

        // MARK: - Gulls & Terns
        let gulls: [(String, String, String)] = [
            ("Herring Gull", "Larus argentatus", "Common large gull."),
            ("Ring-billed Gull", "Larus delawarensis", "Most common urban gull."),
            ("Laughing Gull", "Leucophaeus atricilla", "Black-headed gull."),
            ("Bonaparte's Gull", "Chroicocephalus philadelphia", "Small black-eared gull."),
            ("Mew Gull", "Larus canus", "Medium-sized greenish-billed gull."),
            ("California Gull", "Larus californicus", "Western interior gull."),
            ("Great Black-backed Gull", "Larus marinus", "Largest North American gull."),
            ("Glaucous Gull", "Larus hyperboreus", "Pale Arctic gull."),
            ("Iceland Gull", "Larus glaucescens", "Small pale coastal gull."),
            ("Sabine's Gull", "Xema sabini", "Forked-tail gull."),
            ("Black-legged Kittiwake", "Rissa tridactyla", "Cliff-nesting gull."),
            ("Caspian Tern", "Hydroprogne caspia", "Largest tern."),
            ("Forster's Tern", "Sterna forsteri", "Inland marsh tern."),
            ("Common Tern", "Sterna hirundo", "Familiar beach tern."),
            ("Arctic Tern", "Sterna paradisaea", "Longest migration."),
            ("Least Tern", "Sternula antillarum", "Smallest North American tern."),
            ("Black Tern", "Chlidonias niger", "Freshwater marsh tern."),
            ("Royal Tern", "Thalasseus maximus", "Large southern tern."),
            ("Black Skimmer", "Rynchops niger", "Bill-skimming seabird."),
        ]

        // MARK: - Doves
        let doves: [(String, String, String)] = [
            ("Rock Pigeon", "Columba livia", "Common city bird."),
            ("Mourning Dove", "Zenaida macroura", "Graceful dove."),
            ("Eurasian Collared-Dove", "Streptopelia decaocto", "Recently introduced."),
            ("White-winged Dove", "Zenaida asiatica", "Southwestern dove."),
            ("Inca Dove", "Columbina inca", "Small scaly dove."),
            ("Common Ground-Dove", "Columbina passerina", "Tiny southern dove."),
            ("Band-tailed Pigeon", "Patagioenas fasciata", "Western forest pigeon."),
            ("White-tipped Dove", "Leptotila verreauxi", "South Texas dove."),
        ]

        // MARK: - Owls
        let owls: [(String, String, String)] = [
            ("Great Horned Owl", "Bubo virginianus", "Large tufted owl."),
            ("Snowy Owl", "Bubo scandiacus", "White Arctic owl."),
            ("Barred Owl", "Strix varia", "Hooting woodland owl."),
            ("Great Gray Owl", "Strix nebulosa", "Largest North American owl."),
            ("Long-eared Owl", "Asio otus", "Slender tufted owl."),
            ("Short-eared Owl", "Asio flammeus", "Open grassland owl."),
            ("Northern Saw-whet Owl", "Aegolius acadicus", "Smallest eastern owl."),
            ("Boreal Owl", "Aegolius funereus", "Northern forest owl."),
            ("Eastern Screech-Owl", "Megascops asio", "Small trilling owl."),
            ("Western Screech-Owl", "Megascops kennicottii", "Western small owl."),
            ("Flammulated Owl", "Psiloscops flammeolus", "Small reddish owl."),
            ("Burrowing Owl", "Athene cunicularia", "Ground-nesting owl."),
            ("Northern Pygmy-Owl", "Glaucidium gnoma", "Tiny western forest owl."),
            ("Elf Owl", "Micrathene whitneyi", "World's smallest owl."),
            ("Spotted Owl", "Strix occidentalis", "Old-growth forest owl."),
            ("Barn Owl", "Tyto alba", "Heart-shaped face owl."),
        ]

        // MARK: - Hummingbirds
        let hummingbirds: [(String, String, String)] = [
            ("Ruby-throated Hummingbird", "Archilochus colubris", "Eastern US hummingbird."),
            ("Black-chinned Hummingbird", "Archilochus alexandri", "Western US hummingbird."),
            ("Anna's Hummingbird", "Calypte anna", "Year-round West Coast resident."),
            ("Costa's Hummingbird", "Calypte costae", "Desert Southwest hummingbird."),
            ("Calliope Hummingbird", "Selasphorus calliope", "Smallest North American bird."),
            ("Broad-tailed Hummingbird", "Selasphorus platycercus", "Western mountain hummer."),
            ("Rufous Hummingbird", "Selasphorus rufus", "Feisty rufous hummer."),
            ("Allen's Hummingbird", "Selasphorus sasin", "Coastal California hummer."),
            ("Broad-billed Hummingbird", "Cynanthus latirostris", "Brilliant blue hummer."),
            ("Violet-crowned Hummingbird", "Leucolia violiceps", "Purple-crowned hummer."),
            ("Blue-throated Hummingbird", "Lampornis clemenciae", "Large Southwest hummer."),
            ("Magnificent Hummingbird", "Eugenes fulgens", "Large mountain hummer."),
        ]

        // MARK: - Woodpeckers
        let woodpeckers: [(String, String, String)] = [
            ("Pileated Woodpecker", "Dryocopus pileatus", "Large red-crested woodpecker."),
            ("Northern Flicker", "Colaptes auratus", "Ground-feeding woodpecker."),
            ("Red-bellied Woodpecker", "Melanerpes carolinus", "Barred back woodpecker."),
            ("Red-headed Woodpecker", "Melanerpes erythrocephalus", "All-red headed woodpecker."),
            ("Acorn Woodpecker", "Melanerpes formicivorus", "Acorn-storing woodpecker."),
            ("Lewis's Woodpecker", "Melanerpes lewis", "Dark western woodpecker."),
            ("Gila Woodpecker", "Melanerpes uropygialis", "Desert Southwest woodpecker."),
            ("Golden-fronted Woodpecker", "Melanerpes aurifrons", "Texas/Oklahoma woodpecker."),
            ("Downy Woodpecker", "Dryobates pubescens", "Smallest North American woodpecker."),
            ("Hairy Woodpecker", "Dryobates villosus", "Larger Downy look-alike."),
            ("American Three-toed Woodpecker", "Picoides dorsalis", "Three-toed woodpecker."),
            ("Black-backed Woodpecker", "Picoides arcticus", "Burned forest specialist."),
            ("White-headed Woodpecker", "Dryobates albolvuttatus", "Western pine woodpecker."),
            ("Ivory-billed Woodpecker", "Campephilus principalis", "Possibly extinct."),
            ("Red-bellied Woodpecker", "Melanerpes carolinus", "Common eastern woodpecker."),
        ]

        // MARK: - Thrushes & Mockingbirds
        let thrushes: [(String, String, String)] = [
            ("American Robin", "Turdus migratorius", "Familiar lawn bird."),
            ("Wood Thrush", "Hylocichla mustelina", "Beautiful songster."),
            ("Hermit Thrush", "Catharus guttatus", "Rufous-tailed thrush."),
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
            ("California Thrasher", "Toxostoma redivivum", "Long-billed thrasher."),
            ("Northern Mockingbird", "Mimus polyglottos", "Sound mimic."),
            ("Sage Thrasher", "Oreoscoptes montanus", "Sagebrush thrasher."),
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
            ("Brewer's Sparrow", "Spizella breweri", "Sagebrush sparrow."),
            ("Field Sparrow", "Spizella pusilla", "Pink-billed field sparrow."),
            ("Vesper Sparrow", "Pooecetes gramineus", "White-tailed sparrow."),
            ("Savannah Sparrow", "Passerculus sandwichensis", "Yellow-eyebrowed sparrow."),
            ("Grasshopper Sparrow", "Ammodramus savannarum", "Grasshopper-eating sparrow."),
            ("Henslow's Sparrow", "Centronyx henslowii", "Rare tall grass sparrow."),
            ("LeConte's Sparrow", "Ammospiza leconteii", "Wet meadow sparrow."),
            ("Nelson's Sparrow", "Ammospiza nelsoni", "Salt marsh sparrow."),
            ("Saltmarsh Sparrow", "Ammospiza caudacuta", "Tidal marsh sparrow."),
            ("Baird's Sparrow", "Centronyx bairdii", "Northern prairie sparrow."),
            ("Harris's Sparrow", "Zonotrichia querula", "Black-bibbed sparrow."),
            ("Dark-eyed Junco", "Junco hyemalis", "Winter slate sparrow."),
            ("Yellow-eyed Junco", "Junco phaeonotus", "Southern mountain junco."),
        ]

        // MARK: - Finches
        let finches: [(String, String, String)] = [
            ("House Finch", "Haemorhous mexicanus", "Red-crowned western finch."),
            ("Purple Finch", "Haemorhous purpureus", "Raspberry-capped finch."),
            ("Cassin's Finch", "Haemorhous cassinii", "Western mountain finch."),
            ("Red Crossbill", "Loxia curvirostra", "Crossed-bill finch."),
            ("White-winged Crossbill", "Loxia leucoptera", "White-barred crossbill."),
            ("Common Redpoll", "Acanthis flammea", "Far northern finch."),
            ("Hoary Redpoll", "Acanthis hornemanni", "Pale Arctic redpoll."),
            ("Pine Siskin", "Spinus pinus", "Yellow-winged siskin."),
            ("American Goldfinch", "Spinus tristis", "Black-capped yellow finch."),
            ("Lesser Goldfinch", "Spinus psaltria", "Small western goldfinch."),
            ("Lawrence's Goldfinch", "Spinus lawrencei", "Black-faced goldfinch."),
            ("Evening Grosbeak", "Hesperiphona vespertina", "Huge-billed finch."),
            ("Pine Grosbeak", "Pinicola enucleator", "Northern forest grosbeak."),
            ("Gray-crowned Rosy-Finch", "Leucosticte tephrocotis", "Western mountain finch."),
            ("Black Rosy-Finch", "Leucosticte atrata", "High mountain finch."),
            ("Brown-capped Rosy-Finch", "Leucosticte australis", "Colorado peak finch."),
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
            ("Boat-tailed Grackle", "Quiscalus major", "Coastal marsh grackle."),
            ("Orchard Oriole", "Icterus spurius", "Chestnut oriole."),
            ("Bullock's Oriole", "Icterus bullockii", "Western orange oriole."),
            ("Baltimore Oriole", "Icterus galbula", "Eastern orange oriole."),
            ("Scott's Oriole", "Icterus parisorum", "Southwestern desert oriole."),
            ("Hooded Oriole", "Icterus cucullatus", "Black-hooded oriole."),
            ("Altamira Oriole", "Icterus gularis", "South Texas tropical oriole."),
            ("Audubon's Oriole", "Icterus graduacauda", "Yellow-hooded oriole."),
            ("Bobolink", "Dolichonyx oryzivorus", "White-rumped summer blackbird."),
            ("Eastern Meadowlark", "Sturnella magna", "Yellow-breasted field bird."),
            ("Western Meadowlark", "Sturnella neglecta", "Western field bird."),
            ("Yellow-breasted Chat", "Icteria virens", "Large yellow-breasted songbird."),
        ]

        // MARK: - Warblers
        let warblers: [(String, String, String)] = [
            ("Yellow Warbler", "Setophaga petechia", "Bright yellow wetland warbler."),
            ("Magnolia Warbler", "Setophaga magnolia", "Black-necklaced warbler."),
            ("Cape May Warbler", "Setophaga tigrina", "Chestnut-cheeked warbler."),
            ("Yellow-rumped Warbler", "Setophaga coronata", "Most common warbler."),
            ("Black-throated Blue Warbler", "Setophaga caerulescens", "Blue upperparts warbler."),
            ("Palm Warbler", "Setophaga palmarum", "Tail-wagging warbler."),
            ("Pine Warbler", "Setophaga pinus", "Pine forest warbler."),
            ("Yellow-throated Warbler", "Setophaga dominica", "Yellow-throated treetop warbler."),
            ("Black-throated Green Warbler", "Setophaga virens", "Green-backed warbler."),
            ("Blackburnian Warbler", "Setophaga fusca", "Orange-throated warbler."),
            ("Bay-breasted Warbler", "Setophaga castanea", "Rusty-sided warbler."),
            ("Blackpoll Warbler", "Setophaga striata", "Black-capped warbler."),
            ("Black-and-white Warbler", "Mniotilta varia", "Striped creeping warbler."),
            ("American Redstart", "Setophaga ruticilla", "Orange-patched warbler."),
            ("Prothonotary Warbler", "Protonotaria citrea", "Brilliant golden warbler."),
            ("Worm-eating Warbler", "Helmitheros vermivorum", "Striped-head warbler."),
            ("Swainson's Warbler", "Limnothlypis swainsonii", "Dense undergrowth warbler."),
            ("Ovenbird", "Seiurus aurocapilla", "Ground-nesting warbler."),
            ("Northern Waterthrush", "Parkesia noveboracensis", "Bobbing wetland warbler."),
            ("Louisiana Waterthrush", "Parkesia motacilla", "Pink-legged waterthrush."),
            ("Connecticut Warbler", "Oporornis agilis", "Bold eyeringed warbler."),
            ("MacGillivray's Warbler", "Geothlypis tolmiei", "Broken-eyeringed warbler."),
            ("Common Yellowthroat", "Geothlypis trichas", "Black-masked warbler."),
            ("Hooded Warbler", "Setophaga citrina", "Yellow-hooded warbler."),
            ("Wilson's Warbler", "Cardellina pusilla", "Black-capped warbler."),
            ("Canada Warbler", "Cardellina canadensis", "Necklaced warbler."),
            ("Cerulean Warbler", "Setophaga cerulea", "Sky-blue treetop warbler."),
            ("Kirtland's Warbler", "Setophaga kirtlandii", "Jack Pine specialist."),
            ("Prairie Warbler", "Setophaga discolor", "Open country warbler."),
            ("Kentucky Warbler", "Geothlypis formosa", "Deep woods warbler."),
            ("Mourning Warbler", "Geothlypis philadelphia", "Gray-hooded warbler."),
            ("Wilsonia citrina", "Hooded Warbler", "Forest understory warbler."),
            ("Canada Warbler", "Cardellina canadensis", "Northern forests warbler."),
        ]

        // MARK: - Kingfishers & Grebes
        let otherBirds: [(String, String, String)] = [
            ("Belted Kingfisher", "Megaceryle alcyon", "Diving fish-eating bird."),
            ("Ringed Kingfisher", "Megaceryle torquata", "Large southern Texas kingfisher."),
            ("Green Kingfisher", "Chloroceryle americana", "Small stream kingfisher."),
            ("Pied-billed Grebe", "Podilymbus podiceps", "Chicken-billed grebe."),
            ("Horned Grebe", "Podiceps auritus", "Golden head-plumed grebe."),
            ("Red-necked Grebe", "Podiceps grisegena", "Large red-necked grebe."),
            ("Eared Grebe", "Podiceps nigricollis", "Black ear-tufted grebe."),
            ("Western Grebe", "Aechmophorus occidentalis", "Large long-necked grebe."),
            ("Clark's Grebe", "Aechmophorus clarkii", "Western grebe variant."),
            ("American Coot", "Fulica americana", "Rail-like wetland bird."),
            ("Purple Gallinule", "Porphyrio martinica", "Colorful marsh bird."),
            ("Common Gallinule", "Gallinula galeata", "Red-shielded marsh bird."),
            ("Sora", "Porzana carolina", "Common marsh rail."),
            ("Virginia Rail", "Rallus limicola", "Freshwater marsh rail."),
            ("King Rail", "Rallus elegans", "Large freshwater rail."),
            ("Clapper Rail", "Rallus crepitans", "Salt marsh rail."),
            ("American Woodcock", "Scolopax minor", "Dusk field bird."),
            ("Common Nighthawk", "Chordeiles minor", "Dusk insect hunter."),
            ("Common Poorwill", "Phalaenoptilus nuttallii", "Night-time singer."),
            ("Eastern Whip-poor-will", "Antrostomus vociferus", "Night song bird."),
            ("Chuck-will's-widow", "Antrostomus carolinensis", "Southern night singer."),
            ("Chimney Swift", "Chaetura pelagica", "Tube-tailed aerial bird."),
            ("Vaux's Swift", "Chaetura vauxi", "Western chimney swift."),
            ("White-throated Swift", "Aeronautes saxatalis", "High altitude swift."),
            ("Ruby-throated Hummingbird", "Archilochus colubris", "Only eastern hummer."),
            ("Black Swift", "Cypseloides niger", "Largest North American swift."),
            ("Northern Rough-winged Swallow", "Stelgidopteryx serripennis", "Brownish swallow."),
            ("Purple Martin", "Progne subis", "Largest swallow."),
            ("Tree Swallow", "Tachycineta bicolor", "Iridescent blue swallow."),
            ("Barn Swallow", "Hirundo rustica", "Forked-tail swallow."),
            ("Cliff Swallow", "Petrochelidon pyrrhonota", "Gourd-nest swallow."),
            ("Bank Swallow", "Riparia riparia", "Burrowing swallow."),
            ("Cave Swallow", "Petrochelidon fulva", "Cave-nesting swallow."),
            ("House Wren", "Troglodytes aedon", "Small singing bird."),
            ("Winter Wren", "Troglodytes hiemalis", "Tiny rounded wren."),
            ("Sedge Wren", "Cistothorus stellaris", "Small prairie wetland wren."),
            ("Marsh Wren", "Cistothorus palustris", "Reed marsh wren."),
            ("Carolina Wren", "Thryothorus ludovicianus", "Large southern wren."),
            ("Bewick's Wren", "Thryomanes bewickii", "Western white-browed wren."),
            ("Cactus Wren", "Campylorhynchus brunneicapillus", "Southwestern desert wren."),
            ("Rock Wren", "Salpinctes obsoletus", "Western rock wren."),
            (" Canyon Wren", "Catherpes mexicanus", "Canyon dwelling wren."),
            ("American Dipper", "Cinclus mexicanus", "Stream-walking bird."),
            ("House Wren", "Troglodytes aedon", "Common garden wren."),
            ("Eurasian Wren", "Troglodytes troglodytes", "Widespread small wren."),
            ("White-breasted Nuthatch", "Sitta carolinensis", "Upside-down tree bird."),
            ("Red-breasted Nuthatch", "Sitta canadensis", "Small nuthatch with eyeline."),
            ("Pygmy Nuthatch", "Sitta pygmaea", "Tiny western pine nuthatch."),
            ("Brown-headed Nuthatch", "Sitta pusilla", "Southeastern pine nuthatch."),
            ("Brown Creeper", "Certhia americana", "Tree-spiraling bird."),
            ("Blue-gray Gnatcatcher", "Polioptila caerulea", "Tiny blue-gray bird."),
            ("California Gnatcatcher", "Polioptila californica", "Coastal California bird."),
            ("Golden-crowned Kinglet", "Regulus satrapa", "Tiny crested kinglet."),
            ("Ruby-crowned Kinglet", "Corthylio calendula", "Tiny kinglet with red crown."),
            ("Boreal Chickadee", "Poecile hudsonicus", "Northern brown chickadee."),
            ("Carolina Chickadee", "Poecile carolinensis", "Southeastern chickadee."),
            ("Black-capped Chickadee", "Poecile atricapillus", "Familiar black-capped bird."),
            ("Mountain Chickadee", "Poecile gambeli", "Western mountain chickadee."),
            ("Chestnut-backed Chickadee", "Poecile rufescens", "Western chickadee with rufous."),
            ("Bohemian Waxwing", "Bombycilla garrulus", "Northern silky bird."),
            ("Cedar Waxwing", "Bombycilla cedrorum", "Fruity silky bird."),
            ("Phainopepla", "Phainopepla nitens", "Crested silky desert bird."),
            ("Loggerhead Shrike", "Lanius ludovicianus", "Butcher bird."),
            ("Northern Shrike", "Lanius borealis", "Northern predatory shrike."),
            ("White-eyed Vireo", "Vireo griseus", "Southern scrub vireo."),
            ("Bell's Vireo", "Vireo bellii", "Small western vireo."),
            ("Gray Vireo", "Vireo vicinior", "Western desert scrub vireo."),
            ("Yellow-throated Vireo", "Vireo flavifrons", "Yellow-throated vireo."),
            ("Blue-headed Vireo", "Vireo solitaries", "Bold EYERINGED vireo."),
            ("Warbling Vireo", "Vireo gilvus", "Melodious tree-top vireo."),
            ("Philadelphia Vireo", "Vireo philadelphicus", "Small yellowish vireo."),
            ("Red-eyed Vireo", "Vireo olivaceus", "Persistent singer vireo."),
            ("Yellow-green Vireo", "Vireo flavoviridis", "Tropical vireo."),
            ("Black-whiskered Vireo", "Vireo altiloquus", "Southern coastal vireo."),
            ("American Robin", "Turdus migratorius", "Familiar lawn bird."),
        ]

        // Combine all
        let allBirds: [[(String, String, String)]] = [
            waterfowl, hawks, herons, shorebirds, gulls, doves, owls,
            hummingbirds, woodpeckers, thrushes, sparrows, finches,
            blackbirds, warblers, otherBirds
        ]

        for category in allBirds {
            for (name, scientific, desc) in category {
                let id = name.lowercased()
                    .replacingOccurrences(of: " ", with: "-")
                    .replacingOccurrences(of: "'", with: "")
                    .replacingOccurrences(of: "", with: "")
                    .replacingOccurrences(of: "", with: "")

                birds.append(BirdSpecies(
                    id: id,
                    commonName: name,
                    scientificName: scientific,
                    family: "Birds",
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
