//
//  NotebookDetailView.swift
//  118NoteMind
//

import SwiftUI

struct NotebookDetailView: View {
    @ObservedObject var viewModel: NoteMindViewModel
    @State var notebook: Notebook

    @State private var detailNote: Note?
    @State private var showAddNote = false

    private var notes: [Note] {
        viewModel.notes(forNotebook: notebook)
    }

    var body: some View {
        ZStack {
            NoteMindScreenBackdrop()
            mainContent
        }
        .navigationTitle(notebook.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddNote = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(colors: [.noteAccent, .noteAccent.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                        )
                        .compositingGroup()
                        .shadow(color: Color.noteAccent.opacity(0.45), radius: 8, x: 0, y: 4)
                }
                .accessibilityLabel("Add note to notebook")
            }
        }
        .sheet(isPresented: $showAddNote) {
            AddNoteView(viewModel: viewModel, notebook: notebook)
        }
        .sheet(item: $detailNote) { note in
            NoteDetailView(viewModel: viewModel, noteId: note.id)
        }
        .onAppear(perform: syncNotebook)
        .onChange(of: viewModel.notebooks) { _ in
            syncNotebook()
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if notes.isEmpty {
            emptyState
        } else {
            notesList
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("No notes in this notebook yet.")
                .foregroundColor(.gray)
            Button("Add note") {
                showAddNote = true
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(NoteMindDesign.primaryButtonFill)
            )
            .foregroundColor(.white)
            .compositingGroup()
            .noteDepthShadow(elevation: .medium)
            .padding(.horizontal, 32)
        }
    }

    private var notesList: some View {
        List {
            ForEach(notes) { note in
                notebookRow(for: note)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func notebookRow(for note: Note) -> some View {
        NoteCard(note: note)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .contentShape(Rectangle())
            .onTapGesture { detailNote = note }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    removeNoteFromNotebook(note)
                } label: {
                    Label("Remove", systemImage: "folder.badge.minus")
                }
                .tint(.noteAccent)
            }
    }

    private func syncNotebook() {
        if let updated = viewModel.notebooks.first(where: { $0.id == notebook.id }) {
            notebook = updated
        }
    }

    private func removeNoteFromNotebook(_ note: Note) {
        notebook.noteIds.removeAll { $0 == note.id }
        viewModel.updateNotebook(notebook)
    }
}
