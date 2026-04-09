//
//  CategoryNotesView.swift
//  118NoteMind
//

import SwiftUI

struct CategoryNotesView: View {
    @ObservedObject var viewModel: NoteMindViewModel
    let category: NoteCategory

    @State private var detailNote: Note?

    private var notes: [Note] {
        viewModel.notes
            .filter { $0.category == category }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var body: some View {
        ZStack {
            NoteMindScreenBackdrop()

            if notes.isEmpty {
                Text("No notes in this category.")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(notes) { note in
                        NoteCard(note: note)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .contentShape(Rectangle())
                            .onTapGesture { detailNote = note }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    viewModel.toggleCompleted(note)
                                } label: {
                                    Label(
                                        note.isCompleted ? "Reopen" : "Complete",
                                        systemImage: "checkmark"
                                    )
                                }
                                .tint(note.isCompleted ? .noteAccent : .noteSuccess)

                                Button(role: .destructive) {
                                    viewModel.deleteNote(note)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    viewModel.toggleFavorite(note)
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                .tint(.noteAccent)
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $detailNote) { note in
            NoteDetailView(viewModel: viewModel, noteId: note.id)
        }
    }
}
