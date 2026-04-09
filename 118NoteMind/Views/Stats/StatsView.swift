//
//  StatsView.swift
//  118NoteMind
//

import Charts
import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: NoteMindViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(
                            title: "Total notes",
                            value: "\(viewModel.totalNotes)",
                            icon: "doc.text.fill",
                            color: .noteAccent
                        )

                        StatCard(
                            title: "Completed",
                            value: "\(viewModel.completedNotes)",
                            icon: "checkmark.circle.fill",
                            color: .noteSuccess,
                            emphasis: .success
                        )

                        StatCard(
                            title: "Favorites",
                            value: "\(viewModel.favoriteNotes)",
                            icon: "star.fill",
                            color: .noteAccent
                        )

                        StatCard(
                            title: "Avg. words",
                            value: "\(viewModel.averageWords)",
                            icon: "text.word.spacing",
                            color: .noteAccent
                        )
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity by day")
                            .font(.headline)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.noteAccent, .white.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color.noteAccent.opacity(0.25), radius: 6, x: 0, y: 3)

                        Chart {
                            ForEach(viewModel.weeklyActivity) { data in
                                BarMark(
                                    x: .value("Day", data.day),
                                    y: .value("Notes", data.count)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.noteSuccess, .noteSuccess.opacity(0.45)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                        }
                        .frame(height: 150)
                        .chartXAxis {
                            AxisMarks { value in
                                AxisValueLabel()
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisValueLabel()
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                    .padding(18)
                    .noteCardSurface(cornerRadius: 18, emphasis: .accent, elevation: .low)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("By category")
                            .font(.headline)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.noteAccent, .white.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        if viewModel.categoryDistribution.isEmpty {
                            Text("No data yet.")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        } else {
                            ForEach(viewModel.categoryDistribution) { item in
                                HStack {
                                    Image(systemName: item.icon)
                                        .foregroundColor(.noteAccent)
                                        .frame(width: 30)

                                    Text(item.name)
                                        .foregroundColor(.white)

                                    Spacer()

                                    Text("\(item.count)")
                                        .foregroundColor(.noteSuccess)

                                    Text("(\(Int(item.percentage))%)")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding(18)
                    .noteCardSurface(cornerRadius: 18, emphasis: .accent, elevation: .low)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Popular tags")
                            .font(.headline)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.noteSuccess, .noteAccent.opacity(0.95)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        if viewModel.popularTags.isEmpty {
                            Text("No tags yet.")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.popularTags.prefix(10), id: \.self) { tag in
                                        Text("#\(tag)")
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(
                                                Capsule()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [Color.noteSuccess.opacity(0.28), Color.noteSuccess.opacity(0.1)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                            )
                                            .overlay(
                                                Capsule()
                                                    .stroke(NoteMindDesign.borderGlow(accent: .noteSuccess), lineWidth: 1)
                                            )
                                            .foregroundColor(.noteSuccess)
                                            .compositingGroup()
                                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                        }
                    }
                    .padding(18)
                    .noteCardSurface(cornerRadius: 18, emphasis: .success, elevation: .low)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(NoteMindScreenBackdrop())
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
        .tint(.noteAccent)
    }
}
