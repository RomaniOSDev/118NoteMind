//
//  NotebooksView.swift
//  118NoteMind
//

import SwiftUI

struct NotebooksView: View {
    @ObservedObject var viewModel: NoteMindViewModel

    @State private var showAddNotebookSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.notebooks) { notebook in
                        NavigationLink {
                            NotebookDetailView(viewModel: viewModel, notebook: notebook)
                        } label: {
                            NotebookCard(notebook: notebook)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.deleteNotebook(notebook)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }

                    Button("Create notebook") {
                        showAddNotebookSheet = true
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(NoteMindDesign.panelFill(.accent))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(NoteMindDesign.borderGlow(accent: .noteAccent), lineWidth: 1)
                    )
                    .foregroundStyle(
                        LinearGradient(colors: [.noteAccent, .white.opacity(0.95)], startPoint: .leading, endPoint: .trailing)
                    )
                    .compositingGroup()
                    .noteDepthShadow(elevation: .medium)
                }
                .padding()
            }
            .background(NoteMindScreenBackdrop())
            .navigationTitle("Notebooks")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddNotebookSheet) {
                AddNotebookView(viewModel: viewModel)
            }
        }
        .tint(.noteAccent)
    }
}
