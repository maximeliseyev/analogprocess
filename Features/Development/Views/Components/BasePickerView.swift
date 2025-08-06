//
//  BasePickerView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import UIKit

protocol BasePickerItem: Hashable {
    var displayTitle: String { get }
    var isAvailable: Bool { get }
}

struct BasePickerView<T: BasePickerItem>: View {
    @Binding var selectedValue: T
    let items: [T]
    let title: LocalizedStringKey
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                Group {
                    if items.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "info.circle")
                                .infoIconStyle()
                            
                            Text(LocalizedStringKey("noOptionsAvailable"))
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(LocalizedStringKey("noOptionsDescription"))
                                .disabledTextStyle()
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        List(items, id: \.self) { item in
                            Button(action: {
                                if item.isAvailable {
                                    selectedValue = item
                                    onDismiss()
                                }
                            }) {
                                HStack {
                                    Text(item.displayTitle)
                                        .primaryTextStyle()
                                        .foregroundColor(item.isAvailable ? .primary : .secondary)
                                    
                                    Spacer()
                                    
                                    if selectedValue == item {
                                        Image(systemName: "checkmark")
                                            .checkmarkStyle()
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(!item.isAvailable)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(LocalizedStringKey("cancel")) {
                        onDismiss()
                    }
                }
            }
        }
    }
}

// MARK: - ISO Specific Implementation

struct ISOItem: BasePickerItem {
    let value: Int
    let isAvailable: Bool
    
    var displayTitle: String {
        String(format: String(localized: "isoLabel"), "\(value)")
    }
    
    static func == (lhs: ISOItem, rhs: ISOItem) -> Bool {
        lhs.value == rhs.value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

// MARK: - Preview

struct BasePickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BasePickerView(
                selectedValue: .constant(ISOItem(value: 400, isAvailable: true)),
                items: [
                    ISOItem(value: 100, isAvailable: true),
                    ISOItem(value: 200, isAvailable: true),
                    ISOItem(value: 400, isAvailable: true),
                    ISOItem(value: 800, isAvailable: true)
                ],
                title: LocalizedStringKey("selectISO"),
                onDismiss: {}
            )
            
            BasePickerView(
                selectedValue: .constant(ISOItem(value: 400, isAvailable: true)),
                items: [],
                title: LocalizedStringKey("selectISO"),
                onDismiss: {}
            )
        }
    }
} 