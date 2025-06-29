import SwiftUI
import ARKit
import RealityKit
import Vision

struct RoomScannerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var roomData: RoomData?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> ARViewController {
        let controller = ARViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {}
    
    class Coordinator: NSObject, ARViewControllerDelegate {
        var parent: RoomScannerView
        
        init(_ parent: RoomScannerView) {
            self.parent = parent
        }
        
        func didFinishScanning(roomData: RoomData) {
            parent.roomData = roomData
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// Delegate protocol for ARViewController
protocol ARViewControllerDelegate: AnyObject {
    func didFinishScanning(roomData: RoomData)
}

// Enhanced ARKit-based view controller for room scanning
class ARViewController: UIViewController, ARSessionDelegate {
    weak var delegate: ARViewControllerDelegate?
    var arView: ARView!
    
    // UI Elements
    private var scanningLabel: UILabel!
    private var progressView: UIProgressView!
    private var instructionLabel: UILabel!
    private var finishButton: UIButton!
    
    // Scanning state
    private var meshAnchors: [ARMeshAnchor] = []
    private var planeAnchors: [ARPlaneAnchor] = []
    private var scanningProgress: Float = 0.0
    private var isScanningComplete = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
        setupUI()
    }
    
    func setupARView() {
        arView = ARView(frame: view.bounds)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(arView)
        
        // Configure AR session with advanced features
        let config = ARWorldTrackingConfiguration()
        
        // Enable mesh reconstruction if supported
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
            print("LiDAR mesh reconstruction enabled")
        }
        
        // Enable depth data if supported
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics.insert(.sceneDepth)
            print("Scene depth enabled")
        }
        
        // Enable plane detection
        config.planeDetection = [.horizontal, .vertical]
        
        // Set session delegate
        arView.session.delegate = self
        
        // Start AR session
        arView.session.run(config)
    }
    
    func setupUI() {
        // Scanning progress label
        scanningLabel = UILabel()
        scanningLabel.text = "Scanning Room..."
        scanningLabel.textColor = .white
        scanningLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        scanningLabel.textAlignment = .center
        scanningLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        scanningLabel.layer.cornerRadius = 8
        scanningLabel.layer.masksToBounds = true
        scanningLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanningLabel)
        
        // Progress view
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        // Instruction label
        instructionLabel = UILabel()
        instructionLabel.text = "Move your device slowly around the room to capture all surfaces"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 14)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        instructionLabel.layer.cornerRadius = 8
        instructionLabel.layer.masksToBounds = true
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        // Finish button
        finishButton = UIButton(type: .system)
        finishButton.setTitle("Finish Scan", for: .normal)
        finishButton.setTitleColor(.white, for: .normal)
        finishButton.backgroundColor = .systemBlue
        finishButton.layer.cornerRadius = 12
        finishButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        finishButton.addTarget(self, action: #selector(finishScanTapped), for: .touchUpInside)
        finishButton.isEnabled = false
        finishButton.alpha = 0.5
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(finishButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scanningLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scanningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanningLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            scanningLabel.heightAnchor.constraint(equalToConstant: 40),
            
            progressView.topAnchor.constraint(equalTo: scanningLabel.bottomAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            instructionLabel.bottomAnchor.constraint(equalTo: finishButton.topAnchor, constant: -20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            instructionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            finishButton.widthAnchor.constraint(equalToConstant: 200),
            finishButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                meshAnchors.append(meshAnchor)
                updateScanningProgress()
            } else if let planeAnchor = anchor as? ARPlaneAnchor {
                planeAnchors.append(planeAnchor)
                updateScanningProgress()
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                if let index = meshAnchors.firstIndex(where: { $0.identifier == meshAnchor.identifier }) {
                    meshAnchors[index] = meshAnchor
                }
            } else if let planeAnchor = anchor as? ARPlaneAnchor {
                if let index = planeAnchors.firstIndex(where: { $0.identifier == planeAnchor.identifier }) {
                    planeAnchors[index] = planeAnchor
                }
            }
        }
        updateScanningProgress()
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            meshAnchors.removeAll { $0.identifier == anchor.identifier }
            planeAnchors.removeAll { $0.identifier == anchor.identifier }
        }
        updateScanningProgress()
    }
    
    // MARK: - Scanning Logic
    
    private func updateScanningProgress() {
        let meshCount = Float(meshAnchors.count)
        let planeCount = Float(planeAnchors.count)
        
        // Calculate progress based on mesh and plane coverage
        let totalAnchors = meshCount + planeCount
        let progress = min(1.0, totalAnchors / 10.0) // Consider scan complete with 10+ anchors
        
        DispatchQueue.main.async {
            self.scanningProgress = progress
            self.progressView.progress = progress
            
            if progress >= 0.8 && !self.isScanningComplete {
                self.isScanningComplete = true
                self.finishButton.isEnabled = true
                self.finishButton.alpha = 1.0
                self.instructionLabel.text = "Scan complete! Tap 'Finish Scan' to analyze your room."
            }
        }
    }
    
    @objc func finishScanTapped() {
        guard isScanningComplete else { return }
        
        // Process collected data
        let roomData = processScannedData()
        delegate?.didFinishScanning(roomData: roomData)
    }
    
    private func processScannedData() -> RoomData {
        // Extract room dimensions from mesh anchors
        let dimensions = extractRoomDimensions()
        
        // Extract surfaces from plane anchors
        let surfaces = extractSurfaces()
        
        // Extract obstacles from mesh anchors
        let obstacles = extractObstacles()
        
        // Determine scan quality
        let scanQuality: ScanQuality = meshAnchors.count > 5 ? .excellent : .good
        
        return RoomData(
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
    }
    
    private func extractRoomDimensions() -> RoomDimensions {
        var minX: Float = Float.greatestFiniteMagnitude
        var maxX: Float = -Float.greatestFiniteMagnitude
        var minY: Float = Float.greatestFiniteMagnitude
        var maxY: Float = -Float.greatestFiniteMagnitude
        var minZ: Float = Float.greatestFiniteMagnitude
        var maxZ: Float = -Float.greatestFiniteMagnitude
        
        // Process mesh anchors for room boundaries
        for meshAnchor in meshAnchors {
            let geometry = meshAnchor.geometry
            let vertices = geometry.vertices
            
            for i in 0..<vertices.count {
                let vertex = vertices[i]
                let worldPosition = meshAnchor.transform * simd_float4(vertex, 1.0)
                
                minX = min(minX, worldPosition.x)
                maxX = max(maxX, worldPosition.x)
                minY = min(minY, worldPosition.y)
                maxY = max(maxY, worldPosition.y)
                minZ = min(minZ, worldPosition.z)
                maxZ = max(maxZ, worldPosition.z)
            }
        }
        
        let width = max(maxX - minX, 3.0)
        let height = max(maxY - minY, 2.0)
        let length = max(maxZ - minZ, 3.0)
        
        return RoomDimensions(width: width, length: length, height: height)
    }
    
    private func extractSurfaces() -> [Surface] {
        var surfaces: [Surface] = []
        
        for planeAnchor in planeAnchors {
            let plane = planeAnchor.plane
            let area = plane.width * plane.height
            
            // Determine surface type based on plane alignment
            let surfaceType: Surface.SurfaceType
            let normal = planeAnchor.transform.columns.2
            let upVector = simd_float3(0, 1, 0)
            let dotProduct = simd_dot(normal.xyz, upVector)
            
            if abs(dotProduct) > 0.7 {
                surfaceType = dotProduct > 0 ? .floor : .ceiling
            } else {
                surfaceType = .wall
            }
            
            // Estimate material based on plane characteristics
            let material = estimateMaterialForPlane(planeAnchor)
            
            let surface = Surface(
                type: surfaceType,
                area: area,
                material: material,
                absorptionCoefficient: material.absorptionCoefficient,
                position: planeAnchor.transform.columns.3.xyz
            )
            
            surfaces.append(surface)
        }
        
        return surfaces
    }
    
    private func extractObstacles() -> [Obstacle] {
        var obstacles: [Obstacle] = []
        
        // Identify potential obstacles from mesh anchors
        for meshAnchor in meshAnchors {
            let geometry = meshAnchor.geometry
            let boundingBox = geometry.boundingBox
            
            // Filter out large surfaces (walls, floor, ceiling)
            let volume = boundingBox.max.x - boundingBox.min.x
            let volumeY = boundingBox.max.y - boundingBox.min.y
            let volumeZ = boundingBox.max.z - boundingBox.min.z
            let totalVolume = volume * volumeY * volumeZ
            
            if totalVolume < 2.0 && totalVolume > 0.1 { // Furniture-sized objects
                let obstacle = Obstacle(
                    type: .furniture,
                    position: meshAnchor.transform.columns.3.xyz,
                    dimensions: simd_float3(volume, volumeY, volumeZ),
                    material: Material(
                        name: "Unknown",
                        absorptionCoefficient: 0.3,
                        reflectionCoefficient: 0.7,
                        density: 1.0
                    )
                )
                obstacles.append(obstacle)
            }
        }
        
        return obstacles
    }
    
    private func estimateMaterialForPlane(_ planeAnchor: ARPlaneAnchor) -> Material {
        // In a real implementation, this would use computer vision
        // to analyze the plane's visual characteristics
        return Material(
            name: "Drywall",
            absorptionCoefficient: 0.1,
            reflectionCoefficient: 0.9,
            density: 1.0
        )
    }
}

// MARK: - Extensions

extension simd_float4 {
    var xyz: simd_float3 {
        return simd_float3(x, y, z)
    }
} 