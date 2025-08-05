# Архитектурные подходы для AgitationMode

## Обзор

Текущая реализация `AgitationMode` была рефакторена в более гибкую и расширяемую архитектуру, соответствующую принципам SOLID и протокол-ориентированному программированию. Предлагаются три основных подхода:

## 1. Strategy Pattern + Protocol-Oriented Programming

### Преимущества:
- **Гибкость**: Каждый тип агитации инкапсулирован в отдельную стратегию
- **Расширяемость**: Легко добавлять новые типы агитации
- **Тестируемость**: Каждую стратегию можно тестировать изолированно
- **Соблюдение SOLID**: Single Responsibility, Open/Closed, Dependency Inversion

### Использование:

```swift
// Создание через сервис
let service = AgitationModeService()
let presets = service.presets

// Создание кастомного режима
let customMode = service.createCustomMode(agitationSeconds: 30, restSeconds: 30)

// Использование
let agitation = customMode.getAgitationForMinute(5, totalMinutes: 10)
```

### Структура:
- `AgitationStrategy` - протокол для стратегий
- `ContinuousAgitationStrategy` - стратегия непрерывной агитации
- `CycleAgitationStrategy` - стратегия циклической агитации
- `ComplexAgitationStrategy` - стратегия сложной агитации с фазами
- `AgitationModeService` - сервис для работы с режимами

## 2. Builder Pattern

### Преимущества:
- **Читаемость**: Цепочка методов для создания объектов
- **Гибкость**: Можно создавать объекты с разными параметрами
- **Валидация**: Можно добавить проверки на этапе сборки
- **Fluent Interface**: Интуитивный API

### Использование:

```swift
// Создание стандартных режимов
let orwoMode = AgitationModeBuilder.createORWO()
let xtolMode = AgitationModeBuilder.createXTOL()

// Создание кастомного режима
let customMode = AgitationModeBuilder.createCustomCycle(
    agitationSeconds: 45, 
    restSeconds: 15
)

// Создание через билдер
let mode = AgitationModeBuilder()
    .setName("Custom Mode")
    .setType(.custom)
    .setCustom(true)
    .setCycleParameters(agitationSeconds: 30, restSeconds: 30)
    .build()
```

### Структура:
- `AgitationModeBuilder` - основной билдер
- Factory методы для стандартных режимов
- Цепочка методов для настройки параметров

## 3. Configuration Pattern

### Преимущества:
- **Конфигурируемость**: Режимы можно загружать из внешних источников
- **Сериализация**: Поддержка JSON/XML конфигураций
- **Динамичность**: Можно изменять режимы без перекомпиляции
- **Централизация**: Все конфигурации в одном месте

### Использование:

```swift
// Создание менеджера конфигураций
let configManager = AgitationConfigurationManager()

// Получение конфигурации
let orwoConfig = configManager.getConfiguration(for: .orwo)

// Создание режима из конфигурации
let mode = AgitationConfigurationAdapter.createAgitationMode(from: orwoConfig)

// Создание кастомной конфигурации
let customConfig = configManager.createCustomConfiguration(
    agitationSeconds: 30, 
    restSeconds: 30
)
```

### Структура:
- `AgitationConfiguration` - модель конфигурации
- `AgitationConfigurationManager` - менеджер конфигураций
- `AgitationConfigurationAdapter` - адаптер для преобразования

## Рекомендации по выбору подхода

### Strategy Pattern подходит для:
- Сложной бизнес-логики агитации
- Частого добавления новых типов агитации
- Требований к тестируемости
- Соблюдения SOLID принципов

### Builder Pattern подходит для:
- Создания сложных объектов с множеством параметров
- Требований к читаемости кода
- Fluent API
- Валидации параметров при создании

### Configuration Pattern подходит для:
- Загрузки конфигураций из внешних источников
- Динамического изменения режимов
- Сериализации/десериализации
- Централизованного управления конфигурациями

## Обратная совместимость

Все три подхода обеспечивают обратную совместимость через статические методы в `AgitationMode`:

```swift
// Старый код продолжает работать
let presets = AgitationMode.presets
let customMode = AgitationMode.createCustomMode(agitationSeconds: 30, restSeconds: 30)
```

## Миграция

Для постепенной миграции рекомендуется:

1. Начать с Strategy Pattern для новых функций
2. Использовать Builder Pattern для создания кастомных режимов
3. Применить Configuration Pattern для управления стандартными режимами
4. Постепенно заменить старый код на новый API

## Тестирование

Каждый подход поддерживает unit-тестирование:

```swift
// Тестирование стратегий
func testContinuousAgitationStrategy() {
    let strategy = ContinuousAgitationStrategy()
    let phase = strategy.getAgitationForMinute(5, totalMinutes: 10)
    XCTAssertEqual(phase.agitationType, .continuous)
}

// Тестирование билдера
func testAgitationModeBuilder() {
    let mode = AgitationModeBuilder()
        .setName("Test")
        .setType(.continuous)
        .build()
    XCTAssertEqual(mode.name, "Test")
}

// Тестирование конфигураций
func testAgitationConfiguration() {
    let config = AgitationConfigurationManager().getConfiguration(for: .orwo)
    XCTAssertNotNil(config)
}
``` 