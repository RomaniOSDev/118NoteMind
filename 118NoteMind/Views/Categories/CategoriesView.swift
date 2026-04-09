//
//  CategoriesView.swift
//  118NoteMind
//

import SwiftUI

struct CategoriesView: View {
    @ObservedObject var viewModel: NoteMindViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(NoteCategory.allCases, id: \.self) { category in
                        NavigationLink {
                            CategoryNotesView(viewModel: viewModel, category: category)
                        } label: {
                            CategoryCard(
                                category: category,
                                count: viewModel.notesCount(for: category),
                                completed: viewModel.completedCount(for: category)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(NoteMindScreenBackdrop())
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .tint(.noteAccent)
    }
}
