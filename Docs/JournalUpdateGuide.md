# Journal Update Guide

## Overview

The journal has been completely redesigned with a new record structure that provides more comprehensive information about film development sessions.

## New Record Structure

### Required Fields
- **Date & Time**: Automatically set to current date/time
- **Film**: Film name (required)
- **Developer**: Developer name (required)

### Optional Fields
- **Name**: Custom name for the record (optional)
- **Dilution**: Developer dilution ratio
- **Temperature**: Development temperature in °C
- **Time**: Development time in minutes
- **Comment**: Additional notes about the development

## Features

### Creating Records

#### From Calculator Results
1. Calculate development time in the calculator
2. View results in CalculationResultView
3. Tap the book icon to save to journal
4. Record is automatically created with calculated parameters

#### From Scratch
1. Open Journal view
2. Tap the "+" button in the toolbar
3. Fill in the required and optional fields
4. Tap "Save" to create the record

### Journal View
- **Scrollable List**: All records displayed in chronological order
- **Swipe to Delete**: Swipe left on any record to delete it
- **Rich Information**: Each record shows all relevant parameters
- **Search & Filter**: Future enhancement for finding specific records

### Record Display
Each record shows:
- **Header**: Name (if provided) or Film + Developer
- **Date**: When the record was created
- **Parameters**: Dilution, temperature, time
- **Comment**: Additional notes (if provided)

## Technical Implementation

### Data Model
```swift
public struct JournalRecord {
    public let id = UUID()
    public var date: Date
    public var name: String?
    public var filmName: String?
    public var developerName: String?
    public var dilution: String?
    public var temperature: Double?
    public var time: Int?
    public var comment: String?
}
```

### Core Data Integration
- Records are stored as `CalculationRecord` entities
- New fields: `name`, `comment`
- Automatic conversion between `JournalRecord` and `CalculationRecord`

### Views
- **CreateRecordView**: Form for creating new records
- **JournalView**: List of all records with delete functionality
- **RecordRowView**: Individual record display

## User Interface

### CreateRecordView
- **Form-based interface** with sections for different data types
- **Validation**: Film and developer names are required
- **Prefill support**: Can be pre-filled with calculator results
- **Date picker**: For setting custom date/time

### JournalView
- **List interface** with swipe-to-delete
- **Add button**: "+" in toolbar for creating new records
- **Empty state**: Helpful message when no records exist

## Localization

All strings are localized in:
- `Resources/Localization/en.lproj/Localizable.strings`
- `Resources/Localization/ru.lproj/Localizable.strings`

New localization keys:
- `journal_create_record`
- `journal_record_basic_info`
- `journal_record_name`
- `journal_record_film`
- `journal_record_developer`
- `journal_record_parameters`
- `journal_record_dilution`
- `journal_record_temperature`
- `journal_record_time`
- `journal_record_comment`
- `journal_record_comment_placeholder`
- `journal_record_date`

## Migration

### From Old Structure
- Existing records are automatically converted
- Old fields are preserved
- New fields are optional and can be added later

### Data Compatibility
- Backward compatible with existing records
- New fields are optional
- No data loss during migration

## Future Enhancements

### Planned Features
- **Search functionality**: Find records by film, developer, or date
- **Filtering**: Filter by date range, film type, etc.
- **Export**: Export records to CSV or PDF
- **Statistics**: Development statistics and trends
- **Tags**: Custom tags for organizing records
- **Photos**: Attach photos of developed film

### Technical Improvements
- **Batch operations**: Delete multiple records
- **Undo functionality**: Recover deleted records
- **Cloud sync**: Sync records across devices
- **Backup**: Export/import journal data

## Usage Examples

### Creating a Record from Calculator
```swift
let journalRecord = JournalRecord(
    date: Date(),
    name: "Portrait in Park",
    filmName: "Ilford HP5 Plus",
    developerName: "Kodak Xtol",
    dilution: "1+1",
    temperature: 20.0,
    time: 480,
    comment: "Good results, slightly soft contrast"
)
```

### Saving to Core Data
```swift
coreDataService.saveJournalRecord(journalRecord)
```

### Loading Records
```swift
let records = coreDataService.getCalculationRecords()
    .map { JournalRecord.fromCalculationRecord($0) }
``` 