//
//  ManualView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 28.07.2025.
//

import SwiftUI

public struct ManualView: View {
    @StateObject private var viewModel = ManualViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedArticle: Article?
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey("manuals"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Articles and guides for film development")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Карточки с мануалами
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(viewModel.articles) { article in
                            ManualCard(article: article) {
                                selectedArticle = article
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadArticles()
        }
        .sheet(item: $selectedArticle) { article in
            ArticleView(article: article)
        }
    }
}

struct ManualCard: View {
    let article: Article
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: article.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(article.color)
                    .frame(width: 60, height: 60)
                    .background(article.color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(spacing: 4) {
                    Text(article.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(article.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

public struct ManualView_Previews: PreviewProvider {
    public static var previews: some View {
        ManualView()
    }
}
