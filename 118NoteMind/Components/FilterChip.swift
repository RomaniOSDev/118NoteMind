//
//  FilterChip.swift
//  118NoteMind
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color

    private var backgroundGradient: LinearGradient {
        if isSelected {
            LinearGradient(
                colors: [color, color.opacity(0.82)],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            LinearGradient(
                colors: [
                    Color.noteAccent.opacity(0.14),
                    Color.black.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var body: some View {
        Text(title)
            .font(.subheadline.weight(isSelected ? .semibold : .regular))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(backgroundGradient)
            )
            .foregroundColor(isSelected ? .noteBackground : color)
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(isSelected ? 0.85 : 0.45), color.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(isSelected ? 0.35 : 0.22), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
            .shadow(color: color.opacity(isSelected ? 0.28 : 0.1), radius: isSelected ? 6 : 3, x: 0, y: 2)
    }
}
