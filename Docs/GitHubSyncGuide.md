# GitHub Data Sync Guide

## Overview

FilmLab now supports automatic data synchronization with the GitHub repository [filmdevelopmentdata](https://github.com/maximeliseyev/filmdevelopmentdata). This allows users to keep their local database up-to-date with the latest film development data without manually updating JSON files.

## Features

### Automatic Data Sync
- Downloads films, developers, development times, and temperature multipliers from GitHub
- Compares with existing local data and adds only new entries
- Preserves user's existing data and calculations
- Shows sync progress and last sync date

### User Interface
- New "Data" section in Settings
- Sync button with progress indicator
- Last sync date display
- Success/error alerts

## Technical Implementation

### GitHubDataService
Located in `Core/Services/GitHubDataService.swift`:

```swift
public class GitHubDataService: ObservableObject {
    // Downloads data from GitHub repository
    func downloadAllData() async throws -> GitHubData
    
    // Progress tracking
    @Published var isDownloading: Bool
    @Published var downloadProgress: Double
    @Published var lastSyncDate: Date?
}
```

### CoreDataService Integration
The `CoreDataService` has been extended with:

```swift
func syncDataFromGitHub() async throws {
    // Downloads data from GitHub
    // Compares with existing data
    // Adds only new entries
    // Updates UI
}
```

### Settings Integration
The `SettingsView` includes:

- Data sync section with progress indicator
- Sync button with loading state
- Last sync date display
- Error handling with user-friendly messages

## Data Structure

The GitHub repository contains:

- `films.json` - Film definitions
- `developers.json` - Developer definitions  
- `development-times.json` - Development time data
- `temperature-multipliers.json` - Temperature correction factors

## Usage

1. Open Settings in the app
2. Navigate to the "Data" section
3. Tap "Sync Now" to download latest data
4. Wait for sync to complete
5. Check the last sync date to confirm success

## Error Handling

The system handles various error scenarios:

- Network connectivity issues
- Invalid JSON data
- Missing required fields
- Duplicate data prevention

## Localization

All user-facing strings are localized in:

- `Resources/Localization/en.lproj/Localizable.strings`
- `Resources/Localization/ru.lproj/Localizable.strings`

## Testing

Tests are available in `Tests/GitHubSyncTests.swift`:

- Data download verification
- Progress tracking
- Sync date persistence

## Future Enhancements

Potential improvements:

- Automatic background sync
- Conflict resolution for modified local data
- Sync frequency settings
- Offline mode support 