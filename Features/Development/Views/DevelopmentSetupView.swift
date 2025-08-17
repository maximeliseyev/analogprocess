//
//  SwiftDataDevelopmentSetupView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

struct DevelopmentSetupView: View {
    @StateObject private var viewModel: DevelopmentSetupViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Параметры для определения режима открытия
    let isFromStageEditor: Bool
    let stageType: StageType?
    
    init(isFromStageEditor: Bool = false, stageType: StageType? = nil, viewModel: DevelopmentSetupViewModel? = nil) {
        self.isFromStageEditor = isFromStageEditor
        self.stageType = stageType
        
        // Используем переданный ViewModel или создаем новый
        if let existingViewModel = viewModel {
            self._viewModel = StateObject(wrappedValue: existingViewModel)
        } else {
            self._viewModel = StateObject(wrappedValue: DevelopmentSetupViewModel())
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Mode Selection Picker - скрываем в режиме редактора стадии
                    if !isFromStageEditor {
                        Picker("Process Mode", selection: $viewModel.selectedMode) {
                            ForEach(ProcessMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                        .onChange(of: viewModel.selectedMode) { _, newMode in
                            viewModel.updateMode(newMode)
                        }
                    }
                    
                    DevelopmentParametersView(viewModel: viewModel)
                    
                    if let calculatedTime = viewModel.calculatedTime {
                        if isFromStageEditor {
                            // В режиме редактора стадии показываем только кнопку калькулятора
                            VStack(spacing: 16) {
                                Button(action: {
                                    NotificationCenter.default.post(
                                        name: Notification.Name("DevelopmentCalculatedTime"),
                                        object: nil,
                                        userInfo: ["seconds": calculatedTime]
                                    )
                                    viewModel.navigateToCalculator = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.forwardslash.minus")
                                            .font(.system(size: 18, design: .monospaced))
                                        Text("\(calculatedTime / 60):\(String(format: "%02d", calculatedTime % 60))")
                                            .font(.system(size: 18, design: .monospaced))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .background(.orange)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        } else {
                            // Обычный режим - показываем обе кнопки
                            CalculatedTimeSection(
                                time: calculatedTime,
                                temperature: viewModel.temperature,
                                filmName: viewModel.selectedFilmName,
                                developerName: viewModel.selectedMode == .developing ? viewModel.selectedDeveloperName : "Fixer",
                                onCalculatorTap: {
                                    NotificationCenter.default.post(
                                        name: Notification.Name("DevelopmentCalculatedTime"),
                                        object: nil,
                                        userInfo: ["seconds": calculatedTime]
                                    )
                                    viewModel.navigateToCalculator = true
                                },
                                onTimerTap: {
                                    NotificationCenter.default.post(
                                        name: Notification.Name("DevelopmentCalculatedTime"),
                                        object: nil,
                                        userInfo: ["seconds": calculatedTime]
                                    )
                                    viewModel.navigateToTimer = true
                                }
                            )
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $viewModel.showFilmPicker) {
            FilmPickerView(
                films: viewModel.films,
                selectedFilm: $viewModel.selectedFilm,
                iso: $viewModel.iso,
                onDismiss: { viewModel.showFilmPicker = false },
                onFilmSelected: { film in
                    viewModel.selectFilm(film)
                }
            )
        }
        .sheet(isPresented: $viewModel.showDeveloperPicker) {
            DeveloperPickerView(
                developers: viewModel.developers,
                selectedDeveloper: $viewModel.selectedDeveloper,
                selectedDilution: $viewModel.selectedDilution,
                onDismiss: { viewModel.showDeveloperPicker = false },
                onDeveloperSelected: { developer in
                    viewModel.selectDeveloper(developer)
                }
            )
        }
        .sheet(isPresented: $viewModel.showDilutionPicker) {
            DilutionPickerView(
                dilutions: viewModel.getAvailableDilutions(),
                selectedDilution: $viewModel.selectedDilution,
                onDismiss: { viewModel.showDilutionPicker = false },
                isDisabled: viewModel.selectedFilm == nil || viewModel.selectedDeveloper == nil,
                onDilutionSelected: { dilution in
                    viewModel.selectDilution(dilution)
                }
            )
        }
        .sheet(isPresented: $viewModel.showFixerPicker) {
            FixerPickerView(
                swiftDataFixers: viewModel.fixers,
                selectedSwiftDataFixer: $viewModel.selectedFixer,
                onDismiss: { viewModel.showFixerPicker = false },
                onSwiftDataFixerSelected: { fixer in
                    viewModel.selectFixer(fixer)
                }
            )
        }
        .sheet(isPresented: $viewModel.showISOPicker) {
            ISOPickerView(
                iso: $viewModel.iso,
                onDismiss: { viewModel.showISOPicker = false },
                availableISOs: viewModel.getAvailableISOs()
            )
        }
        .navigationDestination(isPresented: $viewModel.navigateToCalculator) {
            if let calculatedTime = viewModel.calculatedTime {
                CalculatorView(
                    initialTime: calculatedTime, 
                    initialTemperature: viewModel.temperature,
                    isFromStageEditor: isFromStageEditor
                )
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToTimer) {
            if let calculatedTime = viewModel.calculatedTime {
                let minutes = calculatedTime / 60
                let seconds = calculatedTime % 60
                let timerLabel = "\(viewModel.selectedFilmName) / \(viewModel.selectedDeveloperName)"
                
                TimerView(
                    timerLabel: timerLabel,
                    totalMinutes: minutes,
                    totalSeconds: seconds
                )
            }
        }
        .navigationTitle(LocalizedStringKey("developmentSetup"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isFromStageEditor {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("save")) {
                        if let calculatedTime = viewModel.calculatedTime {
                            NotificationCenter.default.post(
                                name: Notification.Name("DevelopmentCalculatedTime"),
                                object: nil,
                                userInfo: ["seconds": calculatedTime]
                            )
                        }
                        dismiss()
                    }
                    .disabled(viewModel.calculatedTime == nil)
                }
            }
        }
        .onAppear {
            viewModel.reloadData()
            
            // Устанавливаем правильный режим при открытии из редактора стадии
            if isFromStageEditor, let stageType = stageType {
                switch stageType {
                case .fixer:
                    viewModel.selectedMode = .fixer
                case .develop:
                    viewModel.selectedMode = .developing
                default:
                    break
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DismissCalculatorView"))) { _ in
            // Закрываем калькулятор и возвращаемся к DevelopmentSetupView
            viewModel.navigateToCalculator = false
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DismissDevelopmentSetupView"))) { _ in
            // Закрываем DevelopmentSetupView и возвращаемся к StageEditorSheet
            if isFromStageEditor {
                dismiss()
            }
        }
    }
}

struct DevelopmentSetupView_Previews: PreviewProvider {
    static var previews: some View {
        DevelopmentSetupView()
    }
}
