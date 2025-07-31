//
//  ArticleView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct ArticleView: View {
    let manualType: ManualTypes
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(manualType.content)
                        .font(.body)
                        .lineSpacing(6)
                        .padding()
                }
            }
            .navigationTitle(manualType.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MarkdownTextView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(parseMarkdown(text), id: \.id) { element in
                switch element.type {
                case .heading1:
                    Text(element.text)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                case .heading2:
                    Text(element.text)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                case .heading3:
                    Text(element.text)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                case .paragraph:
                    Text(element.text)
                        .primaryTextStyle()
                case .listItem:
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .captionTextStyle()
                        Text(element.text)
                            .primaryTextStyle()
                    }
                case .bold:
                    Text(element.text)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private func parseMarkdown(_ text: String) -> [MarkdownElement] {
        var elements: [MarkdownElement] = []
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty { continue }
            
            if trimmedLine.hasPrefix("# ") {
                elements.append(MarkdownElement(type: .heading1, text: String(trimmedLine.dropFirst(2))))
            } else if trimmedLine.hasPrefix("## ") {
                elements.append(MarkdownElement(type: .heading2, text: String(trimmedLine.dropFirst(3))))
            } else if trimmedLine.hasPrefix("### ") {
                elements.append(MarkdownElement(type: .heading3, text: String(trimmedLine.dropFirst(4))))
            } else if trimmedLine.hasPrefix("- ") || trimmedLine.hasPrefix("* ") {
                elements.append(MarkdownElement(type: .listItem, text: String(trimmedLine.dropFirst(2))))
            } else if trimmedLine.contains("**") {
                // Простая обработка жирного текста
                let boldText = trimmedLine.replacingOccurrences(of: "**", with: "")
                elements.append(MarkdownElement(type: .bold, text: boldText))
            } else {
                elements.append(MarkdownElement(type: .paragraph, text: trimmedLine))
            }
        }
        
        return elements
    }
}

struct MarkdownElement {
    let id = UUID()
    let type: MarkdownElementType
    let text: String
}

enum MarkdownElementType {
    case heading1
    case heading2
    case heading3
    case paragraph
    case listItem
    case bold
}

struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ArticleView(manualType: .basics)
                .previewDisplayName("Article View")
            
            ArticleView(manualType: .pushPull)
                .previewDisplayName("Article View - Push Pull")
        }
    }
} 