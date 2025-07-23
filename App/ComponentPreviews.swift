//
//  ComponentPreviews.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData

// MARK: - Parameter Row Preview
struct ParameterRowPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            ParameterRow(
                label: "Film:",
                value: "Kodak Tri-X 400",
                onTap: { print("Film tapped") }
            )
            
            ParameterRow(
                label: "Developer:",
                value: "D-76",
                onTap: { print("Developer tapped") }
            )
            
            ParameterRow(
                label: "Dilution:",
                value: "1:1",
                onTap: { print("Dilution tapped") }
            )
            
            ParameterRow(
                label: "ISO/EI:",
                value: "400",
                onTap: { print("ISO tapped") }
            )
            
            ParameterRow(
                label: "Temperature (°C):",
                value: "20°C (Standard)",
                onTap: { print("Temperature tapped") }
            )
        }
        .padding()
        .background(Color.black)
    }
}



// MARK: - Record Row Preview
struct RecordRowPreview: View {
    @State private var records: [CalculationRecord] = []
    
    var body: some View {
        VStack(spacing: 20) {
            if let record = records.first {
                RecordRowView(
                    record: record,
                    onTap: { print("Record tapped") }
                )
            }
        }
        .padding()
        .onAppear {
            loadPreviewRecord()
        }
    }
    
    private func loadPreviewRecord() {
        let context = PersistenceController.preview.container.viewContext
        
        let record = CalculationRecord(context: context)
        record.filmName = "Kodak Tri-X 400"
        record.developerName = "D-76"
        record.dilution = "1:1"
        record.iso = 400
        record.temperature = 20.0
        record.time = 480
        record.date = Date()
        
        records = [record]
    }
}

// MARK: - Calculator Components Preview
struct CalculatorComponentsPreview: View {
    @State private var minutes = "8"
    @State private var seconds = "30"
    @State private var coefficient = "1.33"
    @State private var isPushMode = true
    @State private var pushSteps = 3
    
    var body: some View {
        VStack(spacing: 30) {
            // Time Input
            TimeInputView(minutes: $minutes, seconds: $seconds)
            
            // Coefficient Input
            CoefficientInputView(coefficient: $coefficient)
            
            // Process Type
            ProcessTypeView(isPushMode: $isPushMode)
            
            // Steps Input
            StepsInputView(pushSteps: $pushSteps, isPushMode: isPushMode)
            
            // Action Buttons
            ActionButtonsView(
                onCalculate: { print("Calculate tapped") },
                onSave: { print("Save tapped") },
                showSaveButton: true
            )
        }
        .padding()
    }
}

// MARK: - Preview Providers
struct ComponentPreviews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Parameter Row Components
            ParameterRowPreview()
                .previewDisplayName("Parameter Row")
            

            
            // Record Row
            RecordRowPreview()
                .previewDisplayName("Record Row")
            
            // Calculator Components
            CalculatorComponentsPreview()
                .previewDisplayName("Calculator Components")
        }
    }
}

 
