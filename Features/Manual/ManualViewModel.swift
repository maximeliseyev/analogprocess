//
//  ManualViewModel.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 28.07.2025.
//


import SwiftUI
import CoreData
import Combine

@MainActor
public class ManualViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var articles: [Article] = []
    @Published var selectedArticle: Article?
    @Published var articleContent: String = ""
    
    // MARK: - Dependencies
    // private let coreDataService = CoreDataService.shared
    
    // MARK: - Methods
    
    func loadArticles() {
        articles = ArticleCategory.allCases.map { category in
            Article(
                title: category.displayName,
                subtitle: category.subtitle,
                category: category,
                filename: "\(category.rawValue)-article.md",
                icon: category.icon,
                color: category.color
            )
        }
    }
    
    func loadArticleContent(for article: Article) {
        guard let path = Bundle.main.path(forResource: article.filename.replacingOccurrences(of: ".md", with: ""), 
                                        ofType: "md", 
                                        inDirectory: "Resources/Articles/\(article.category.rawValue)") else {
            articleContent = "Article not found"
            return
        }
        
        do {
            articleContent = try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            articleContent = "Error loading article: \(error.localizedDescription)"
        }
    }
}
