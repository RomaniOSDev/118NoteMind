//
//  NoteMindViewModel.swift
//  118NoteMind
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class NoteMindViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var notebooks: [Notebook] = []

    @Published var searchText: String = ""
    @Published var selectedFilter: FilterType?
    @Published var selectedCategory: NoteCategory?
    @Published var selectedTag: String?

    enum FilterType {
        case active, completed, favorites
    }

    var totalNotes: Int { notes.count }

    var completedNotes: Int {
        notes.filter(\.isCompleted).count
    }

    var favoriteNotes: Int {
        notes.filter(\.isFavorite).count
    }

    var upcomingReminders: Int {
        notes.filter {
            guard let date = $0.reminderDate, !$0.isCompleted else { return false }
            return date > Date()
        }.count
    }

    var averageWords: Int {
        guard !notes.isEmpty else { return 0 }
        let totalWords = notes.reduce(0) { $0 + $1.content.split(separator: " ").count }
        return totalWords / notes.count
    }

    var filteredNotes: [Note] {
        var result = notes

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                    || $0.content.localizedCaseInsensitiveContains(searchText)
                    || $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        switch selectedFilter {
        case .active:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter(\.isCompleted)
        case .favorites:
            result = result.filter(\.isFavorite)
        case nil:
            break
        }

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) }
        }

        return result.sorted { $0.updatedAt > $1.updatedAt }
    }

    var allTags: [String] {
        Array(Set(notes.flatMap(\.tags))).sorted()
    }

    var popularTags: [String] {
        let tagCounts = Dictionary(grouping: notes.flatMap(\.tags), by: { $0 })
            .mapValues(\.count)
        return tagCounts.sorted { $0.value > $1.value }.map(\.key)
    }

    struct WeeklyActivity: Identifiable {
        let id: String
        let day: String
        let count: Int
    }

    var weeklyActivity: [WeeklyActivity] {
        let calendar = Calendar.current
        let today = Date()
        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }.reversed()

        return weekDays.map { date in
            let count = notes.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }.count
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "E"
            dayFormatter.locale = Locale(identifier: "en_US")
            let idFormatter = DateFormatter()
            idFormatter.dateFormat = "yyyy-MM-dd"
            idFormatter.locale = Locale(identifier: "en_US_POSIX")
            return WeeklyActivity(
                id: idFormatter.string(from: date),
                day: dayFormatter.string(from: date),
                count: count
            )
        }
    }

    struct CategoryDistribution: Identifiable {
        let id: String
        let name: String
        let icon: String
        let count: Int
        let percentage: Double
    }

    var categoryDistribution: [CategoryDistribution] {
        let grouped = Dictionary(grouping: notes, by: \.category)
        let total = Double(totalNotes)

        return grouped.map { category, list in
            CategoryDistribution(
                id: category.rawValue,
                name: category.rawValue,
                icon: category.icon,
                count: list.count,
                percentage: total > 0 ? Double(list.count) / total * 100 : 0
            )
        }
        .sorted { $0.count > $1.count }
    }

    func notesCount(for category: NoteCategory) -> Int {
        notes.filter { $0.category == category }.count
    }

    func completedCount(for category: NoteCategory) -> Int {
        notes.filter { $0.category == category && $0.isCompleted }.count
    }

    func tagCount(_ tag: String) -> Int {
        notes.filter { $0.tags.contains(tag) }.count
    }

    func note(by id: UUID) -> Note? {
        notes.first { $0.id == id }
    }

    func notes(forNotebook notebook: Notebook) -> [Note] {
        let idSet = Set(notebook.noteIds)
        return notes.filter { idSet.contains($0.id) }.sorted { $0.updatedAt > $1.updatedAt }
    }

    var homeRecentNotes: [Note] {
        Array(notes.sorted { $0.updatedAt > $1.updatedAt }.prefix(6))
    }

    var homeFavoriteNotes: [Note] {
        Array(notes.filter(\.isFavorite).sorted { $0.updatedAt > $1.updatedAt }.prefix(10))
    }

    var homeUpcomingReminders: [Note] {
        notes
            .filter {
                guard let d = $0.reminderDate, !$0.isCompleted else { return false }
                return d > Date()
            }
            .sorted {
                ($0.reminderDate ?? .distantFuture) < ($1.reminderDate ?? .distantFuture)
            }
    }

    var homeCompletionProgress: Double {
        guard totalNotes > 0 else { return 0 }
        return Double(completedNotes) / Double(totalNotes)
    }

    var homeActiveNotesCount: Int {
        notes.filter { !$0.isCompleted }.count
    }

    func resetNotesFiltersToShowAll() {
        selectedFilter = nil
        selectedCategory = nil
        selectedTag = nil
        searchText = ""
    }

    func applyCategoryFilterForNotes(_ category: NoteCategory) {
        selectedFilter = nil
        selectedTag = nil
        selectedCategory = category
    }

    func addNote(_ note: Note) {
        notes.append(note)
        if let reminderDate = note.reminderDate {
            scheduleNotification(for: note, at: reminderDate)
        }
        saveToUserDefaults()
    }

    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            let oldNote = notes[index]
            if oldNote.reminderDate != note.reminderDate {
                cancelNotification(for: oldNote)
                if let newReminder = note.reminderDate {
                    scheduleNotification(for: note, at: newReminder)
                }
            }
            notes[index] = note
            saveToUserDefaults()
        }
    }

    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        for i in notebooks.indices {
            notebooks[i].noteIds.removeAll { $0 == note.id }
        }
        cancelNotification(for: note)
        saveToUserDefaults()
    }

    func toggleCompleted(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isCompleted.toggle()
            notes[index].updatedAt = Date()
            saveToUserDefaults()
        }
    }

    func toggleFavorite(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isFavorite.toggle()
            notes[index].updatedAt = Date()
            saveToUserDefaults()
        }
    }

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func addNotebook(_ notebook: Notebook) {
        notebooks.append(notebook)
        saveToUserDefaults()
    }

    func deleteNotebook(_ notebook: Notebook) {
        notebooks.removeAll { $0.id == notebook.id }
        saveToUserDefaults()
    }

    func updateNotebook(_ notebook: Notebook) {
        if let index = notebooks.firstIndex(where: { $0.id == notebook.id }) {
            notebooks[index] = notebook
            saveToUserDefaults()
        }
    }

    func attachNote(_ note: Note, to notebook: Notebook) {
        guard let index = notebooks.firstIndex(where: { $0.id == notebook.id }) else { return }
        if !notebooks[index].noteIds.contains(note.id) {
            notebooks[index].noteIds.append(note.id)
            saveToUserDefaults()
        }
    }

    private func scheduleNotification(for note: Note, at date: Date) {
        guard date > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = note.title
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: note.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification(for note: Note) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [note.id.uuidString])
    }

    private let notesKey = "notemind_notes"
    private let notebooksKey = "notemind_notebooks"

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
        if let encoded = try? JSONEncoder().encode(notebooks) {
            UserDefaults.standard.set(encoded, forKey: notebooksKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }

        if let data = UserDefaults.standard.data(forKey: notebooksKey),
           let decoded = try? JSONDecoder().decode([Notebook].self, from: data) {
            notebooks = decoded
        }

        if notes.isEmpty {
            loadDemoData()
        }
    }

    private func loadDemoData() {
        let note1 = Note(
            id: UUID(),
            title: "Team meeting",
            content: "Discuss the new project at 3:00 PM. Prepare the presentation.",
            category: .work,
            priority: .high,
            tags: ["work", "meeting"],
            isCompleted: false,
            isFavorite: true,
            reminderDate: Date().addingTimeInterval(3600),
            images: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        let note2 = Note(
            id: UUID(),
            title: "Groceries",
            content: "Milk, bread, eggs, vegetables, fruit",
            category: .personal,
            priority: .medium,
            tags: ["shopping", "home"],
            isCompleted: true,
            isFavorite: false,
            reminderDate: nil,
            images: nil,
            createdAt: Date().addingTimeInterval(-86400),
            updatedAt: Date().addingTimeInterval(-86400)
        )

        let note3 = Note(
            id: UUID(),
            title: "App idea",
            content: "Build a notes app with tags and categories",
            category: .ideas,
            priority: .low,
            tags: ["idea", "dev"],
            isCompleted: false,
            isFavorite: true,
            reminderDate: nil,
            images: nil,
            createdAt: Date().addingTimeInterval(-172800),
            updatedAt: Date().addingTimeInterval(-172800)
        )

        notes = [note1, note2, note3]

        let notebook = Notebook(
            id: UUID(),
            name: "Work notes",
            icon: "briefcase.fill",
            noteIds: [note1.id],
            color: nil,
            createdAt: Date()
        )

        notebooks = [notebook]
        saveToUserDefaults()
    }
}
