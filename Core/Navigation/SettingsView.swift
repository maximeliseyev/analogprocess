import SwiftUI
import CoreData

public struct SettingsView: View {
    @Binding var colorScheme: ColorScheme?
    @State private var selectedTheme: Int = 0
    @State private var showingDataAlert = false
    @State private var alertMessage = ""
    
    public init(colorScheme: Binding<ColorScheme?>) {
        self._colorScheme = colorScheme
    }
    
    public var body: some View {
        Form {
            Section(header: Text(LocalizedStringKey("settings_theme"))) {
                Picker(selection: $selectedTheme, label: Text(LocalizedStringKey("settings_theme_mode"))) {
                    Text(LocalizedStringKey("settings_theme_system")).tag(0)
                    Text(LocalizedStringKey("settings_theme_light")).tag(1)
                    Text(LocalizedStringKey("settings_theme_dark")).tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedTheme) { newValue in
                    switch newValue {
                    case 1: colorScheme = .light
                    case 2: colorScheme = .dark
                    default: colorScheme = nil
                    }
                }
            }
        }
        .navigationTitle(LocalizedStringKey("settings"))
        .onAppear {
            if colorScheme == .light { selectedTheme = 1 }
            else if colorScheme == .dark { selectedTheme = 2 }
            else { selectedTheme = 0 }
        }
    }
} 
