//
//  TagsView.swift
//  118NoteMind
//

import SwiftUI

struct TagsView: View {
    @ObservedObject var viewModel: NoteMindViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(viewModel.allTags, id: \.self) { tag in
                        NavigationLink {
                            TagNotesView(viewModel: viewModel, tag: tag)
                        } label: {
                            TagChip(
                                tag: tag,
                                count: viewModel.tagCount(tag),
                                isSelected: false
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(NoteMindScreenBackdrop())
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.large)
        }
        .tint(.noteSuccess)
    }
}
