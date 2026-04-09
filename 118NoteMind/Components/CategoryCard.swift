//
//  CategoryCard.swift
//  118NoteMind
//

import SwiftUI

struct CategoryCard: View {
    let category: NoteCategory
    let count: Int
    let completed: Int

    private var percentage: Double {
        guard count > 0 else { return 0 }
        return Double(completed) / Double(count)
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.largeTitle)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.noteAccent, .noteAccent.opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.noteAccent.opacity(0.35), radius: 8, x: 0, y: 4)

            Text(category.rawValue)
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.white.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("\(count) notes")
                .font(.caption)
                .foregroundColor(.gray)

            if count > 0 {
                ProgressView(value: percentage)
                    .tint(.noteSuccess)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.35))
                    )
                    .clipShape(Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .noteCardSurface(cornerRadius: 18, emphasis: .accent, elevation: .medium)
    }
}
