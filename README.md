# FilmLab

A comprehensive iOS application for film development, providing tools for calculating development times, managing timers, and tracking development sessions.

## Features

### 🎯 Core Functionality
- **Development Setup**: Configure film, developer, dilution, ISO, and temperature parameters
- **Time Calculator**: Calculate push/pull development times with custom coefficients
- **Development Timer**: Professional timer with agitation patterns and progress tracking
- **Journal**: Save and manage development records and calculations

### 🎨 User Interface
- **Dark Theme**: Modern iOS-style dark interface
- **Navigation**: Tab-based navigation with home screen and child screens
- **Responsive Design**: Optimized for iPhone and iPad

### 📱 Navigation Structure
- **Main Screen**: Overview with app description and quick access buttons
- **Development Setup**: Film and developer parameter configuration
- **Calculator**: Time calculation with push/pull processing
- **Timer**: Development timer with agitation patterns
- **Journal**: Saved records and development history

## Architecture

### Navigation System
- **MainTabView**: Central navigation controller with TabView for child screens
- **NavigationStack**: Modern SwiftUI navigation with NavigationLink
- **Home Button**: Single home button in toolbar for all child screens
- **TabBar**: Hidden on main screen, visible on child screens

### Data Management
- **CoreData**: Persistent storage for development records
- **JSON Import**: Film and developer data from JSON files
- **Calculation Engine**: Development time calculations with temperature compensation

### View Structure
```
FilmLab/
├── App/
├── Core/
│   ├── Models/
│   ├── Navigation/
│   ├── Persistence/
│   └── Services/
├── Features/
│   ├── Calculator/
│   ├── Development/
│   ├── Journal/
│   ├── Manual/
│   └── Timer/
├── Resources/
└── Tests/
```

## Development

### Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### Setup
1. Clone the repository
2. Open `FilmLab.xcodeproj` in Xcode
3. Build and run on iOS Simulator or device

### Testing
- **NavigationTests**: Tests for navigation flow and tab switching
- **NavigationFlowTests**: Integration tests for navigation state
- **IntegrationTests**: End-to-end flow testing

## Localization

The app supports multiple languages:
- **English**: Primary language
- **Russian**: Secondary language

Localization files are located in `Resources/Localization/`.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## Version History

### v1.0.0
- Initial release with core functionality
- Modern SwiftUI navigation system
- Dark theme interface
- CoreData persistence
- Localization support 