# ПЛАН РЕФАКТОРИНГА ПРОЕКТА ANALOGPROCESS

> Документ создан: 2025-01-14
> Статус: В ожидании реализации

## 🎯 ЦЕЛИ РЕФАКТОРИНГА

1. **Устранить дублирование кода** - сократить объем кода на ~30%
2. **Упростить архитектуру** - убрать избыточные слои абстракции
3. **Повысить поддерживаемость** - унифицировать повторяющиеся паттерны
4. **Улучшить производительность** - оптимизировать тяжелые операции

---

## 🔥 КРИТИЧЕСКИЕ ПРОБЛЕМЫ (Приоритет 1)

### 1.1 Неиспользуемый HomeView
**Проблема:** HomeView.swift не используется, функциональность дублирована в MainTabView
- `Core/Navigation/HomeView.swift` - полностью не используется
- `Core/Navigation/MainTabView.swift` - содержит дублированную логику главного экрана

**Решение:**
```
✅ ДЕЙСТВИЕ: Удалить неиспользуемый HomeView.swift
📁 УДАЛИТЬ: Core/Navigation/HomeView.swift
📝 РЕЗУЛЬТАТ: Единое место для изменений главного экрана (MainTabView.mainScreenView)
⏱️ ВРЕМЯ: 15 минут
```

### 1.2 Дублирование констант
**Проблема:** 3 файла с одинаковыми константами
- `Core/Models/Constants.swift`
- `Core/Shared/Constants/AppConstants.swift`
- `Core/Shared/Constants/NetworkConstants.swift`

**Решение:**
```
✅ ДЕЙСТВИЕ: Объединить все в AppConstants.swift
📁 УДАЛИТЬ: Constants.swift, NetworkConstants.swift
📝 ОБНОВИТЬ: Все импорты в проекте
⏱️ ВРЕМЯ: 2 часа
```

### 1.3 Дублированный ParameterRow
**Проблема:** Два идентичных компонента
- `Shared/Components/ParameterRow.swift`
- `Features/Development/Views/Components/ParameterRow.swift`

**Решение:**
```
✅ ДЕЙСТВИЕ: Оставить только Shared версию
📁 УДАЛИТЬ: Development/Views/Components/ParameterRow.swift
📝 ОБНОВИТЬ: Импорты в Development модуле
⏱️ ВРЕМЯ: 30 минут
```

### 1.4 Избыточная архитектура сервисов
**Проблема:** Тройная вложенность DataService -> Repository -> ModelContext

**Решение:**
```
✅ ДЕЙСТВИЕ: Упростить до DataService -> ModelContext
📁 УДАЛИТЬ: SwiftDataRepository.swift
📝 ОБНОВИТЬ: SwiftDataService - прямая работа с ModelContext
📝 УБРАТЬ: Лишние протоколы FilmProtocol, DeveloperProtocol
⏱️ ВРЕМЯ: 4 часа
```

### 1.5 Удаление неиспользуемого NavigationButton
**Проблема:** Дублирование логики отображения кнопок на главном экране.
- `Core/Navigation/NavigationButton.swift` - неиспользуемый компонент.
- `Core/Navigation/NavigationConstants.swift` - содержит неиспользуемую структуру `NavigationButtonData`.

**Решение:**
```
✅ ДЕЙСТВИЕ: Удалить неиспользуемые файлы и структуры.
📁 УДАЛИТЬ: Core/Navigation/NavigationButton.swift
📝 ОБНОВИТЬ: Core/Navigation/NavigationConstants.swift - удалить `NavigationButtonData`.
⏱️ ВРЕМЯ: 15 минут
```

---

## ⚡ ВЫСОКИЙ ПРИОРИТЕТ (Приоритет 2)

### 2.1 Унификация Picker компонентов
**Проблема:** 8 похожих Picker'ов с дублированной логикой

**Решение:**
```
✅ СОЗДАТЬ: BasePickerView<T: Searchable>
📝 РЕФАКТОРИТЬ: FilmPickerView, DeveloperPickerView, FixerPickerView
📝 УНИФИЦИРОВАТЬ: Логику поиска и фильтрации
⏱️ ВРЕМЯ: 6 часов
```

**Пример архитектуры:**
```swift
struct BasePickerView<T: Searchable>: View {
    @Binding var selection: T?
    let items: [T]
    let title: String

    var body: some View {
        // Унифицированная логика поиска
    }
}

protocol Searchable {
    var searchableText: String { get }
}
```

### 2.2 Объединение AutoComplete логики
**Проблема:** Дублированные suggestion методы в 3 ViewModels

**Решение:**
```
✅ СОЗДАТЬ: AutoCompleteManager
📝 РЕФАКТОРИТЬ: CreateRecordViewModel, CalculatorViewModel
📝 УНИФИЦИРОВАТЬ: updateSuggestions логику
⏱️ ВРЕМЯ: 3 часа
```

**Пример архитектуры:**
```swift
class AutoCompleteManager<T: Searchable> {
    func updateSuggestions(for input: String, from items: [T]) -> [T] {
        // Единая логика поиска
    }
}
```

### 2.3 Упрощение SwiftData/Codable дублирования
**Проблема:** Параллельные модели данных

**Решение:**
```
✅ ДЕЙСТВИЕ: Создать единые базовые протоколы
📝 УПРОСТИТЬ: Backward compatibility computed properties
📝 ОБЪЕДИНИТЬ: Общие поля через протоколы
⏱️ ВРЕМЯ: 4 часа
```

---

## 📈 СРЕДНИЙ ПРИОРИТЕТ (Приоритет 3)

### 3.1 Унификация валидации
**Проблема:** Повторяющиеся isValid методы

**Решение:**
```
✅ СОЗДАТЬ: ValidationManager протокол
📝 РЕФАКТОРИТЬ: CreateRecordViewModel, CalculatorViewModel
📝 СТАНДАРТИЗИРОВАТЬ: Правила валидации
⏱️ ВРЕМЯ: 2 часа
```

### 3.2 Оптимизация Navigation
**Проблема:** Сложные NavigationLink цепочки

**Решение:**
```
✅ СОЗДАТЬ: NavigationCoordinator
📝 УПРОСТИТЬ: Переходы между экранами
📝 ЦЕНТРАЛИЗОВАТЬ: Роутинг логику
⏱️ ВРЕМЯ: 5 часов
```

### 3.3 Упрощение Generic ограничений
**Проблема:** Переусложненные типы в DevelopmentSetupViewModel

**Решение:**
```
✅ УПРОСТИТЬ: Generic ограничения до минимума
📝 УБРАТЬ: Ненужные associatedtype
📝 ИСПОЛЬЗОВАТЬ: Type erasure где необходимо
⏱️ ВРЕМЯ: 2 часа
```

---

## 🔧 ТЕХНИЧЕСКОЕ УЛУЧШЕНИЕ (Приоритет 4)

### 4.1 Оптимизация импортов
**Решение:**
```
✅ УБРАТЬ: Неиспользуемые import
📝 ОРГАНИЗОВАТЬ: Импорты по группам
📝 ИСПОЛЬЗОВАТЬ: @testable только в тестах
⏱️ ВРЕМЯ: 1 час
```

### 4.2 Consistency в naming
**Решение:**
```
✅ СТАНДАРТИЗИРОВАТЬ: Naming conventions
📝 ПРИВЕСТИ: К единому стилю переменных
📝 УПОРЯДОЧИТЬ: Методы по алфавиту в больших классах
⏱️ ВРЕМЯ: 2 часа
```

---

## 📊 ПЛАН РЕАЛИЗАЦИИ

### Фаза 1: Критические исправления (1 неделя)
- [x] Удаление неиспользуемого HomeView
- [x] Объединение констант
- [x] Удаление дублированного ParameterRow
- [x] Упрощение архитектуры сервисов
- [x] Удаление неиспользуемого NavigationButton

### Фаза 2: Унификация компонентов (1.5 недели)
- [ ] BasePickerView создание
- [ ] AutoCompleteManager реализация
- [ ] SwiftData/Codable оптимизация

### Фаза 3: Архитектурные улучшения (1 неделя)
- [ ] ValidationManager
- [ ] NavigationCoordinator
- [ ] Generic упрощения

### Фаза 4: Полировка (0.5 недели)
- [ ] Импорты и naming
- [ ] Финальное тестирование
- [ ] Документация обновления

**ОБЩЕЕ ВРЕМЯ:** ~4 недели
**ОЖИДАЕМОЕ СОКРАЩЕНИЕ КОДА:** 25-30%

---

## ⚠️ РИСКИ И ПРЕДОСТОРОЖНОСТИ

1. **Регрессии:** Тщательное тестирование после каждой фазы
2. **Breaking changes:** Версионирование при изменении public API
3. **Совместимость:** Сохранение критических интерфейсов
4. **Rollback план:** Git теги перед каждой крупной фазой

---

## 📋 ЧЕКЛИСТ КАЧЕСТВА

- [ ] Все тесты проходят
- [ ] Нет compiler warnings
- [ ] SwiftLint проверки пройдены
- [ ] Performance тесты в норме
- [ ] UI тесты работают
- [ ] Документация обновлена

---

*Этот план будет обновляться по мере реализации. Каждое завершение фазы помечается в чеклисте выше.*