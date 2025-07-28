//
//  ManualViewModel.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 28.07.2025.
//


import SwiftUI
import CoreData
import Combine

public struct Article: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let category: ArticleCategory
    public let filename: String
    public let icon: String
    public let color: Color
    
    public init(title: String, subtitle: String, category: ArticleCategory, filename: String, icon: String, color: Color) {
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.filename = filename
        self.icon = icon
        self.color = color
    }
}

public enum ArticleCategory: String, CaseIterable {
    case basics = "basics"
    case pushPull = "push-pull"
    case agitation = "agitation"
    case filmTypes = "film-types"
    case developers = "developers"
    case troubleshooting = "troubleshooting"
    
    var displayName: String {
        switch self {
        case .basics: return "Development Basics"
        case .pushPull: return "Push & Pull"
        case .agitation: return "Agitation Methods"
        case .filmTypes: return "Film Types"
        case .developers: return "Developers Guide"
        case .troubleshooting: return "Troubleshooting"
        }
    }
    
    var subtitle: String {
        switch self {
        case .basics: return "Learn the fundamentals"
        case .pushPull: return "Advanced techniques"
        case .agitation: return "Different approaches"
        case .filmTypes: return "Understanding films"
        case .developers: return "Developer comparison"
        case .troubleshooting: return "Common issues"
        }
    }
    
    var icon: String {
        switch self {
        case .basics: return "book.fill"
        case .pushPull: return "arrow.up.arrow.down"
        case .agitation: return "hand.raised.fill"
        case .filmTypes: return "camera.fill"
        case .developers: return "drop.fill"
        case .troubleshooting: return "wrench.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .basics: return .blue
        case .pushPull: return .orange
        case .agitation: return .green
        case .filmTypes: return .purple
        case .developers: return .red
        case .troubleshooting: return .yellow
        }
    }
}

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
