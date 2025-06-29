import SwiftUI

struct ContentView: View {
    @State private var showingRoomScanner = false
    @State private var showingSpeakerPlacement = false
    @State private var roomData: RoomData?
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.05),
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header section
                    headerSection
                    
                    Spacer()
                    
                    // Main content section
                    mainContentSection
                    
                    Spacer()
                    
                    // Info section
                    infoSection
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingRoomScanner) {
            RoomScannerView(roomData: $roomData)
        }
        .sheet(isPresented: $showingSpeakerPlacement) {
            if let roomData = roomData {
                SpeakerPlacementView(roomData: roomData)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // App icon with animation
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(isAnimating ? 5 : -5))
            }
            .padding(.top, 40)
            
            // App title and subtitle
            VStack(spacing: 8) {
                Text("AcouSpace")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("AI-Powered Speaker Placement")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Main Content Section
    private var mainContentSection: some View {
        VStack(spacing: 24) {
            // Action buttons
            VStack(spacing: 16) {
                // Scan Room Button
                ActionButton(
                    title: "Scan Room",
                    subtitle: "Use camera to analyze your space",
                    icon: "camera.fill",
                    gradient: LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    action: {
                        showingRoomScanner = true
                    }
                )
                
                // Speaker Placement Button
                ActionButton(
                    title: "Speaker Placement",
                    subtitle: "Get personalized recommendations",
                    icon: "speaker.wave.2.fill",
                    gradient: LinearGradient(
                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    action: {
                        showingSpeakerPlacement = true
                    }
                )
                .disabled(roomData == nil)
                .opacity(roomData == nil ? 0.6 : 1.0)
            }
            
            // Status indicator
            if let roomData = roomData {
                statusCard(roomData: roomData)
            }
        }
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(spacing: 20) {
            // How it works section
            VStack(spacing: 16) {
                Text("How it works")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    StepRow(
                        number: 1,
                        title: "Scan your room",
                        description: "Use your iPhone's camera and LiDAR",
                        icon: "camera.fill"
                    )
                    
                    StepRow(
                        number: 2,
                        title: "AI analyzes acoustics",
                        description: "Advanced algorithms process room data",
                        icon: "brain.head.profile"
                    )
                    
                    StepRow(
                        number: 3,
                        title: "Get optimal placement",
                        description: "Personalized speaker recommendations",
                        icon: "speaker.wave.3.fill"
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Status Card
    private func statusCard(roomData: RoomData) -> some View {
        HStack(spacing: 16) {
            // Status icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Room Scanned")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(String(format: "%.1f", roomData.dimensions.width))m × \(String(format: "%.1f", roomData.dimensions.length))m × \(String(format: "%.1f", roomData.dimensions.height))m")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("Quality: \(roomData.scanQuality.rawValue)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Supporting Views

struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(gradient)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StepRow: View {
    let number: Int
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Step number
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 