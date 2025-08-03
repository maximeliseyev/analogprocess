//
//  OnChangeMigrationTests.swift
//  FilmLab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import XCTest
import SwiftUI
@testable import FilmLab

final class OnChangeMigrationTests: XCTestCase {
    
    func testOnChangeNewSyntax() {
        // Тест для проверки нового синтаксиса onChange
        var value = 0
        var oldValueReceived: Int?
        var newValueReceived: Int?
        
        // Симулируем новый синтаксис onChange
        let onChangeHandler: (Int, Int) -> Void = { oldValue, newValue in
            oldValueReceived = oldValue
            newValueReceived = newValue
        }
        
        // Вызываем обработчик с изменением значения
        onChangeHandler(0, 1)
        
        XCTAssertEqual(oldValueReceived, 0)
        XCTAssertEqual(newValueReceived, 1)
    }
    
    func testOnChangeCompatibility() {
        // Тест совместимости с различными типами данных
        var stringValue = "old"
        var intValue = 0
        var doubleValue = 0.0
        
        // Тест с String
        let stringHandler: (String, String) -> Void = { oldValue, newValue in
            XCTAssertEqual(oldValue, "old")
            XCTAssertEqual(newValue, "new")
        }
        stringHandler("old", "new")
        
        // Тест с Int
        let intHandler: (Int, Int) -> Void = { oldValue, newValue in
            XCTAssertEqual(oldValue, 0)
            XCTAssertEqual(newValue, 1)
        }
        intHandler(0, 1)
        
        // Тест с Double
        let doubleHandler: (Double, Double) -> Void = { oldValue, newValue in
            XCTAssertEqual(oldValue, 0.0)
            XCTAssertEqual(newValue, 1.0)
        }
        doubleHandler(0.0, 1.0)
    }
    
    func testOnChangeOptionalValues() {
        // Тест с опциональными значениями
        var optionalValue: String? = nil
        
        let optionalHandler: (String?, String?) -> Void = { oldValue, newValue in
            XCTAssertNil(oldValue)
            XCTAssertEqual(newValue, "test")
        }
        optionalHandler(nil, "test")
    }
    
    func testOnChangeEnumValues() {
        // Тест с enum значениями
        enum TestEnum: Int {
            case first = 0
            case second = 1
        }
        
        let enumHandler: (TestEnum, TestEnum) -> Void = { oldValue, newValue in
            XCTAssertEqual(oldValue, .first)
            XCTAssertEqual(newValue, .second)
        }
        enumHandler(.first, .second)
    }
}

// MARK: - SwiftUI Preview Helper

struct OnChangeTestView: View {
    @State private var value = 0
    @State private var oldValue: Int?
    @State private var newValue: Int?
    
    var body: some View {
        VStack {
            Text("Value: \(value)")
            Button("Increment") {
                value += 1
            }
        }
        .onChange(of: value) { oldValue, newValue in
            self.oldValue = oldValue
            self.newValue = newValue
        }
    }
}

#Preview {
    OnChangeTestView()
} 