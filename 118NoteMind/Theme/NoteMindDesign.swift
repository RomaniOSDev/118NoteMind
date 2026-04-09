//
//  NoteMindDesign.swift
//  118NoteMind
//

import SwiftUI

// MARK: - Panel emphasis

enum NotePanelEmphasis {
    case accent
    case success
}

// MARK: - Elevation (layered shadows)

enum NoteElevation {
    case low, medium, high

    fileprivate var primaryOpacity: Double {
        switch self {
        case .low: return 0.3
        case .medium: return 0.45
        case .high: return 0.58
        }
    }

    fileprivate var primaryRadius: CGFloat {
        switch self {
        case .low: return 8
        case .medium: return 16
        case .high: return 26
        }
    }

    fileprivate var primaryY: CGFloat {
        switch self {
        case .low: return 4
        case .medium: return 10
        case .high: return 16
        }
    }

    fileprivate var accentGlow: Double {
        switch self {
        case .low: return 0.07
        case .medium: return 0.14
        case .high: return 0.22
        }
    }

    fileprivate var glowRadius: CGFloat {
        switch self {
        case .low: return 5
        case .medium: return 12
        case .high: return 20
        }
    }

    fileprivate var glowY: CGFloat {
        switch self {
        case .low: return 2
        case .medium: return 5
        case .high: return 8
        }
    }
}

// MARK: - Gradients & presets

enum NoteMindDesign {
    static var screenRadialAccent: RadialGradient {
        RadialGradient(
            colors: [Color.noteAccent.opacity(0.32), Color.clear],
            center: UnitPoint(x: 0.1, y: 0.05),
            startRadius: 20,
            endRadius: 420
        )
    }

    static var screenRadialSuccess: RadialGradient {
        RadialGradient(
            colors: [Color.noteSuccess.opacity(0.14), Color.clear],
            center: UnitPoint(x: 0.95, y: 0.9),
            startRadius: 20,
            endRadius: 300
        )
    }

    static var screenTopSheen: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.07), Color.clear],
            startPoint: .top,
            endPoint: UnitPoint(x: 0.5, y: 0.32)
        )
    }

    static var screenBottomVignette: LinearGradient {
        LinearGradient(
            colors: [Color.clear, Color.black.opacity(0.42)],
            startPoint: .center,
            endPoint: .bottom
        )
    }

    static func panelFill(_ emphasis: NotePanelEmphasis) -> LinearGradient {
        switch emphasis {
        case .accent:
            return LinearGradient(
                colors: [
                    Color.noteAccent.opacity(0.24),
                    Color.noteBackground.opacity(0.55),
                    Color.black.opacity(0.32)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .success:
            return LinearGradient(
                colors: [
                    Color.noteSuccess.opacity(0.16),
                    Color.noteBackground.opacity(0.52),
                    Color.black.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    static func borderGlow(accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [accent.opacity(0.58), accent.opacity(0.2), Color.white.opacity(0.12)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var searchFieldFill: LinearGradient {
        LinearGradient(
            colors: [
                Color.noteAccent.opacity(0.26),
                Color.noteAccent.opacity(0.1),
                Color.black.opacity(0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryButtonFill: LinearGradient {
        LinearGradient(
            colors: [Color.noteAccent, Color.noteAccent.opacity(0.72)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var destructiveOutlineFill: LinearGradient {
        LinearGradient(
            colors: [Color.noteSuccess.opacity(0.12), Color.black.opacity(0.15)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Full screen backdrop

struct NoteMindScreenBackdrop: View {
    var body: some View {
        ZStack {
            Color.noteBackground
            NoteMindDesign.screenRadialAccent
            NoteMindDesign.screenRadialSuccess
            NoteMindDesign.screenTopSheen
            NoteMindDesign.screenBottomVignette
        }
        .ignoresSafeArea()
    }
}

// MARK: - View extensions

extension View {
    func noteScreenBackdrop() -> some View {
        background(NoteMindScreenBackdrop())
    }

    func noteDepthShadow(elevation: NoteElevation = .medium) -> some View {
        self
            .shadow(color: .black.opacity(elevation.primaryOpacity), radius: elevation.primaryRadius, x: 0, y: elevation.primaryY)
            .shadow(color: Color.noteAccent.opacity(elevation.accentGlow), radius: elevation.glowRadius, x: 0, y: elevation.glowY)
    }

    /// Gradient fill, luminous border, depth shadow — for cards & panels.
    func noteCardSurface(
        cornerRadius: CGFloat = 16,
        emphasis: NotePanelEmphasis = .accent,
        elevation: NoteElevation = .low
    ) -> some View {
        let borderTint: Color = emphasis == .accent ? .noteAccent : .noteSuccess
        return self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(NoteMindDesign.panelFill(emphasis))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(NoteMindDesign.borderGlow(accent: borderTint), lineWidth: 1)
            )
            .compositingGroup()
            .noteDepthShadow(elevation: elevation)
    }

    func noteInsetHighlight(cornerRadius: CGFloat, opacity: Double = 0.22) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(opacity), .clear, .black.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .blendMode(.overlay)
        )
    }

    func noteSearchBarChrome(cornerRadius: CGFloat = 14) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(NoteMindDesign.searchFieldFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(NoteMindDesign.borderGlow(accent: .noteAccent), lineWidth: 1)
        )
        .compositingGroup()
        .noteDepthShadow(elevation: .low)
    }
}
