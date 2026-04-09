//
//  NotesListView.swift
//  118NoteMind
//

import SwiftUI

struct NotesListView: View {
    @ObservedObject var viewModel: NoteMindViewModel
    @State private var showAddNote = false
    @State private var detailNote: Note?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NoteMindScreenBackdrop()

            VStack(alignment: .leading, spacing: 16) {
                headerSection

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        StatCard(
                            title: "Total",
                            value: "\(viewModel.totalNotes)",
                            icon: "doc.text.fill",
                            color: .noteAccent
                        )
                        .frame(width: 140)

                        StatCard(
                            title: "Done",
                            value: "\(viewModel.completedNotes)",
                            icon: "checkmark.circle.fill",
                            color: .noteSuccess,
                            emphasis: .success
                        )
                        .frame(width: 140)

                        StatCard(
                            title: "Favorite",
                            value: "\(viewModel.favoriteNotes)",
                            icon: "star.fill",
                            color: .noteAccent
                        )
                        .frame(width: 140)

                        StatCard(
                            title: "Reminders",
                            value: "\(viewModel.upcomingReminders)",
                            icon: "bell.fill",
                            color: .noteSuccess,
                            emphasis: .success
                        )
                        .frame(width: 140)
                    }
                    .padding(.horizontal)
                }

                searchBar

                filterChips

                notesList
            }

            Button {
                showAddNote = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 56))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color.noteAccent)
            }
            .compositingGroup()
            .noteDepthShadow(elevation: .high)
            .padding(.trailing, 20)
            .padding(.bottom, 24)
            .accessibilityLabel("Add note")
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showAddNote) {
            AddNoteView(viewModel: viewModel)
        }
        .sheet(item: $detailNote) { note in
            NoteDetailView(viewModel: viewModel, noteId: note.id)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Notes")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(
                    LinearGradient(
                        colors: [.noteAccent, .noteAccent.opacity(0.75), .white.opacity(0.92)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.noteAccent.opacity(0.35), radius: 12, x: 0, y: 6)

            Text("\(viewModel.totalNotes) notes")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.55))
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.noteAccent)

            TextField("Search notes...", text: $viewModel.searchText)
                .foregroundColor(.white)
                .tint(.noteAccent)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .noteSearchBarChrome(cornerRadius: 14)
        .padding(.horizontal)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: viewModel.selectedFilter == nil && viewModel.selectedCategory == nil && viewModel.selectedTag == nil, color: .noteAccent)
                    .onTapGesture {
                        viewModel.selectedFilter = nil
                        viewModel.selectedCategory = nil
                        viewModel.selectedTag = nil
                    }

                FilterChip(title: "Active", isSelected: viewModel.selectedFilter == .active, color: .noteAccent)
                    .onTapGesture { viewModel.selectedFilter = .active }

                FilterChip(title: "Completed", isSelected: viewModel.selectedFilter == .completed, color: .noteSuccess)
                    .onTapGesture { viewModel.selectedFilter = .completed }

                FilterChip(title: "Favorites", isSelected: viewModel.selectedFilter == .favorites, color: .noteAccent)
                    .onTapGesture { viewModel.selectedFilter = .favorites }

                Menu {
                    ForEach(NoteCategory.allCases, id: \.self) { category in
                        Button(category.rawValue) {
                            viewModel.selectedCategory = category
                            viewModel.selectedTag = nil
                        }
                    }
                    Button("All categories") {
                        viewModel.selectedCategory = nil
                    }
                } label: {
                    FilterChip(
                        title: viewModel.selectedCategory?.rawValue ?? "Category",
                        isSelected: viewModel.selectedCategory != nil,
                        color: .noteAccent
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    private var notesList: some View {
        List {
            ForEach(viewModel.filteredNotes) { note in
                NoteCard(note: note)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        detailNote = note
                    }
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
