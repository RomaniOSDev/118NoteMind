//
//  NotebookCard.swift
//  118NoteMind
//

import SwiftUI

struct NotebookCard: View {
    let notebook: Notebook

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.noteAccent.opacity(0.35), Color.noteAccent.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(NoteMindDesign.borderGlow(accent: .noteAccent), lineWidth: 1)
                    )
                Image(systemName: notebook.icon)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.noteAccent, .noteAccent.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(notebook.name)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.white.opacity(0.88)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .font(.headline)

                Text("\(notebook.noteIds.count) notes")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.noteAccent, .noteAccent.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .padding()
        .noteCardSurface(cornerRadius: 18, emphasis: .accent, elevation: .medium)
    }
}
