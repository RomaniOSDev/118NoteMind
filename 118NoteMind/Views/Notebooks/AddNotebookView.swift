//
//  AddNotebookView.swift
//  118NoteMind
//

import SwiftUI

struct AddNotebookView: View {
    @ObservedObject var viewModel: NoteMindViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var icon: String = "book.fill"

    private let iconOptions = [
        "book.fill",
        "briefcase.fill",
        "heart.fill",
        "star.fill",
        "folder.fill",
        "graduationcap.fill",
        "lightbulb.fill",
        "leaf.fill"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .foregroundColor(.white)
                }
                .listRowBackground(formRowBackground)

                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(iconOptions, id: \.self) { symbol in
                                let selected = icon == symbol
                                Image(systemName: symbol)
                                    .font(.title2)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: selected
                                                ? [.noteSuccess, .noteSuccess.opacity(0.7)]
                                                : [.noteAccent, .noteAccent.opacity(0.65)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(NoteMindDesign.panelFill(selected ? .success : .accent))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(
                                                NoteMindDesign.borderGlow(accent: selected ? .noteSuccess : .noteAccent),
                                                lineWidth: 1
                                            )
                                    )
                                    .compositingGroup()
                                    .shadow(color: .black.opacity(0.28), radius: selected ? 8 : 4, x: 0, y: selected ? 4 : 2)
                                    .onTapGesture { icon = symbol }
                            }
                        }
                    }
                } header: {
                    Text("Icon")
                        .foregroundColor(.gray)
                }
                .listRowBackground(formRowBackground)
            }
            .scrollContentBackground(.hidden)
            .background(NoteMindScreenBackdrop())
            .foregroundColor(.white)
            .navigationTitle("New notebook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.noteAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .bold()
                        .foregroundColor(.noteAccent)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let notebook = Notebook(
            id: UUID(),
            name: trimmed,
            icon: icon,
            noteIds: [],
            color: nil,
            createdAt: Date()
        )
        viewModel.addNotebook(notebook)
        dismiss()
    }
}
