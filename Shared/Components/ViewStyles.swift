//
//  ViewStyles.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

// MARK: - Button Styles
extension View {
    /// Основной стиль кнопки с синим фоном и белым текстом
    /// Использование: Button("Текст") { }.primaryButtonStyle()
    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(minWidth: 80)
            .background(Color.blue)
            .cornerRadius(10)
    }
    
    /// Вторичный стиль кнопки с зеленым фоном и белым текстом
    /// Использование: Button("Текст") { }.secondaryButtonStyle()
    func secondaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(minWidth: 80)
            .background(Color.green)
            .cornerRadius(10)
    }
    
    /// Стиль для иконок в кнопках
    /// Использование: Image(systemName: "timer").iconButtonStyle()
    func iconButtonStyle() -> some View {
        self
            .font(.system(size: 16))
            .foregroundColor(.white)
    }
}

// MARK: - Card Styles
extension View {
    /// Основной стиль карточки с серым фоном
    /// Использование: VStack { }.cardStyle()
    func cardStyle() -> some View {
        self
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
    
    /// Стиль карточки для параметров с более темным фоном
    /// Использование: HStack { }.parameterCardStyle()
    func parameterCardStyle() -> some View {
        self
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
    }
    
    /// Стиль карточки для picker'ов
    /// Использование: HStack { }.pickerCardStyle()
    func pickerCardStyle() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.05))
    }
}

// MARK: - Text Styles
extension View {
    /// Стиль заголовка с белым текстом (для темных фонов)
    /// Использование: Text("Заголовок").headlineTextStyle()
    func headlineTextStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
    }
    
    /// Стиль основного текста с белым цветом (для темных фонов)
    /// Использование: Text("Текст").bodyTextStyle()
    func bodyTextStyle() -> some View {
        self
            .font(.body)
            .foregroundColor(.white)
    }
    
    /// Стиль подписи с серым текстом
    /// Использование: Text("Подпись").captionTextStyle()
    func captionTextStyle() -> some View {
        self
            .font(.caption)
            .foregroundColor(.gray)
    }
    
    /// Стиль моноширинного текста для основного контента
    /// Использование: Text("123").monospacedBodyStyle()
    func monospacedBodyStyle() -> some View {
        self
            .font(.system(.body, design: .monospaced))
            .fontWeight(.medium)
    }
    
    /// Стиль моноширинного заголовка
    /// Использование: Text("123").monospacedTitleStyle()
    func monospacedTitleStyle() -> some View {
        self
            .font(.system(.title3, design: .monospaced))
            .fontWeight(.bold)
    }
    
    /// Стиль заголовка для picker'ов
    /// Использование: Text("Заголовок").pickerTitleStyle()
    func pickerTitleStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.primary)
    }
    
    /// Стиль подписи для picker'ов
    /// Использование: Text("Подпись").pickerSubtitleStyle()
    func pickerSubtitleStyle() -> some View {
        self
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

// MARK: - Layout Styles
extension View {
    /// Стандартные горизонтальные отступы
    /// Использование: VStack { }.standardPadding()
    func standardPadding() -> some View {
        self
            .padding(.horizontal)
    }
    
    /// Вертикальные отступы с настраиваемым размером
    /// Использование: VStack { }.verticalSpacing(16)
    func verticalSpacing(_ spacing: CGFloat = 12) -> some View {
        self
            .padding(.vertical, spacing)
    }
    
    /// Горизонтальные отступы с настраиваемым размером
    /// Использование: HStack { }.horizontalSpacing(20)
    func horizontalSpacing(_ spacing: CGFloat = 16) -> some View {
        self
            .padding(.horizontal, spacing)
    }
}

// MARK: - Interactive Styles
extension View {
    /// Стиль галочки для выбранных элементов
    /// Использование: Image(systemName: "checkmark").checkmarkStyle()
    func checkmarkStyle() -> some View {
        self
            .foregroundColor(.blue)
            .font(.system(size: 16, weight: .medium))
    }
    
    /// Стиль стрелки для навигации
    /// Использование: Image(systemName: "chevron.down").chevronStyle()
    func chevronStyle() -> some View {
        self
            .foregroundColor(.gray)
            .font(.caption)
    }
    
    /// Стиль информационной иконки
    /// Использование: Image(systemName: "info.circle").infoIconStyle()
    func infoIconStyle() -> some View {
        self
            .font(.largeTitle)
            .foregroundColor(.blue)
    }
    
    /// Стиль предупреждающей иконки
    /// Использование: Image(systemName: "exclamationmark.triangle").warningIconStyle()
    func warningIconStyle() -> some View {
        self
            .font(.largeTitle)
            .foregroundColor(.orange)
    }
    
    /// Стиль отключенного текста
    /// Использование: Text("Текст").disabledTextStyle()
    func disabledTextStyle() -> some View {
        self
            .font(.body)
            .foregroundColor(.secondary)
    }
    
    /// Стиль основного текста
    /// Использование: Text("Текст").primaryTextStyle()
    func primaryTextStyle() -> some View {
        self
            .font(.body)
            .foregroundColor(.primary)
    }
}
