import SwiftUI

struct SpeakerPlacementView: View {
    let roomData: RoomData
    @StateObject private var analyzer = RoomAnalyzer()
    @State private var analysis: RoomAnalysis?
    @State private var isLoading = true
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else if let analysis = analysis {
                    analysisView(analysis: analysis)
                } else {
                    errorView
                }
            }
            .navigationTitle("Speaker Placement")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            Task {
                analysis = await analyzer.analyzeRoom(from: Data())
                isLoading = false
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 24) {
            // Animated loading icon
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isLoading)
                
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                Text("Analyzing Your Room")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(analyzer.currentStep)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Progress bar
                ProgressView(value: analyzer.analysisProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(width: 200)
                    .padding(.top, 16)
            }
        }
        .padding()
    }
    
    // MARK: - Analysis View
    private func analysisView(analysis: RoomAnalysis) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Best configuration card
                bestConfigurationCard(analysis: analysis)
                
                // Tab selector
                tabSelector
                
                // Tab content
                TabView(selection: $selectedTab) {
                    placementsTab(analysis: analysis)
                        .tag(0)
                    
                    acousticIssuesTab(analysis: analysis)
                        .tag(1)
                    
                    recommendationsTab(analysis: analysis)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .padding()
        }
    }
    
    // MARK: - Best Configuration Card
    private func bestConfigurationCard(analysis: RoomAnalysis) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                
                Text("Recommended Configuration")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(analysis.bestConfiguration.rawValue)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Best for your room size and acoustics")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Score indicator
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(analysis.speakerSystems.first?.overallScore ?? 0) / 10.0)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.green]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int((analysis.speakerSystems.first?.overallScore ?? 0) * 10))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    Text("Score")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Placements",
                icon: "speaker.wave.2.fill",
                isSelected: selectedTab == 0
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 0
                }
            }
            
            TabButton(
                title: "Issues",
                icon: "exclamationmark.triangle.fill",
                isSelected: selectedTab == 1
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 1
                }
            }
            
            TabButton(
                title: "Tips",
                icon: "lightbulb.fill",
                isSelected: selectedTab == 2
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 2
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // MARK: - Placements Tab
    private func placementsTab(analysis: RoomAnalysis) -> some View {
        VStack(spacing: 16) {
            ForEach(analysis.speakerSystems.first?.placements ?? [], id: \.id) { placement in
                SpeakerPlacementCard(placement: placement)
            }
        }
    }
    
    // MARK: - Acoustic Issues Tab
    private func acousticIssuesTab(analysis: RoomAnalysis) -> some View {
        VStack(spacing: 16) {
            if analysis.acousticIssues.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text("No Major Issues Detected")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Your room has good acoustic properties")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            } else {
                ForEach(analysis.acousticIssues) { issue in
                    AcousticIssueCard(issue: issue)
                }
            }
        }
    }
    
    // MARK: - Recommendations Tab
    private func recommendationsTab(analysis: RoomAnalysis) -> some View {
        VStack(spacing: 16) {
            ForEach(Array(analysis.improvementSuggestions.enumerated()), id: \.offset) { index, suggestion in
                RecommendationCard(
                    number: index + 1,
                    suggestion: suggestion
                )
            }
        }
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Analysis Failed")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Please try scanning your room again")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                isLoading = true
                Task {
                    analysis = await analyzer.analyzeRoom(from: Data())
                    isLoading = false
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SpeakerPlacementCard: View {
    let placement: SpeakerPlacement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Speaker icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: speakerIcon(for: placement.speakerType))
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(placement.speakerType.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Confidence: \(Int(placement.confidence * 100))%")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Confidence indicator
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 3)
                        .frame(width: 30, height: 30)
                    
                    Circle()
                        .trim(from: 0, to: placement.confidence)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 30, height: 30)
                        .rotationEffect(.degrees(-90))
                }
            }
            
            // Position info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Position:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("(\(String(format: "%.1f", placement.position.x)), \(String(format: "%.1f", placement.position.y)), \(String(format: "%.1f", placement.position.z)))")
                        .font(.system(size: 12, family: .monospaced))
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Distance:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.1f", placement.distance))m")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Angle:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.0f", placement.angle))°")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
            
            // Reasoning
            Text(placement.reasoning)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func speakerIcon(for type: SpeakerPlacement.SpeakerType) -> String {
        switch type {
        case .leftFront, .rightFront:
            return "speaker.wave.2.fill"
        case .center:
            return "speaker.wave.1.fill"
        case .leftSurround, .rightSurround:
            return "speaker.wave.2"
        case .subwoofer:
            return "speaker.wave.3.fill"
        case .height:
            return "speaker.wave.1"
        }
    }
}

struct AcousticIssueCard: View {
    let issue: AcousticIssue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Issue icon
                ZStack {
                    Circle()
                        .fill(severityColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(severityColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(issue.type.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(issue.severity.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(severityColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(severityColor.opacity(0.1))
                        )
                }
                
                Spacer()
            }
            
            Text(issue.description)
                .font(.system(size: 14))
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
                
                Text(issue.suggestedSolution)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var severityColor: Color {
        switch issue.severity {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        case .critical:
            return .purple
        }
    }
}

struct RecommendationCard: View {
    let number: Int
    let suggestion: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Number badge
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
            
            Text(suggestion)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct SpeakerPlacementView_Previews: PreviewProvider {
    static var previews: some View {
        SpeakerPlacementView(roomData: RoomData(
            dimensions: RoomDimensions(width: 5, length: 6, height: 2.8),
            surfaces: [],
            obstacles: [],
            acousticProperties: AcousticProperties(reverberationTime: 0.5, clarityIndex: 8, speechTransmissionIndex: 0.9, backgroundNoiseLevel: 30, roomMode: [60, 80, 120]),
            scanQuality: .excellent
        ))
    }
} 