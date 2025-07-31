//
//  ManualView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct ManualView: View {
    @StateObject private var viewModel = ManualViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(ManualTypes.allCases, id: \.self) { manualType in
                    NavigationLink(destination: ArticleView(manualType: manualType)) {
                        HStack {
                            Image(systemName: manualType.iconName)
                                .font(.title2)
                                .foregroundColor(manualType.color)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(manualType.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(manualType.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("manuals"))
            .navigationBarTitleDisplayMode(.large)
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
                        .pickerTitleStyle()
                        .multilineTextAlignment(.center)
                    
                    Text(article.subtitle)
                        .pickerSubtitleStyle()
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ManualCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Одиночная карточка
            ManualCard(
                article: Article(
                    title: "Development Basics",
                    subtitle: "Learn the fundamentals",
                    category: .basics,
                    filename: "basics.md",
                    icon: "book.fill",
                    color: .blue
                ),
                onTap: {}
            )
            .padding()
            .previewDisplayName("Single Card")
            
            // Сетка карточек
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ManualCard(
                    article: Article(
                        title: "Push & Pull",
                        subtitle: "Advanced techniques",
                        category: .pushPull,
                        filename: "push-pull.md",
                        icon: "arrow.up.arrow.down",
                        color: .orange
                    ),
                    onTap: {}
                )
                
                ManualCard(
                    article: Article(
                        title: "Agitation",
                        subtitle: "Different approaches",
                        category: .agitation,
                        filename: "agitation.md",
                        icon: "hand.raised.fill",
                        color: .green
                    ),
                    onTap: {}
                )
            }
            .padding()
            .previewDisplayName("Card Grid")
        }
    }
}

public struct ManualView_Previews: PreviewProvider {
    public static var previews: some View {
        Group {
            // Основной превью
            ManualView()
                .previewDisplayName("Manual View")
        }
    }
}

