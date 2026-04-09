//
//  OnboardingView.swift
//  118NoteMind
//

import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var page = 0

    private let pages: [(icon: String, title: String, message: String, emphasis: NotePanelEmphasis)] = [
        (
            "square.and.pencil",
            "Write in one place",
            "Capture ideas, tasks, and details with a calm editor that stays out of your way.",
            .accent
        ),
        (
            "folder.badge.gearshape",
            "Organize clearly",
            "Use categories, tags, and notebooks so nothing gets lost when your list grows.",
            .accent
        ),
        (
            "chart.line.uptrend.xyaxis",
            "See your progress",
            "Track reminders, favorites, and simple stats to stay focused every day.",
            .success
        )
    ]

    var body: some View {
        ZStack {
            NoteMindScreenBackdrop()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        onFinish()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white.opacity(0.85), .noteAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                }

                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                        OnboardingPage(
                            icon: item.icon,
                            title: item.title,
                            message: item.message,
                            emphasis: item.emphasis
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                VStack(spacing: 12) {
                    if page < pages.count - 1 {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                page += 1
                            }
                        } label: {
                            Text("Next")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(NoteMindDesign.primaryButtonFill)
                                )
                                .foregroundColor(.white)
                                .compositingGroup()
                                .noteDepthShadow(elevation: .medium)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Goes to the next screen")
                    } else {
                        Button {
                            onFinish()
                        } label: {
                            Text("Get started")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [.noteSuccess, .noteSuccess.opacity(0.78), .noteAccent.opacity(0.9)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .foregroundColor(.noteBackground)
                                .compositingGroup()
                                .noteDepthShadow(elevation: .high)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Continues to the app")
                    }

                    if page > 0 {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                page -= 1
                            }
                        } label: {
                            Text("Back")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.noteAccent.opacity(0.95))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Page

private struct OnboardingPage: View {
    let icon: String
    let title: String
    let message: String
    let emphasis: NotePanelEmphasis

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(NoteMindDesign.panelFill(emphasis))
                    .frame(width: 148, height: 148)
                    .overlay(
                        Circle()
                            .stroke(NoteMindDesign.borderGlow(accent: emphasis == .accent ? .noteAccent : .noteSuccess), lineWidth: 1)
                    )
                    .compositingGroup()
                    .noteDepthShadow(elevation: .high)

                Image(systemName: icon)
                    .font(.system(size: 58, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: emphasis == .accent
                                ? [.noteAccent, .white.opacity(0.92)]
                                : [.noteSuccess, .noteAccent.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: (emphasis == .accent ? Color.noteAccent : Color.noteSuccess).opacity(0.45), radius: 16, x: 0, y: 8)
            }
            .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.88)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.68))
                    .lineSpacing(4)
                    .padding(.horizontal, 28)
            }

            Spacer()
            Spacer()
        }
        .padding(.top, 8)
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
