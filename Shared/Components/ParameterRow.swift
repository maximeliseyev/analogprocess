//
//  ParameterRow.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct ParameterRow: View {
    let label: String
    let value: String
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .headlineTextStyle()
            
            Button(action: onTap) {
                HStack {
                    Text(value)
                        .bodyTextStyle()
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .chevronStyle()
                }
                .parameterCardStyle()
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct ParameterRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                ParameterRow(
                    label: "Film:",
                    value: "Kodak Tri-X 400",
                    onTap: {}
                )
                
                ParameterRow(
                    label: "Developer:",
                    value: "D-76",
                    onTap: {}
                )
                
                ParameterRow(
                    label: "Dilution:",
                    value: "1:1",
                    onTap: {}
                )
            }
            .padding()
        }
    }
} 