//
//  HomeView.swift
//  118NoteMind
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: NoteMindViewModel
    @Binding var selectedTab: Int

    @State private var showAddNote = false
    @State private var detailNote: Note?

    private let notesTab = 1
    private let statsTab = 5

    private var todayLine: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                headerBlock

                heroCard

                quickMetricsRow

                if !viewModel.homeFavoriteNotes.isEmpty {
                    favoritesSection
                }

                recentSection

                if !viewModel.homeUpcomingReminders.isEmpty {
                    remindersSection
                }

                categoriesSection

                statisticsTeaser
            }
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .background(NoteMindScreenBackdrop())
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddNote) {
            AddNoteView(viewModel: viewModel)
        }
        .sheet(item: $detailNote) { note in
            NoteDetailView(viewModel: viewModel, noteId: note.id)
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(homeGreeting())
                .font(.title2.weight(.semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.noteAccent, .white.opacity(0.92)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text(todayLine)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.55))
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 20) {
                HomeProgressRing(progress: viewModel.homeCompletionProgress)
                    .frame(width: 88, height: 88)
                    .compositingGroup()
                    .noteDepthShadow(elevation: .low)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Completion")
                    .accessibilityValue("\(Int(viewModel.homeCompletionProgress * 100)) percent")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Your workspace")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(progressCaption)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(viewModel.homeActiveNotesCount) active · \(viewModel.completedNotes) done")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.noteSuccess.opacity(0.9))
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 12) {
                Button {
                    showAddNote = true
                } label: {
                    Label("New note", systemImage: "square.and.pencil")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(NoteMindDesign.primaryButtonFill)
                        )
                        .foregroundColor(.white)
                        .compositingGroup()
                        .noteDepthShadow(elevation: .medium)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Creates a new note")

                Button {
                    viewModel.resetNotesFiltersToShowAll()
                    selectedTab = notesTab
                } label: {
                    Label("All notes", systemImage: "list.bullet.rectangle")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(NoteMindDesign.panelFill(.accent))
                        )
                        .foregroundStyle(
                            LinearGradient(colors: [.noteAccent, .white.opacity(0.92)], startPoint: .leading, endPoint: .trailing)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(NoteMindDesign.borderGlow(accent: .noteAccent), lineWidth: 1)
                        )
                        .compositingGroup()
                        .noteDepthShadow(elevation: .low)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .noteCardSurface(cornerRadius: 22, emphasis: .accent, elevation: .medium)
        .padding(.horizontal, 20)
    }

    private var progressCaption: String {
        if viewModel.totalNotes == 0 {
            return "Start with a fresh note — capture ideas before they fade."
        }
        let pct = Int(viewModel.homeCompletionProgress * 100)
        if pct == 100 {
            return "Everything checked off. Time to plan what is next."
        }
        return "\(pct)% of notes completed. Keep the momentum going."
    }

    private var quickMetricsRow: some View {
        HStack(spacing: 10) {
            HomeMetricPill(title: "Total", value: viewModel.totalNotes, icon: "doc.text.fill", tint: .noteAccent, emphasis: .accent)
            HomeMetricPill(title: "Active", value: viewModel.homeActiveNotesCount, icon: "flame.fill", tint: .noteAccent, emphasis: .accent)
            HomeMetricPill(title: "Done", value: viewModel.completedNotes, icon: "checkmark.circle.fill", tint: .noteSuccess, emphasis: .success)
            HomeMetricPill(title: "Due", value: viewModel.upcomingReminders, icon: "bell.fill", tint: .noteSuccess, emphasis: .success)
        }
        .padding(.horizontal, 20)
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSectionHeader(title: "Starred", subtitle: "Quick picks", icon: "star.fill")
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.homeFavoriteNotes) { note in
                        HomeFavoriteChip(note: note)
                            .onTapGesture {
                                detailNote = note
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                HomeSectionHeader(title: "Recent", subtitle: "Latest edits", icon: "clock.fill")
                Spacer(minLength: 0)
                Button("See all") {
                    viewModel.resetNotesFiltersToShowAll()
                    selectedTab = notesTab
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.noteAccent)
                .padding(.top, 2)
            }
            .padding(.horizontal, 20)

            if viewModel.homeRecentNotes.isEmpty {
                HomeEmptyHint(message: "No notes yet. Tap New note to begin.")
                    .padding(.horizontal, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.homeRecentNotes) { note in
                        HomeRecentRow(note: note)
                            .onTapGesture {
                                detailNote = note
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSectionHeader(title: "Coming up", subtitle: "Reminders ahead", icon: "bell.badge.fill")
                .padding(.horizontal, 20)

            VStack(spacing: 10) {
                ForEach(Array(viewModel.homeUpcomingReminders.prefix(4))) { note in
                    HomeReminderRow(note: note)
                        .onTapGesture {
                            detailNote = note
                        }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSectionHeader(title: "Categories", subtitle: "Jump into a folder", icon: "folder.fill")
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(NoteCategory.allCases, id: \.self) { category in
                        let count = viewModel.notesCount(for: category)
                        Button {
                            viewModel.applyCategoryFilterForNotes(category)
                            selectedTab = notesTab
                        } label: {
                            HomeCategoryShortcut(category: category, count: count)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var statisticsTeaser: some View {
        Button {
            selectedTab = statsTab
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Insights")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Activity, tags, and distribution")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.55))
                }
                Spacer()
                Image(systemName: "chart.xyaxis.line")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(colors: [.noteSuccess, .noteAccent.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: Color.noteSuccess.opacity(0.35), radius: 6, x: 0, y: 3)
            }
            .padding(18)
            .noteCardSurface(cornerRadius: 18, emphasis: .success, elevation: .medium)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .accessibilityLabel("Open statistics")
    }
}

// MARK: - Pieces

private struct HomeProgressRing: View {
    var progress: Double

    private var clamped: Double {
        min(1, max(0, progress))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.noteAccent.opacity(0.18), lineWidth: 10)
            Circle()
                .trim(from: 0, to: clamped)
                .stroke(
                    AngularGradient(
                        colors: [.noteAccent, .noteSuccess, .noteAccent],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(Int(clamped * 100))")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                Text("%")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.noteSuccess)
            }
        }
    }
}

private struct HomeMetricPill: View {
    let title: String
    let value: Int
    let icon: String
    let tint: Color
    let emphasis: NotePanelEmphasis

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(
                    LinearGradient(colors: [tint, tint.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: tint.opacity(0.35), radius: 4, x: 0, y: 2)
            Text("\(value)")
                .font(.headline.monospacedDigit())
                .foregroundColor(.white)
            Text(title.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .noteCardSurface(cornerRadius: 14, emphasis: emphasis, elevation: .low)
    }
}

private struct HomeSectionHeader: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(
                    LinearGradient(colors: [.noteAccent, .noteAccent.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                )
                .font(.body.weight(.semibold))
                .shadow(color: Color.noteAccent.opacity(0.35), radius: 4, x: 0, y: 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

private struct HomeFavoriteChip: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: note.category.icon)
                    .font(.caption2)
                    .foregroundColor(.noteAccent)
                Spacer()
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.noteSuccess)
                    .shadow(color: Color.noteSuccess.opacity(0.35), radius: 3, x: 0, y: 1)
            }
            Text(note.title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(2)
            Text(note.previewContent)
                .font(.caption2)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding(14)
        .frame(width: 168, alignment: .leading)
        .noteCardSurface(cornerRadius: 16, emphasis: .success, elevation: .medium)
    }
}

private struct HomeRecentRow: View {
    let note: Note

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(note.priority.color)
                .frame(width: 4, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(note.isCompleted ? .gray : .white)
                    .strikethrough(note.isCompleted)

                Text(note.previewContent)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedShortDate(note.updatedAt))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.45))
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.noteAccent.opacity(0.55))
            }
        }
        .padding(14)
        .noteCardSurface(cornerRadius: 16, emphasis: .accent, elevation: .low)
    }
}

private struct HomeReminderRow: View {
    let note: Note

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.noteSuccess.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "bell.fill")
                    .foregroundColor(.noteSuccess)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                if let date = note.reminderDate {
                    Text(formattedDateTime(date))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.55))
                    Text(relativeTimeString(from: date))
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.noteSuccess)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundColor(.noteAccent.opacity(0.55))
        }
        .padding(14)
        .noteCardSurface(cornerRadius: 16, emphasis: .success, elevation: .low)
    }
}

private struct HomeCategoryShortcut: View {
    let category: NoteCategory
    let count: Int

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundColor(.noteAccent)
            Text(category.rawValue)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            Text("\(count)")
                .font(.caption2.weight(.bold))
                .foregroundColor(count > 0 ? .noteSuccess : .gray)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .noteCardSurface(cornerRadius: 14, emphasis: .accent, elevation: .low)
    }
}

private struct HomeEmptyHint: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.5))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(20)
            .noteCardSurface(cornerRadius: 16, emphasis: .accent, elevation: .low)
    }
}
