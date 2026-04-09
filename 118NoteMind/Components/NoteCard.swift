//
//  NoteCard.swift
//  118NoteMind
//

import SwiftUI

struct NoteCard: View {
    let note: Note

    private var emphasis: NotePanelEmphasis {
        note.isCompleted ? .success : .accent
    }

    private var borderTint: Color {
        note.isCompleted ? .noteSuccess : .noteAccent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: note.priority.icon)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [note.priority.color, note.priority.color.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: note.priority.color.opacity(0.35), radius: 3, x: 0, y: 1)
                    .font(.caption)

                Text(note.title)
                    .font(.headline)
                    .foregroundColor(note.isCompleted ? .gray : .white)
                    .strikethrough(note.isCompleted)

                Spacer()

                if note.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.noteSuccess)
                        .shadow(color: Color.noteSuccess.opacity(0.4), radius: 3, x: 0, y: 1)
                        .font(.caption)
                }

                if note.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(
                            LinearGradient(colors: [.noteSuccess, .noteSuccess.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                        )
                        .font(.caption)
                }
            }

            Text(note.previewContent)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: note.category.icon)
                        .font(.caption2)
                    Text(note.category.rawValue)
                        .font(.caption2)
                }
                .foregroundStyle(
                    LinearGradient(colors: [.noteAccent, .noteAccent.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
                )

                Spacer()

                if !note.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(note.tags.prefix(3), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .foregroundStyle(Color.noteSuccess)
                            }
                            if note.tags.count > 3 {
                                Text("+\(note.tags.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(maxWidth: 150)
                }

                Text(formattedShortDate(note.updatedAt))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(NoteMindDesign.panelFill(emphasis))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(NoteMindDesign.borderGlow(accent: borderTint), lineWidth: 1)
        )
        .noteInsetHighlight(cornerRadius: 16, opacity: 0.18)
        .compositingGroup()
        .noteDepthShadow(elevation: .low)
    }
}
