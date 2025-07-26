//
//  DevelopmentHeaderView.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct DevelopmentHeaderView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text(LocalizedStringKey("developmentSetup"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(LocalizedStringKey("developmentSetupDescription"))
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
}

struct DevelopmentHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            DevelopmentHeaderView()
        }
    }
} 