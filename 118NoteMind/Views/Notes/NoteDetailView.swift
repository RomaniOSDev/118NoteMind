//
//  NoteDetailView.swift
//  118NoteMind
//

import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: NoteMindViewModel
    let noteId: UUID

    @Environment(\.dismiss) private var dismiss

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false

    private var note: Note? {
        viewModel.note(by: noteId)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let note {
                    scrollContent(for: note)
                } else {
                    Text("This note is no longer available.")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(NoteMindScreenBackdrop())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.noteAccent)
                }
            }
            .sheet(isPresented: $showEditSheet) {
                if let note {
                    AddNoteView(viewModel: viewModel, editing: note)
                }
            }
            .alert("Delete this note?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let note {
                        viewModel.deleteNote(note)
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    @ViewBuilder
    private func scrollContent(for note: Note) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header(for: note)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Content")
                        .font(.headline)
                        .foregroundStyle(
                            LinearGradient(colors: [.noteAccent, .white.opacity(0.92)], startPoint: .leading, endPoint: .trailing)
                        )

                    Text(note.content.isEmpty ? "—" : note.content)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .noteCardSurface(cornerRadius: 12, emphasis: .accent, elevation: .low)
                }
                .padding(.horizontal)

                if !note.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundStyle(
                                LinearGradient(colors: [.noteAccent, .white.opacity(0.92)], startPoint: .leading, endPoint: .trailing)
                            )

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(note.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.noteSuccess.opacity(0.3), Color.noteSuccess.opacity(0.1)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(NoteMindDesign.borderGlow(accent: .noteSuccess), lineWidth: 1)
                                        )
                                        .foregroundColor(.noteSuccess)
                                        .compositingGroup()
                                        .shadow(color: .black.opacity(0.22), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                if let reminder = note.reminderDate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reminder")
                            .font(.headline)
                            .foregroundStyle(
                                LinearGradient(colors: [.noteAccent, .white.opacity(0.92)], startPoint: .leading, endPoint: .trailing)
                            )

                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(
                                    LinearGradient(colors: [.noteSuccess, .noteSuccess.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                                )
                                .shadow(color: Color.noteSuccess.opacity(0.35), radius: 4, x: 0, y: 2)
                            Text(formattedDateTime(reminder))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .noteCardSurface(cornerRadius: 12, emphasis: .success, elevation: .low)
                    }
                    .padding(.horizontal)
                }

                HStack(spacing: 12) {
                    Button("Edit") {
                        showEditSheet = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(NoteMindDesign.primaryButtonFill)
                    )
                    .foregroundColor(.white)
                    .compositingGroup()
                    .noteDepthShadow(elevation: .medium)

                    Button("Delete") {
                        showDeleteConfirmation = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(NoteMindDesign.destructiveOutlineFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(NoteMindDesign.borderGlow(accent: .noteSuccess), lineWidth: 1)
                    )
                    .foregroundColor(.noteSuccess)
                    .compositingGroup()
                    .noteDepthShadow(elevation: .low)
                }
                .padding()
            }
        }
    }

    private func header(for note: Note) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: note.priority.icon)
                    .foregroundStyle(
                        LinearGradient(colors: [note.priority.color, note.priority.color.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: note.priority.color.opacity(0.4), radius: 4, x: 0, y: 2)

                Text(note.title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(note.isCompleted ? .gray : .white)
                    .strikethrough(note.isCompleted)

                Spacer()

                if note.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.noteSuccess)
                        .shadow(color: Color.noteSuccess.opacity(0.45), radius: 4, x: 0, y: 2)
                }
            }

            HStack {
                Image(systemName: note.category.icon)
                    .foregroundColor(.noteAccent)
                Text(note.category.rawValue)
                    .foregroundStyle(
                        LinearGradient(colors: [.noteAccent, .noteAccent.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
                    )

                Spacer()

                Text("Updated: \(formattedDate(note.updatedAt))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .noteCardSurface(cornerRadius: 18, emphasis: note.isCompleted ? .success : .accent, elevation: .medium)
        .padding(.horizontal)
    }
}
