# AcouSpace - AI-Powered Speaker Placement Assistant

An iOS application that uses computer vision and AI technology to help users optimize speaker placement in their rooms for the best audio experience.

## Features

- **Room Scanning**: Uses iPhone camera and LiDAR (when available) to scan and analyze room dimensions
- **AI Analysis**: Computer vision algorithms detect walls, surfaces, and obstacles
- **Acoustic Modeling**: Analyzes room acoustics including reverberation time, standing waves, and room modes
- **Speaker Placement Recommendations**: Provides optimal speaker positioning for various configurations:
  - 2.0 Stereo
  - 2.1 Stereo with Subwoofer
  - 5.1 Surround Sound
  - 7.1 Surround Sound
  - Dolby Atmos
- **Acoustic Issue Detection**: Identifies potential acoustic problems and provides solutions
- **Visual Feedback**: Clear recommendations with reasoning for each speaker placement

## Technology Stack

- **SwiftUI**: Modern declarative UI framework
- **ARKit**: Augmented Reality framework for room scanning
- **Vision Framework**: Computer vision for object and surface detection
- **Core ML**: Machine learning capabilities for acoustic analysis
- **RealityKit**: 3D scene understanding and mesh reconstruction

## Requirements

- iOS 17.0+
- Xcode 15.0+
- iPhone with camera (LiDAR recommended for best results)
- Swift 5.0+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/AcouSpace.git
```

2. Open the project in Xcode:
```bash
cd AcouSpace
open AcouSpace.xcodeproj
```

3. Build and run the project on your device or simulator

## Usage

1. **Launch the App**: Open AcouSpace on your iPhone
2. **Scan Your Room**: Tap "Scan Room" and follow the on-screen instructions
3. **Wait for Analysis**: The AI will analyze your room's acoustics
4. **View Recommendations**: Get detailed speaker placement suggestions
5. **Follow Guidelines**: Implement the recommended speaker positions

## Project Structure

```
AcouSpace/
├── AcouSpaceApp.swift          # Main app entry point
├── ContentView.swift           # Main navigation interface
├── RoomScannerView.swift       # AR-based room scanning
├── SpeakerPlacementView.swift  # Results and recommendations display
├── RoomAnalyzer.swift          # AI analysis engine
└── SpeakerPlacementModel.swift # Data models and structures
```

## Key Components

### RoomScannerView
- Uses ARKit for room scanning
- Supports LiDAR for precise depth mapping
- Detects walls, floors, ceilings, and obstacles
- Provides real-time feedback during scanning

### RoomAnalyzer
- Processes scanned room data
- Calculates acoustic properties (reverberation time, room modes)
- Generates speaker placement recommendations
- Identifies acoustic issues and provides solutions

### SpeakerPlacementModel
- Defines data structures for room analysis
- Models acoustic properties and speaker configurations
- Handles serialization for data persistence

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Apple ARKit and Vision frameworks
- Acoustic engineering principles
- Speaker placement best practices

## Future Enhancements

- [ ] Support for multiple room configurations
- [ ] Integration with smart home systems
- [ ] Real-time acoustic measurement
- [ ] Cloud-based analysis for complex rooms
- [ ] Export recommendations to PDF
- [ ] Integration with speaker manufacturers' APIs

## Support

If you encounter any issues or have questions, please open an issue on GitHub or contact the development team. 