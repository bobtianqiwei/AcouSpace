import Foundation
import CoreGraphics
import simd

// Room dimensions and properties
struct RoomData: Codable {
    let dimensions: RoomDimensions
    let surfaces: [Surface]
    let obstacles: [Obstacle]
    let acousticProperties: AcousticProperties
    let scanQuality: ScanQuality
    
    init(dimensions: RoomDimensions, surfaces: [Surface], obstacles: [Obstacle], acousticProperties: AcousticProperties, scanQuality: ScanQuality) {
        self.dimensions = dimensions
        self.surfaces = surfaces
        self.obstacles = obstacles
        self.acousticProperties = acousticProperties
        self.scanQuality = scanQuality
    }
}

struct RoomDimensions: Codable {
    let width: Float
    let length: Float
    let height: Float
    
    var volume: Float {
        return width * length * height
    }
    
    var floorArea: Float {
        return width * length
    }
}

struct Surface: Codable, Identifiable {
    let id = UUID()
    let type: SurfaceType
    let area: Float
    let material: Material
    let absorptionCoefficient: Float
    let position: simd_float3
    
    enum SurfaceType: String, Codable, CaseIterable {
        case wall = "Wall"
        case floor = "Floor"
        case ceiling = "Ceiling"
        case window = "Window"
        case door = "Door"
    }
}

struct Material: Codable {
    let name: String
    let absorptionCoefficient: Float
    let reflectionCoefficient: Float
    let density: Float
}

struct Obstacle: Codable, Identifiable {
    let id = UUID()
    let type: ObstacleType
    let position: simd_float3
    let dimensions: simd_float3
    let material: Material
    
    enum ObstacleType: String, Codable, CaseIterable {
        case furniture = "Furniture"
        case column = "Column"
        case beam = "Beam"
        case other = "Other"
    }
}

struct AcousticProperties: Codable {
    let reverberationTime: Float
    let clarityIndex: Float
    let speechTransmissionIndex: Float
    let backgroundNoiseLevel: Float
    let roomMode: [Float]
}

enum ScanQuality: String, Codable, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    
    var description: String {
        switch self {
        case .excellent:
            return "High quality scan with LiDAR support"
        case .good:
            return "Good quality scan with depth sensing"
        case .fair:
            return "Basic scan with limited depth data"
        case .poor:
            return "Low quality scan, manual input recommended"
        }
    }
}

// Speaker placement recommendations
struct SpeakerPlacement: Codable, Identifiable {
    let id = UUID()
    let speakerType: SpeakerType
    let position: simd_float3
    let orientation: simd_float3
    let distance: Float
    let angle: Float
    let confidence: Float
    let reasoning: String
    
    enum SpeakerType: String, Codable, CaseIterable {
        case leftFront = "Left Front"
        case rightFront = "Right Front"
        case center = "Center"
        case leftSurround = "Left Surround"
        case rightSurround = "Right Surround"
        case subwoofer = "Subwoofer"
        case height = "Height"
    }
}

struct SpeakerSystem: Codable {
    let configuration: SpeakerConfiguration
    let placements: [SpeakerPlacement]
    let overallScore: Float
    let recommendations: [String]
    
    enum SpeakerConfiguration: String, Codable, CaseIterable {
        case stereo = "2.0 Stereo"
        case stereoWithSub = "2.1 Stereo with Subwoofer"
        case surround51 = "5.1 Surround"
        case surround71 = "7.1 Surround"
        case dolbyAtmos = "Dolby Atmos"
    }
}

// Analysis results
struct RoomAnalysis: Codable {
    let roomData: RoomData
    let speakerSystems: [SpeakerSystem]
    let bestConfiguration: SpeakerConfiguration
    let acousticIssues: [AcousticIssue]
    let improvementSuggestions: [String]
}

struct AcousticIssue: Codable, Identifiable {
    let id = UUID()
    let type: IssueType
    let severity: Severity
    let description: String
    let position: simd_float3?
    let suggestedSolution: String
    
    enum IssueType: String, Codable, CaseIterable {
        case standingWaves = "Standing Waves"
        case flutterEcho = "Flutter Echo"
        case bassBuildUp = "Bass Build-up"
        case reflection = "Early Reflection"
        case absorption = "Insufficient Absorption"
    }
    
    enum Severity: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
    }
}

// Utility extensions
extension simd_float3: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(Float.self, forKey: .x)
        let y = try container.decode(Float.self, forKey: .y)
        let z = try container.decode(Float.self, forKey: .z)
        self.init(x, y, z)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(z, forKey: .z)
    }
    
    private enum CodingKeys: String, CodingKey {
        case x, y, z
    }
} 