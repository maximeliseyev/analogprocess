# ThemeManager Documentation

## Обзор

`ThemeManager` - это централизованная система управления цветами и темами в приложении FilmLab. Он заменяет хардкод цветов на гибкую систему, которая автоматически адаптируется к светлой и темной темам.

## Структура

### ThemeProvider Protocol
Протокол для Environment (non-isolated контексты):

```swift
protocol ThemeProvider {
    var colorScheme: ColorScheme? { get }
    
    // Background Colors
    var primaryBackground: Color { get }
    var secondaryBackground: Color { get }
    var cardBackground: Color { get }
    var parameterCardBackground: Color { get }
    
    // Text Colors
    var primaryText: Color { get }
    var secondaryText: Color { get }
    var captionText: Color { get }
    
    // Accent Colors
    var primaryAccent: Color { get }
    var secondaryAccent: Color { get }
    var successAccent: Color { get }
    var warningAccent: Color { get }
    var dangerAccent: Color { get }
    var purpleAccent: Color { get }
    
    // Button Colors
    var primaryButtonBackground: Color { get }
    var primaryButtonText: Color { get }
    var secondaryButtonBackground: Color { get }
    var secondaryButtonText: Color { get }
    
    // Selection Colors
    var selectionBackground: Color { get }
    var selectionBorder: Color { get }
    
    // Timer Colors
    var timerActiveBackground: Color { get }
    var timerInactiveBackground: Color { get }
    var agitationBackground: Color { get }
}
```

### Основные классы

1. **ThemeManager** - основной класс для управления темой (MainActor, изолированный)
2. **NonIsolatedThemeManager** - версия для использования в Environment (non-isolated)

## Использование

### В SwiftUI Views (Environment)

```swift
struct MyView: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        ZStack {
            theme.primaryBackground
                .ignoresSafeArea()
            
            VStack {
                Text("Hello World")
                    .foregroundColor(theme.primaryText)
                
                Button("Click me") {
                    // Action
                }
                .primaryButtonStyle()
            }
        }
    }
}
```

### Использование стилей из ViewStyles

```swift
// Кнопки
Button("Primary") { }.primaryButtonStyle()
Button("Secondary") { }.secondaryButtonStyle()

// Карточки
VStack { }.cardStyle()
HStack { }.parameterCardStyle()

// Текст
Text("Title").headlineTextStyle()
Text("Body").bodyTextStyle()
Text("Caption").captionTextStyle()
```

### Прямое использование ThemeManager.shared (MainActor)

```swift
// Для статических элементов в MainActor контекстах
.background(ThemeManager.shared.primaryBackground)
.foregroundColor(ThemeManager.shared.primaryText)
```

## Интеграция в приложение

### 1. В FilmLabApp.swift

```swift
@main
struct FilmLabApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.theme, NonIsolatedThemeManager())
                .onChange(of: colorScheme) { _, newValue in
                    Task { @MainActor in
                        themeManager.colorScheme = newValue
                    }
                }
        }
    }
}
```

### 2. Синхронизация с системной темой

ThemeManager автоматически адаптируется к системной теме через `colorScheme`. Когда пользователь меняет тему в настройках, все цвета обновляются автоматически.

## Преимущества

1. **Централизованное управление** - все цвета в одном месте
2. **Автоматическая адаптация** - поддержка светлой и темной тем
3. **Типобезопасность** - компилятор проверяет правильность использования
4. **Легкость изменения** - изменение цвета в одном месте обновляет весь интерфейс
5. **Консистентность** - единообразное использование цветов во всем приложении
6. **Swift 6 совместимость** - правильная изоляция MainActor

## Миграция с хардкода

### Было:
```swift
.background(Color.black)
.foregroundColor(.white)
.background(Color.blue)
```

### Стало:
```swift
.background(theme.primaryBackground)
.foregroundColor(theme.primaryText)
.background(theme.primaryAccent)
```

## Добавление новых цветов

1. Добавьте свойство в протокол `ThemeProvider`
2. Реализуйте логику в extension `ThemeProvider`
3. Добавьте то же свойство в класс `ThemeManager`
4. Используйте новый цвет в views

```swift
// В ThemeProvider
var customColor: Color { get }

// В extension ThemeProvider
var customColor: Color {
    switch colorScheme {
    case .light:
        return Color.yellow
    case .dark:
        return Color.orange
    case nil:
        return Color.yellow
    @unknown default:
        return Color.yellow
    }
}

// В ThemeManager (дублируем логику)
var customColor: Color {
    switch colorScheme {
    case .light:
        return Color.yellow
    case .dark:
        return Color.orange
    case nil:
        return Color.yellow
    @unknown default:
        return Color.yellow
    }
}
```

## Примеры использования

Смотрите файл `ThemeManagerExample.swift` для полного примера использования всех возможностей ThemeManager. 