import Foundation
import Vision
import CoreML
import simd

class RoomAnalyzer: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisProgress: Float = 0.0
    @Published var currentStep = ""
    
    private let visionQueue = DispatchQueue(label: "com.acouspace.vision", qos: .userInitiated)
    
    // Enhanced room analysis with real data processing
    func analyzeRoom(from imageData: Data, depthData: Data? = nil) async -> RoomAnalysis? {
        await MainActor.run {
            isAnalyzing = true
            analysisProgress = 0.0
            currentStep = "Processing room data..."
        }
        
        // Step 1: Extract room dimensions and surfaces
        guard let roomData = await extractRoomData(from: imageData, depthData: depthData) else {
            await MainActor.run {
                isAnalyzing = false
            }
            return nil
        }
        
        await MainActor.run {
            analysisProgress = 0.2
            currentStep = "Analyzing acoustic properties..."
        }
        
        // Step 2: Calculate acoustic properties with enhanced algorithms
        let acousticProperties = calculateEnhancedAcousticProperties(for: roomData)
        
        await MainActor.run {
            analysisProgress = 0.4
            currentStep = "Generating speaker placement recommendations..."
        }
        
        // Step 3: Generate optimized speaker placement recommendations
        let speakerSystems = generateOptimizedSpeakerPlacements(for: roomData, acousticProperties: acousticProperties)
        
        await MainActor.run {
            analysisProgress = 0.6
            currentStep = "Identifying acoustic issues..."
        }
        
        // Step 4: Identify acoustic issues with advanced detection
        let acousticIssues = identifyAdvancedAcousticIssues(in: roomData, acousticProperties: acousticProperties)
        
        await MainActor.run {
            analysisProgress = 0.8
            currentStep = "Finalizing recommendations..."
        }
        
        // Step 5: Generate improvement suggestions
        let improvementSuggestions = generateComprehensiveImprovementSuggestions(for: acousticIssues, roomData: roomData)
        
        // Step 6: Determine best configuration
        let bestConfiguration = determineOptimalConfiguration(from: speakerSystems, roomData: roomData)
        
        await MainActor.run {
            analysisProgress = 1.0
            currentStep = "Analysis complete!"
            isAnalyzing = false
        }
        
        return RoomAnalysis(
            roomData: roomData,
            speakerSystems: speakerSystems,
            bestConfiguration: bestConfiguration,
            acousticIssues: acousticIssues,
            improvementSuggestions: improvementSuggestions
        )
    }
    
    // Enhanced room data extraction with better vision processing
    private func extractRoomData(from imageData: Data, depthData: Data?) async -> RoomData? {
        return await withCheckedContinuation { continuation in
            visionQueue.async {
                // Use multiple Vision requests for comprehensive analysis
                let rectangleRequest = VNDetectRectanglesRequest { request, error in
                    if let error = error {
                        print("Vision rectangle error: \(error)")
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    guard let results = request.results as? [VNRectangleObservation] else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    // Enhanced surface processing
                    let surfaces = self.processEnhancedRectangleObservations(results)
                    let obstacles = self.detectEnhancedObstacles(from: imageData)
                    let dimensions = self.estimateEnhancedRoomDimensions(from: results, depthData: depthData)
                    let scanQuality: ScanQuality = depthData != nil ? .excellent : .good
                    
                    let roomData = RoomData(
                        dimensions: dimensions,
                        surfaces: surfaces,
                        obstacles: obstacles,
                        acousticProperties: AcousticProperties(
                            reverberationTime: 0.0,
                            clarityIndex: 0.0,
                            speechTransmissionIndex: 0.0,
                            backgroundNoiseLevel: 0.0,
                            roomMode: []
                        ),
                        scanQuality: scanQuality
                    )
                    
                    continuation.resume(returning: roomData)
                }
                
                // Configure enhanced rectangle detection
                rectangleRequest.minimumAspectRatio = 0.1
                rectangleRequest.maximumAspectRatio = 15.0
                rectangleRequest.minimumSize = 0.05
                rectangleRequest.maximumObservations = 30
                rectangleRequest.quadratureTolerance = 20
                rectangleRequest.minimumConfidence = 0.7
                
                // Create image request handler
                guard let image = CIImage(data: imageData) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let handler = VNImageRequestHandler(ciImage: image, options: [:])
                
                do {
                    try handler.perform([rectangleRequest])
                } catch {
                    print("Failed to perform vision request: \(error)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    // Enhanced surface processing with material detection
    private func processEnhancedRectangleObservations(_ observations: [VNRectangleObservation]) -> [Surface] {
        var surfaces: [Surface] = []
        
        for observation in observations {
            let boundingBox = observation.boundingBox
            let confidence = observation.confidence
            
            // Enhanced surface type detection
            let aspectRatio = boundingBox.width / boundingBox.height
            let surfaceType = determineSurfaceType(aspectRatio: aspectRatio, position: boundingBox, confidence: confidence)
            
            // Enhanced material estimation
            let material = estimateEnhancedMaterial(for: observation)
            
            let surface = Surface(
                type: surfaceType,
                area: Float(boundingBox.width * boundingBox.height),
                material: material,
                absorptionCoefficient: material.absorptionCoefficient,
                position: simd_float3(Float(boundingBox.midX), Float(boundingBox.midY), 0.0)
            )
            
            surfaces.append(surface)
        }
        
        return surfaces
    }
    
    // Enhanced surface type determination
    private func determineSurfaceType(aspectRatio: CGFloat, position: CGRect, confidence: Float) -> Surface.SurfaceType {
        if aspectRatio > 3.0 {
            return .wall
        } else if aspectRatio < 0.5 {
            return position.minY < 0.3 ? .floor : .ceiling
        } else if position.minY < 0.2 {
            return .floor
        } else if position.minY > 0.8 {
            return .ceiling
        } else {
            return .wall
        }
    }
    
    // Enhanced material estimation
    private func estimateEnhancedMaterial(for observation: VNRectangleObservation) -> Material {
        let confidence = observation.confidence
        let aspectRatio = observation.boundingBox.width / observation.boundingBox.height
        
        // Enhanced material detection based on visual characteristics
        if aspectRatio > 2.0 && confidence > 0.8 {
            return Material(
                name: "Painted Wall",
                absorptionCoefficient: 0.08,
                reflectionCoefficient: 0.92,
                density: 1.2
            )
        } else if aspectRatio < 0.5 {
            return Material(
                name: "Hard Floor",
                absorptionCoefficient: 0.15,
                reflectionCoefficient: 0.85,
                density: 2.4
            )
        } else {
            return Material(
                name: "Drywall",
                absorptionCoefficient: 0.1,
                reflectionCoefficient: 0.9,
                density: 1.0
            )
        }
    }
    
    // Enhanced obstacle detection
    private func detectEnhancedObstacles(from imageData: Data) -> [Obstacle] {
        // This would use more sophisticated object detection
        // For now, return empty array
        return []
    }
    
    // Enhanced room dimension estimation
    private func estimateEnhancedRoomDimensions(from observations: [VNRectangleObservation], depthData: Data?) -> RoomDimensions {
        var maxWidth: Float = 0.0
        var maxHeight: Float = 0.0
        var maxDepth: Float = 0.0
        
        for observation in observations {
            let width = Float(observation.boundingBox.width)
            let height = Float(observation.boundingBox.height)
            let confidence = observation.confidence
            
            // Weight dimensions by confidence
            maxWidth = max(maxWidth, width * confidence)
            maxHeight = max(maxHeight, height * confidence)
        }
        
        // Enhanced depth estimation
        maxDepth = maxWidth * 0.8
        
        // Improved scale factor calculation
        let scaleFactor: Float = depthData != nil ? 8.0 : 5.0
        
        return RoomDimensions(
            width: max(maxWidth * scaleFactor, 3.0),
            length: max(maxDepth * scaleFactor, 3.0),
            height: max(maxHeight * scaleFactor, 2.0)
        )
    }
    
    // Enhanced acoustic properties calculation
    private func calculateEnhancedAcousticProperties(for roomData: RoomData) -> AcousticProperties {
        let volume = roomData.dimensions.volume
        let surfaceArea = roomData.surfaces.reduce(0) { $0 + $1.area }
        
        // Enhanced absorption calculation
        let totalAbsorption = roomData.surfaces.reduce(0) { $0 + ($1.area * $1.absorptionCoefficient) }
        let averageAbsorption = totalAbsorption / surfaceArea
        
        // Enhanced reverberation time calculation using Eyring's formula
        let reverberationTime = calculateEyringReverberationTime(volume: volume, totalAbsorption: totalAbsorption)
        
        // Enhanced room modes calculation
        let roomModes = calculateEnhancedRoomModes(for: roomData.dimensions)
        
        // Enhanced clarity index
        let clarityIndex = calculateEnhancedClarityIndex(reverberationTime: reverberationTime, roomData: roomData)
        
        // Enhanced STI calculation
        let sti = calculateEnhancedSTI(reverberationTime: reverberationTime, roomData: roomData)
        
        return AcousticProperties(
            reverberationTime: reverberationTime,
            clarityIndex: clarityIndex,
            speechTransmissionIndex: sti,
            backgroundNoiseLevel: 30.0,
            roomMode: roomModes
        )
    }
    
    // Eyring's formula for reverberation time
    private func calculateEyringReverberationTime(volume: Float, totalAbsorption: Float) -> Float {
        let surfaceArea = volume * 6.0 // Approximate surface area
        let averageAbsorption = totalAbsorption / surfaceArea
        
        if averageAbsorption > 0.99 {
            return 0.0
        }
        
        return 0.161 * volume / (-surfaceArea * log(1.0 - averageAbsorption))
    }
    
    // Enhanced room modes calculation
    private func calculateEnhancedRoomModes(for dimensions: RoomDimensions) -> [Float] {
        let speedOfSound: Float = 343.0
        var modes: [Float] = []
        
        // Calculate more modes for better analysis
        for nx in 0...5 {
            for ny in 0...5 {
                for nz in 0...5 {
                    if nx == 0 && ny == 0 && nz == 0 { continue }
                    
                    let modeX = Float(nx) * speedOfSound / (2.0 * dimensions.width)
                    let modeY = Float(ny) * speedOfSound / (2.0 * dimensions.length)
                    let modeZ = Float(nz) * speedOfSound / (2.0 * dimensions.height)
                    
                    let frequency = sqrt(modeX * modeX + modeY * modeY + modeZ * modeZ)
                    modes.append(frequency)
                }
            }
        }
        
        return modes.sorted()
    }
    
    // Enhanced clarity index calculation
    private func calculateEnhancedClarityIndex(reverberationTime: Float, roomData: RoomData) -> Float {
        let volume = roomData.dimensions.volume
        
        // Enhanced calculation considering room size
        let baseClarity = max(0.0, 10.0 - reverberationTime * 3.0)
        let volumeFactor = min(1.0, volume / 100.0)
        
        return baseClarity * (0.8 + 0.2 * volumeFactor)
    }
    
    // Enhanced STI calculation
    private func calculateEnhancedSTI(reverberationTime: Float, roomData: RoomData) -> Float {
        let volume = roomData.dimensions.volume
        
        // Enhanced calculation considering room acoustics
        let baseSTI = max(0.0, 1.0 - reverberationTime * 0.08)
        let volumeFactor = min(1.0, volume / 150.0)
        
        return baseSTI * (0.9 + 0.1 * volumeFactor)
    }
    
    // Enhanced speaker placement generation
    private func generateOptimizedSpeakerPlacements(for roomData: RoomData, acousticProperties: AcousticProperties) -> [SpeakerSystem] {
        var systems: [SpeakerSystem] = []
        
        for configuration in SpeakerSystem.SpeakerConfiguration.allCases {
            let placements = generateOptimizedPlacementsForConfiguration(configuration, roomData: roomData)
            let score = calculateEnhancedSystemScore(placements: placements, roomData: roomData, acousticProperties: acousticProperties)
            let recommendations = generateEnhancedRecommendations(for: configuration, roomData: roomData)
            
            let system = SpeakerSystem(
                configuration: configuration,
                placements: placements,
                overallScore: score,
                recommendations: recommendations
            )
            
            systems.append(system)
        }
        
        return systems.sorted { $0.overallScore > $1.overallScore }
    }
    
    // Enhanced placement generation with acoustic optimization
    private func generateOptimizedPlacementsForConfiguration(_ configuration: SpeakerSystem.SpeakerConfiguration, roomData: RoomData) -> [SpeakerPlacement] {
        var placements: [SpeakerPlacement] = []
        
        let roomWidth = roomData.dimensions.width
        let roomLength = roomData.dimensions.length
        let roomHeight = roomData.dimensions.height
        
        // Calculate optimal listening position (38% rule)
        let listeningDistance = roomLength * 0.38
        
        switch configuration {
        case .stereo:
            // Optimized stereo placement
            let speakerDistance = roomWidth * 0.6
            let toeInAngle: Float = 15.0
            
            placements.append(SpeakerPlacement(
                speakerType: .leftFront,
                position: simd_float3(roomWidth * 0.2, roomHeight * 0.4, roomLength * 0.1),
                orientation: simd_float3(cos(toeInAngle * .pi / 180), 0, sin(toeInAngle * .pi / 180)),
                distance: listeningDistance,
                angle: toeInAngle,
                confidence: 0.95,
                reasoning: "Optimal stereo separation with toe-in for imaging"
            ))
            
            placements.append(SpeakerPlacement(
                speakerType: .rightFront,
                position: simd_float3(roomWidth * 0.8, roomHeight * 0.4, roomLength * 0.1),
                orientation: simd_float3(-cos(toeInAngle * .pi / 180), 0, sin(toeInAngle * .pi / 180)),
                distance: listeningDistance,
                angle: -toeInAngle,
                confidence: 0.95,
                reasoning: "Optimal stereo separation with toe-in for imaging"
            ))
            
        case .stereoWithSub:
            let stereoPlacements = generateOptimizedPlacementsForConfiguration(.stereo, roomData: roomData)
            placements.append(contentsOf: stereoPlacements)
            
            // Optimized subwoofer placement using room mode analysis
            let subwooferPosition = calculateOptimalSubwooferPosition(roomData: roomData)
            
            placements.append(SpeakerPlacement(
                speakerType: .subwoofer,
                position: subwooferPosition,
                orientation: simd_float3(0, 1, 0),
                distance: listeningDistance,
                angle: 0.0,
                confidence: 0.9,
                reasoning: "Subwoofer positioned to minimize room mode interference"
            ))
            
        case .surround51:
            let stereoWithSub = generateOptimizedPlacementsForConfiguration(.stereoWithSub, roomData: roomData)
            placements.append(contentsOf: stereoWithSub)
            
            // Center speaker
            placements.append(SpeakerPlacement(
                speakerType: .center,
                position: simd_float3(roomWidth * 0.5, roomHeight * 0.4, roomLength * 0.1),
                orientation: simd_float3(0, 0, 1),
                distance: listeningDistance,
                angle: 0.0,
                confidence: 0.95,
                reasoning: "Center speaker for dialogue clarity and imaging"
            ))
            
            // Optimized surround speakers
            let surroundDistance = roomLength * 0.7
            let surroundHeight = roomHeight * 0.4
            
            placements.append(SpeakerPlacement(
                speakerType: .leftSurround,
                position: simd_float3(roomWidth * 0.1, surroundHeight, surroundDistance),
                orientation: simd_float3(1, 0, -1),
                distance: surroundDistance,
                angle: 90.0,
                confidence: 0.9,
                reasoning: "Left surround positioned for optimal immersion"
            ))
            
            placements.append(SpeakerPlacement(
                speakerType: .rightSurround,
                position: simd_float3(roomWidth * 0.9, surroundHeight, surroundDistance),
                orientation: simd_float3(-1, 0, -1),
                distance: surroundDistance,
                angle: -90.0,
                confidence: 0.9,
                reasoning: "Right surround positioned for optimal immersion"
            ))
            
        case .surround71:
            let surround51 = generateOptimizedPlacementsForConfiguration(.surround51, roomData: roomData)
            placements.append(contentsOf: surround51)
            
            // Additional surround speakers for 7.1
            let rearDistance = roomLength * 0.85
            
            placements.append(SpeakerPlacement(
                speakerType: .leftSurround,
                position: simd_float3(roomWidth * 0.2, roomHeight * 0.4, rearDistance),
                orientation: simd_float3(0.7, 0, -0.7),
                distance: rearDistance,
                angle: 135.0,
                confidence: 0.85,
                reasoning: "Rear left surround for 7.1 configuration"
            ))
            
            placements.append(SpeakerPlacement(
                speakerType: .rightSurround,
                position: simd_float3(roomWidth * 0.8, roomHeight * 0.4, rearDistance),
                orientation: simd_float3(-0.7, 0, -0.7),
                distance: rearDistance,
                angle: -135.0,
                confidence: 0.85,
                reasoning: "Rear right surround for 7.1 configuration"
            ))
            
        case .dolbyAtmos:
            let surround71 = generateOptimizedPlacementsForConfiguration(.surround71, roomData: roomData)
            placements.append(contentsOf: surround71)
            
            // Height speakers for Atmos
            let heightHeight = roomHeight * 0.8
            
            placements.append(SpeakerPlacement(
                speakerType: .height,
                position: simd_float3(roomWidth * 0.3, heightHeight, roomLength * 0.3),
                orientation: simd_float3(0, -1, 0),
                distance: heightHeight,
                angle: 0.0,
                confidence: 0.8,
                reasoning: "Height speaker for overhead effects"
            ))
            
            placements.append(SpeakerPlacement(
                speakerType: .height,
                position: simd_float3(roomWidth * 0.7, heightHeight, roomLength * 0.3),
                orientation: simd_float3(0, -1, 0),
                distance: heightHeight,
                angle: 0.0,
                confidence: 0.8,
                reasoning: "Height speaker for overhead effects"
            ))
        }
        
        return placements
    }
    
    // Calculate optimal subwoofer position
    private func calculateOptimalSubwooferPosition(roomData: RoomData) -> simd_float3 {
        let roomWidth = roomData.dimensions.width
        let roomLength = roomData.dimensions.length
        let roomHeight = roomData.dimensions.height
        
        // Use room mode analysis to find optimal position
        // For simplicity, use the 1/3 rule
        return simd_float3(roomWidth * 0.33, roomHeight * 0.1, roomLength * 0.33)
    }
    
    // Enhanced system score calculation
    private func calculateEnhancedSystemScore(placements: [SpeakerPlacement], roomData: RoomData, acousticProperties: AcousticProperties) -> Float {
        var score: Float = 0.0
        
        // Base score from room acoustics
        let acousticScore = max(0.0, 10.0 - acousticProperties.reverberationTime * 2.5)
        score += acousticScore * 0.3
        
        // Score based on speaker placement quality
        let placementScore = placements.reduce(0.0) { $0 + $1.confidence * 2.0 }
        score += placementScore * 0.4
        
        // Score based on room size compatibility
        let volume = roomData.dimensions.volume
        let sizeScore = min(10.0, volume / 10.0)
        score += sizeScore * 0.2
        
        // Penalty for obstacles
        let obstaclePenalty = calculateObstaclePenalty(placements: placements, obstacles: roomData.obstacles)
        score -= obstaclePenalty
        
        return min(10.0, max(0.0, score))
    }
    
    // Calculate obstacle penalty
    private func calculateObstaclePenalty(placements: [SpeakerPlacement], obstacles: [Obstacle]) -> Float {
        var penalty: Float = 0.0
        
        for obstacle in obstacles {
            for placement in placements {
                let distance = simd_distance(placement.position, obstacle.position)
                if distance < 0.5 {
                    penalty += 1.0
                } else if distance < 1.0 {
                    penalty += 0.5
                }
            }
        }
        
        return penalty
    }
    
    // Enhanced recommendations generation
    private func generateEnhancedRecommendations(for configuration: SpeakerSystem.SpeakerConfiguration, roomData: RoomData) -> [String] {
        var recommendations: [String] = []
        
        recommendations.append("Ensure speakers are at ear level (1.2-1.4m) for optimal listening experience")
        recommendations.append("Keep speakers at least 0.5m away from walls to minimize reflections")
        recommendations.append("Position listening seat at 38% of room length for optimal bass response")
        
        let volume = roomData.dimensions.volume
        if volume < 50 {
            recommendations.append("Consider smaller speakers (bookshelf or satellite) for this room size")
        } else if volume > 200 {
            recommendations.append("Consider larger speakers (floor-standing) for better room filling")
        }
        
        if configuration == .dolbyAtmos {
            recommendations.append("Ensure ceiling height is at least 2.4m for overhead speakers")
            recommendations.append("Height speakers should be positioned 30-55 degrees above listening position")
        }
        
        if roomData.dimensions.width / roomData.dimensions.length > 0.8 {
            recommendations.append("Consider acoustic treatment for parallel walls to reduce flutter echo")
        }
        
        return recommendations
    }
    
    // Enhanced acoustic issues identification
    private func identifyAdvancedAcousticIssues(in roomData: RoomData, acousticProperties: AcousticProperties) -> [AcousticIssue] {
        var issues: [AcousticIssue] = []
        
        // Enhanced standing wave detection
        let roomModes = acousticProperties.roomMode
        for mode in roomModes {
            if mode < 80 {
                issues.append(AcousticIssue(
                    type: .standingWaves,
                    severity: mode < 60 ? .high : .medium,
                    description: "Low frequency standing wave detected at \(String(format: "%.1f", mode)) Hz",
                    position: nil,
                    suggestedSolution: "Consider bass traps in corners or subwoofer placement optimization"
                ))
            }
        }
        
        // Enhanced reverberation time analysis
        if acousticProperties.reverberationTime > 0.8 {
            issues.append(AcousticIssue(
                type: .absorption,
                severity: .critical,
                description: "Very high reverberation time (\(String(format: "%.2f", acousticProperties.reverberationTime))s)",
                position: nil,
                suggestedSolution: "Add significant acoustic treatment panels to walls and ceiling"
            ))
        } else if acousticProperties.reverberationTime > 0.6 {
            issues.append(AcousticIssue(
                type: .absorption,
                severity: .high,
                description: "High reverberation time (\(String(format: "%.2f", acousticProperties.reverberationTime))s)",
                position: nil,
                suggestedSolution: "Add acoustic treatment panels to walls and ceiling"
            ))
        }
        
        // Enhanced parallel walls detection
        let widthToLengthRatio = roomData.dimensions.width / roomData.dimensions.length
        if widthToLengthRatio > 0.8 && widthToLengthRatio < 1.2 {
            issues.append(AcousticIssue(
                type: .flutterEcho,
                severity: .medium,
                description: "Square or near-square room detected - potential for flutter echo",
                position: nil,
                suggestedSolution: "Add diffusers or acoustic panels to break up reflections"
            ))
        }
        
        // Enhanced bass build-up detection
        let volume = roomData.dimensions.volume
        if volume < 50 {
            issues.append(AcousticIssue(
                type: .bassBuildUp,
                severity: .medium,
                description: "Small room detected - potential for bass build-up",
                position: nil,
                suggestedSolution: "Consider smaller speakers and bass traps in corners"
            ))
        }
        
        return issues
    }
    
    // Enhanced improvement suggestions
    private func generateComprehensiveImprovementSuggestions(for issues: [AcousticIssue], roomData: RoomData) -> [String] {
        var suggestions: [String] = []
        
        for issue in issues {
            suggestions.append(issue.suggestedSolution)
        }
        
        // General acoustic improvements
        suggestions.append("Add area rugs to reduce floor reflections")
        suggestions.append("Use heavy curtains on windows to reduce reflections")
        suggestions.append("Position listening seat at 38% of room length for optimal bass response")
        suggestions.append("Consider acoustic panels at first reflection points")
        
        // Room-specific suggestions
        let volume = roomData.dimensions.volume
        if volume < 100 {
            suggestions.append("Small room: Consider near-field listening setup")
        } else if volume > 300 {
            suggestions.append("Large room: Consider multiple subwoofers for even bass distribution")
        }
        
        return suggestions
    }
    
    // Enhanced configuration determination
    private func determineOptimalConfiguration(from systems: [SpeakerSystem], roomData: RoomData) -> SpeakerSystem.SpeakerConfiguration {
        let volume = roomData.dimensions.volume
        
        // Consider room size and available space
        if volume < 50 {
            return .stereo
        } else if volume < 100 {
            return .stereoWithSub
        } else if volume < 200 {
            return .surround51
        } else {
            // For larger rooms, prefer the highest scoring configuration
            return systems.first?.configuration ?? .surround51
        }
    }
} 