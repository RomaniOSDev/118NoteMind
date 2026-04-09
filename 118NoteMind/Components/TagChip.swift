//
//  TagChip.swift
//  118NoteMind
//

import SwiftUI

struct TagChip: View {
    let tag: String
    let count: Int
    let isSelected: Bool

    private var fillGradient: LinearGradient {
        if isSelected {
            LinearGradient(
                colors: [.noteSuccess, .noteSuccess.opacity(0.82)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            LinearGradient(
                colors: [Color.noteAccent.opacity(0.16), Color.black.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var body: some View {
        HStack {
            Text("#\(tag)")
                .font(.subheadline)
            Text("(\(count))")
                .font(.caption)
                .foregroundColor(isSelected ? .noteBackground.opacity(0.65) : .gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(fillGradient)
        )
        .foregroundColor(isSelected ? .noteBackground : .noteSuccess)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: isSelected
                            ? [Color.noteSuccess.opacity(0.9), Color.white.opacity(0.15)]
                            : [Color.noteSuccess.opacity(0.35), Color.noteAccent.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .compositingGroup()
        .shadow(color: .black.opacity(0.28), radius: 8, x: 0, y: 4)
        .shadow(color: Color.noteSuccess.opacity(isSelected ? 0.25 : 0.12), radius: 6, x: 0, y: 3)
    }
}
