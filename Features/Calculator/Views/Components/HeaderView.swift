//
//  HeaderView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct HeaderView: View {
    let onJournalTap: () -> Void
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey("calculator"))
                .font(.title3)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(LocalizedStringKey("journal")) {
                onJournalTap()
            }
            .foregroundColor(.blue)
        }
        .padding(.top)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(onJournalTap: {})
            .padding()
    }
} 