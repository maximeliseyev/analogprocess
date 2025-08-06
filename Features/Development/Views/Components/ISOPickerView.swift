//
//  ISOPickerView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct ISOPickerView: View {
    @Binding var iso: Int32
    let onDismiss: () -> Void
    let availableISOs: [Int]
    
    private let allISOs = [25, 32, 40, 50, 64, 80, 100, 125, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 2000, 2500, 3200, 4000, 5000, 6400, 8000, 12800]
    
    private var items: [ISOItem] {
        allISOs.map { isoValue in
            ISOItem(value: isoValue, isAvailable: availableISOs.contains(isoValue))
        }
    }
    
    private var selectedItem: ISOItem {
        ISOItem(value: Int(iso), isAvailable: true)
    }
    
    var body: some View {
        BasePickerView(
            selectedValue: Binding(
                get: { selectedItem },
                set: { iso = Int32($0.value) }
            ),
            items: items,
            title: LocalizedStringKey("selectISO"),
            onDismiss: onDismiss
        )
    }
}

struct ISOPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ISOPickerView(
                iso: .constant(400),
                onDismiss: {},
                availableISOs: [100, 200, 400, 800]
            )
            
            ISOPickerView(
                iso: .constant(400),
                onDismiss: {},
                availableISOs: []
            )
        }
    }
} 
