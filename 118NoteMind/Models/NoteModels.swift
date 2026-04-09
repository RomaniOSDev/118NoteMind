//
//  NoteModels.swift
//  118NoteMind
//

import Foundation
import SwiftUI

enum NoteCategory: String, CaseIterable, Codable {
    case personal = "Personal"
    case work = "Work"
    case study = "Study"
    case ideas = "Ideas"
    case todo = "Tasks"
    case journal = "Journal"
    case other = "Other"

    var icon: String {
        switch self {
        case .personal: return "person.fill"
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .ideas: return "lightbulb.fill"
        case .todo: return "checklist"
        case .journal: return "book.closed.fill"
        case .other: return "folder.fill"
        }
    }
}

enum NotePriority: Int, CaseIterable, Codable {
    case low = 1
    case medium = 2
    case high = 3

    var color: Color {
        switch self {
        case .low: return .noteSuccess.opacity(0.5)
        case .medium: return .noteAccent
        case .high: return .noteSuccess
        }
    }

    var icon: String {
        switch self {
        case .low: return "flag"
        case .medium: return "flag.fill"
        case .high: return "flag.fill"
        }
    }

    var title: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var category: NoteCategory
    var priority: NotePriority
    var tags: [String]
    var isCompleted: Bool
    var isFavorite: Bool
    var reminderDate: Date?
    var images: [String]?
    let createdAt: Date
    var updatedAt: Date

    var previewContent: String {
        let maxLength = 100
        if content.count > maxLength {
            return String(content.prefix(maxLength)) + "..."
        }
        return content
    }
}

struct Notebook: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var icon: String
    var noteIds: [UUID]
    var color: String?
    let createdAt: Date
}

struct Tag: Identifiable, Codable {
    let id: UUID
    var name: String
    var count: Int
    var color: String?
}

struct Reminder: Identifiable, Codable {
    let id: UUID
    let noteId: UUID
    let noteTitle: String
    let date: Date
    var isCompleted: Bool
}

struct SearchHistory: Identifiable, Codable {
    let id: UUID
    var query: String
    let date: Date
}

struct NoteStats {
    var totalNotes: Int
    var completedNotes: Int
    var favoriteNotes: Int
    var categoriesCount: [NoteCategory: Int]
    var tagsCount: [String: Int]
    var averageWords: Int
}
