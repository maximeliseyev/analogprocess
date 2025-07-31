//
//  ManualTypes.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 28.07.2025.
//

import SwiftUI

public enum ManualTypes: String, CaseIterable {
    case basics = "basics"
    case pushPull = "push-pull"
    case agitation = "agitation"
    case filmTypes = "film-types"
    case developers = "developers"
    case troubleshooting = "troubleshooting"
    
    var title: String {
        switch self {
        case .basics: return "Development Basics"
        case .pushPull: return "Push & Pull"
        case .agitation: return "Agitation Methods"
        case .filmTypes: return "Film Types"
        case .developers: return "Developers Guide"
        case .troubleshooting: return "Troubleshooting"
        }
    }
    
    var description: String {
        switch self {
        case .basics: return "Learn the fundamentals"
        case .pushPull: return "Advanced techniques"
        case .agitation: return "Different approaches"
        case .filmTypes: return "Understanding films"
        case .developers: return "Developer comparison"
        case .troubleshooting: return "Common issues"
        }
    }
    
    var iconName: String {
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
    
    var content: String {
        switch self {
        case .basics: return "Development basics content..."
        case .pushPull: return "Push and pull development content..."
        case .agitation: return "Agitation methods content..."
        case .filmTypes: return "Film types content..."
        case .developers: return "Developers guide content..."
        case .troubleshooting: return "Troubleshooting content..."
        }
    }
}

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