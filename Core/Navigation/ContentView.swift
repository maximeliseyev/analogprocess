//
//  ContentView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showMainTabs = false
    @State private var selectedTab = 0
    
    var body: some View {
        if showMainTabs {
            MainTabView(selectedTab: $selectedTab)
        } else {
            HomeView(onSelectTab: { tab in
                selectedTab = tab
                showMainTabs = true
            })
        }
    }
}
