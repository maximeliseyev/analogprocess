//
//  StagingCalculationResultView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct StagingCalculationResultView: View {
    let results: [ProcessStep]
    @ObservedObject var viewModel: CalculatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            // Отступ от верхнего индикатора перетаскивания шита
            Spacer().frame(height: 8)
            
            Text(LocalizedStringKey("results"))
                .font(.headline)
                .padding(.top, 4)
            
            // Информация о температурном коэффициенте
            let temperatureMultiplier = viewModel.getTemperatureMultiplier()
            if temperatureMultiplier != 1.0 {
                Text("Температурный коэффициент: ×\(String(format: "%.2f", temperatureMultiplier))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    let base = results.first
                    let calculated = results.last
                    
                    if let base = base {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("+0")
                                    .monospacedBodyStyle()
                                Text(base.formattedTime)
                                    .monospacedTitleStyle()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                saveCalculatedTime(result: base)
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text(LocalizedStringKey("save"))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                        }
                        .cardStyle()
                    }
                    
                    if let calculated = calculated, base?.id != calculated.id {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(calculated.label)
                                    .monospacedBodyStyle()
                                Text(calculated.formattedTime)
                                    .monospacedTitleStyle()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                saveCalculatedTime(result: calculated)
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text(LocalizedStringKey("save"))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                        }
                        .cardStyle()
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .presentationDetents([.fraction(0.4)])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Private Methods
    
    private func saveCalculatedTime(result: ProcessStep) {
        let totalSeconds = result.minutes * 60 + result.seconds
        
        // Отправляем уведомление с рассчитанным временем
        NotificationCenter.default.post(
            name: Notification.Name("DevelopmentCalculatedTime"),
            object: nil,
            userInfo: ["seconds": totalSeconds]
        )
        
        // Закрываем sheet и возвращаемся на экран настройки Develop stage
        dismiss()
        
        // Дополнительно закрываем калькулятор, чтобы вернуться к DevelopmentSetupView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(
                name: Notification.Name("DismissCalculatorView"),
                object: nil
            )
        }
    }
}

// MARK: - Preview
struct StagingCalculationResultView_Previews: PreviewProvider {
    static var previews: some View {
        let mockResults = [
            ProcessStep(
                label: "+0",
                minutes: 8,
                seconds: 30
            ),
            ProcessStep(
                label: "+1",
                minutes: 11,
                seconds: 20
            )
        ]
        
        StagingCalculationResultView(
            results: mockResults,
            viewModel: CalculatorViewModel(swiftDataService: SwiftDataService(githubDataService: GitHubDataService(), modelContainer: SwiftDataPersistence.preview.modelContainer))
        )
        .previewDisplayName("Staging Calculation Result")
    }
}
