# Navigation in FilmLab

## Navigation Architecture Overview

The application uses a modern SwiftUI navigation system with TabView and NavigationStack:

1. **MainTabView** - Central navigation controller with conditional TabView
2. **Home Screen** - Main screen with app description and quick access buttons
3. **Child Screens** - TabView with 4 main functions

## Navigation Structure

### ContentView
- Manages the main app state
- Contains `selectedTab` state for current screen
- Uses MainTabView as the primary navigation container

### MainTabView
- **Main Screen (selectedTab == 0)**: Home screen without TabBar
- **Child Screens (selectedTab == 1-4)**: TabView with 4 tabs
- **Home Button**: Single home button in toolbar for all child screens

### Navigation Flow
- **Main Screen**: Clean interface with description and function buttons
- **Child Screens**: TabView with bottom navigation bar
- **Home Button**: Returns to main screen (selectedTab = 0)

## Screen Structure

### Main Screen (selectedTab == 0)
- **No TabBar**: Hidden for clean interface
- **No Home Button**: Only settings button in toolbar
- **Function Buttons**: Direct access to main features
- **App Description**: Overview of FilmLab capabilities

### Child Screens (selectedTab == 1-4)
- **TabView**: Bottom navigation with 4 tabs
- **Home Button**: Single button in top-left corner
- **Settings Button**: Available in toolbar

### Tab Structure
1. **Presets** (Development Setup) - Film and developer configuration
2. **Calculator** - Time calculation with push/pull processing
3. **Timer** - Development timer with agitation patterns
4. **Journal** - Saved records and development history

## Navigation Implementation

### MainTabView Structure
```swift
NavigationStack {
    if selectedTab == 0 {
        mainScreenView // Home screen without TabView
    } else {
        TabView(selection: $selectedTab) {
            // Child screens with tabs
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: goToHome) {
                    Image(systemName: "house")
                }
            }
        }
    }
}
```

### Home Button Functionality
```swift
private func goToHome() {
    selectedTab = 0 // Return to main screen
}
```

## Navigation Patterns

### 1. Main Screen → Child Screen
```swift
Button(action: {
    selectedTab = idx + 1 // Navigate to child screen
}) {
    // Function button content
}
```

### 2. Child Screen → Main Screen
```swift
Button(action: goToHome) {
    Image(systemName: "house")
}
```

### 3. NavigationLink Usage
- **Settings**: NavigationLink to SettingsView
- **Timer**: NavigationLink from Calculator and Development screens
- **Results**: Sheet presentation for calculation results

## State Management

### ContentView
- `@State private var selectedTab = 0`

### MainTabView
- `@Binding var selectedTab: Int`
- `var onBackToHome: () -> Void`

## Testing Navigation

### Created Tests:
1. **NavigationTests.swift** - Basic navigation tests
2. **NavigationFlowTests.swift** - Navigation flow tests
3. **IntegrationTests.swift** - End-to-end integration tests

### Key Test Scenarios:
- Main screen to child screen navigation
- Tab switching functionality
- Home button functionality
- Sheet presentation
- Navigation error handling

## Development Guidelines

### Adding New Screens:
1. Add button to main screen (update ForEach and functions)
2. Add tab to MainTabView TabView
3. Create corresponding tests
4. Update navigation documentation

### Modifying Navigation:
1. Update MainTabView for new state management
2. Update tests for new navigation flows
3. Update documentation

## Potential Issues

### Known Issues:
1. No tab index validation
2. No error handling for invalid data
3. No transition animations between screens

### Improvement Recommendations:
1. Add tab index validation
2. Add error handling
3. Add transition animations
4. Add UI tests for actual button presses

## Recent Changes

### Navigation System Updates:
1. **Removed HomeView**: Integrated into MainTabView
2. **Single Home Button**: One button in toolbar for all child screens
3. **TabBar Management**: Hidden on main screen, visible on child screens
4. **Simplified State**: Removed complex navigation state management

### Architecture Improvements:
1. **Modern SwiftUI**: Using NavigationStack and NavigationLink
2. **Clean Interface**: Single home button instead of multiple
3. **Better UX**: TabBar only where needed
4. **Simplified Code**: Removed unnecessary parameters and closures 