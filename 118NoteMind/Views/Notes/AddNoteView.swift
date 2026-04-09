//
//  AddNoteView.swift
//  118NoteMind
//

import SwiftUI

struct AddNoteView: View {
    @ObservedObject var viewModel: NoteMindViewModel
    private let editing: Note?
    private let notebook: Notebook?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var content: String
    @State private var category: NoteCategory
    @State private var priority: NotePriority
    @State private var tagsString: String
    @State private var hasReminder: Bool
    @State private var reminderDate: Date
    @State private var isCompleted: Bool
    @State private var isFavorite: Bool

    init(viewModel: NoteMindViewModel, editing: Note? = nil, notebook: Notebook? = nil) {
        self.viewModel = viewModel
        self.editing = editing
        self.notebook = notebook
        let note = editing
        _title = State(initialValue: note?.title ?? "")
        _content = State(initialValue: note?.content ?? "")
        _category = State(initialValue: note?.category ?? .personal)
        _priority = State(initialValue: note?.priority ?? .medium)
        _tagsString = State(initialValue: note.map { $0.tags.joined(separator: ", ") } ?? "")
        _hasReminder = State(initialValue: note?.reminderDate != nil)
        _reminderDate = State(initialValue: note?.reminderDate ?? Date().addingTimeInterval(3600))
        _isCompleted = State(initialValue: note?.isCompleted ?? false)
        _isFavorite = State(initialValue: note?.isFavorite ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .foregroundColor(.white)

                    TextEditor(text: $content)
                        .frame(height: 200)
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                }
                .listRowBackground(formRowBackground)

                Section {
                    Picker("Category", selection: $category) {
                        ForEach(NoteCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }

                    Picker("Priority", selection: $priority) {
                        Text(NotePriority.low.title).tag(NotePriority.low)
                        Text(NotePriority.medium.title).tag(NotePriority.medium)
                        Text(NotePriority.high.title).tag(NotePriority.high)
                    }
                    .pickerStyle(.segmented)

                    TextField("Tags (comma-separated)", text: $tagsString)
                        .foregroundColor(.white)
                } header: {
                    Text("Organization")
                        .foregroundColor(.gray)
                }
                .listRowBackground(formRowBackground)

                Section {
                    Toggle("Set reminder", isOn: $hasReminder)
                        .tint(.noteSuccess)

                    if hasReminder {
                        DatePicker(
                            "Date & time",
                            selection: $reminderDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                } header: {
                    Text("Reminder")
                        .foregroundColor(.gray)
                }
                .listRowBackground(formRowBackground)

                Section {
                    Toggle("Completed", isOn: $isCompleted)
                        .tint(.noteSuccess)

                    Toggle("Favorite", isOn: $isFavorite)
                        .tint(.noteAccent)
                }
                .listRowBackground(formRowBackground)
            }
            .scrollContentBackground(.hidden)
            .background(NoteMindScreenBackdrop())
            .foregroundColor(.white)
            .navigationTitle(editing == nil ? "New note" : "Edit note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.noteAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundColor(.noteAccent)
                        .bold()
                }
            }
            .tint(.noteAccent)
        }
        .background(NoteMindScreenBackdrop())
    }

    private var formRowBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(NoteMindDesign.panelFill(.accent))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(NoteMindDesign.borderGlow(accent: .noteAccent), lineWidth: 1)
            )
    }

    private func save() {
        let tags = tagsString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let now = Date()
        let reminder = hasReminder ? reminderDate : nil

        if let existing = editing {
            var updated = existing
            updated.title = title.isEmpty ? "Untitled" : title
            updated.content = content
            updated.category = category
            updated.priority = priority
            updated.tags = tags
            updated.isCompleted = isCompleted
            updated.isFavorite = isFavorite
            updated.reminderDate = reminder
            updated.updatedAt = now
            viewModel.updateNote(updated)
        } else {
            let newNote = Note(
                id: UUID(),
                title: title.isEmpty ? "Untitled" : title,
                content: content,
                category: category,
                priority: priority,
                tags: tags,
                isCompleted: isCompleted,
                isFavorite: isFavorite,
                reminderDate: reminder,
                images: nil,
                createdAt: now,
                updatedAt: now
            )
            viewModel.addNote(newNote)
            if let notebook {
                viewModel.attachNote(newNote, to: notebook)
            }
        }
        dismiss()
    }
}
