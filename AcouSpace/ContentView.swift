import SwiftUI

struct ContentView: View {
    @State private var showingRoomScanner = false
    @State private var showingSpeakerPlacement = false
    @State private var roomData: RoomData?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("AcouSpace")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("AI-Powered Speaker Placement")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Main action buttons
                VStack(spacing: 20) {
                    Button(action: {
                        showingRoomScanner = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text("Scan Room")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingSpeakerPlacement = true
                    }) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title2)
                            Text("Speaker Placement")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    .disabled(roomData == nil)
                    .opacity(roomData == nil ? 0.6 : 1.0)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Info section
                VStack(spacing: 15) {
                    Text("How it works:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "1.circle.fill")
                                .foregroundColor(.blue)
                            Text("Scan your room with camera")
                        }
                        
                        HStack {
                            Image(systemName: "2.circle.fill")
                                .foregroundColor(.blue)
                            Text("AI analyzes room acoustics")
                        }
                        
                        HStack {
                            Image(systemName: "3.circle.fill")
                                .foregroundColor(.blue)
                            Text("Get optimal speaker placement")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.bottom, 30)
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 