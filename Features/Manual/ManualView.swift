//
//  ManualView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 28.07.2025.
//

import SwiftUI

public struct ManualView: View {
    @StateObject private var viewModel = ManualViewModel()
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Manuals comming soon...")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .padding()
            .navigationTitle("Manuals")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
}
