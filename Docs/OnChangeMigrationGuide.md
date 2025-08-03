# onChange Migration Guide

## Overview

This guide documents the migration from the deprecated `onChange(of:perform:)` syntax to the new iOS 17+ syntax.

## Migration Details

### Old Syntax (Deprecated)
```swift
.onChange(of: someValue) { newValue in
    // Handle change
}
```

### New Syntax (iOS 17+)
```swift
.onChange(of: someValue) { oldValue, newValue in
    // Handle change
}
```

## Changes Made

### DevelopmentSetupView.swift
**Before:**
```swift
.onChange(of: viewModel.iso) { _ in
    viewModel.updateISO(viewModel.iso)
}
.onChange(of: viewModel.temperature) { _ in
    viewModel.updateTemperature(viewModel.temperature)
}
```

**After:**
```swift
.onChange(of: viewModel.iso) { oldValue, newValue in
    viewModel.updateISO(newValue)
}
.onChange(of: viewModel.temperature) { oldValue, newValue in
    viewModel.updateTemperature(newValue)
}
```

### SettingsView.swift
**Before:**
```swift
.onChange(of: selectedTheme) { newValue in
    switch newValue {
    case 1: colorScheme = .light
    case 2: colorScheme = .dark
    default: colorScheme = nil
    }
}
```

**After:**
```swift
.onChange(of: selectedTheme) { oldValue, newValue in
    switch newValue {
    case 1: colorScheme = .light
    case 2: colorScheme = .dark
    default: colorScheme = nil
    }
}
```

## Benefits of New Syntax

### 1. Access to Old Value
The new syntax provides access to both the old and new values:
```swift
.onChange(of: temperature) { oldValue, newValue in
    print("Temperature changed from \(oldValue) to \(newValue)")
}
```

### 2. Better Performance
The new syntax is more efficient and provides better performance characteristics.

### 3. Future-Proof
The new syntax is the recommended approach for iOS 17+ and will be supported in future versions.

## Compatibility

### iOS Version Support
- **iOS 16 and earlier**: Old syntax still works but shows deprecation warnings
- **iOS 17+**: New syntax is required for optimal performance

### Migration Strategy
1. **Immediate**: Update all `onChange` calls to use new syntax
2. **Testing**: Verify functionality with new syntax
3. **Documentation**: Update any documentation referencing the old syntax

## Testing

### Test Cases
The migration includes comprehensive tests in `OnChangeMigrationTests.swift`:

1. **Basic Functionality**: Tests the new syntax with simple value changes
2. **Type Compatibility**: Tests with different data types (String, Int, Double)
3. **Optional Values**: Tests with optional types
4. **Enum Values**: Tests with enum types

### Test Coverage
- ✅ New syntax functionality
- ✅ Old vs new value handling
- ✅ Different data types
- ✅ Optional values
- ✅ Enum values

## Best Practices

### 1. Use Both Parameters
Even if you don't need the old value, include both parameters:
```swift
.onChange(of: value) { _, newValue in
    // Handle new value
}
```

### 2. Handle Optional Values
For optional values, handle both nil and non-nil cases:
```swift
.onChange(of: optionalValue) { oldValue, newValue in
    if let newValue = newValue {
        // Handle non-nil value
    } else {
        // Handle nil value
    }
}
```

### 3. Consider Performance
For complex objects, consider if you need to react to all changes or just specific properties.

## Future Considerations

### Potential Enhancements
- **Batch Changes**: Handle multiple property changes simultaneously
- **Debouncing**: Add debouncing for rapid changes
- **Conditional Updates**: Only update when specific conditions are met

### Monitoring
- Watch for any new deprecation warnings
- Monitor performance improvements
- Track any issues with the new syntax

## Conclusion

The migration to the new `onChange` syntax is complete and provides:
- ✅ Better performance
- ✅ Access to both old and new values
- ✅ Future-proof code
- ✅ Comprehensive test coverage

All deprecation warnings have been resolved and the code is now using the recommended iOS 17+ syntax. 