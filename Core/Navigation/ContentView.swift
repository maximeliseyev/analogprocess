//
//  ContentView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct ContentView: View {
    @Binding var colorScheme: ColorScheme?
    @State private var showMainTabs = false
    @State private var selectedTab = 0
    
    var body: some View {
        if showMainTabs {
            MainTabView(
                selectedTab: $selectedTab,
                onBackToHome: {
                    showMainTabs = false
                },
                colorScheme: $colorScheme
            )
        } else {
            HomeView(
                onSelectTab: { tab in
                    selectedTab = tab
                    showMainTabs = true
                },
                colorScheme: $colorScheme
            )
        }
    }
}
