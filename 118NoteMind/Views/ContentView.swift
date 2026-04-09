//
//  ContentView.swift
//  118NoteMind
//

import SwiftUI

struct ContentView: View {
    @AppStorage("notemind_onboarding_completed") private var onboardingCompleted = false

    @StateObject private var viewModel = NoteMindViewModel()
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if onboardingCompleted {
                mainTabView
            } else {
                OnboardingView {
                    onboardingCompleted = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(viewModel: viewModel, selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack {
                NotesListView(viewModel: viewModel)
            }
            .tabItem {
                Label("Notes", systemImage: "doc.text.fill")
            }
            .tag(1)

            CategoriesView(viewModel: viewModel)
                .tabItem {
                    Label("Categories", systemImage: "folder.fill")
                }
                .tag(2)

            TagsView(viewModel: viewModel)
                .tabItem {
                    Label("Tags", systemImage: "tag.fill")
                }
                .tag(3)

            NotebooksView(viewModel: viewModel)
                .tabItem {
                    Label("Notebooks", systemImage: "book.fill")
                }
                .tag(4)

            StatsView(viewModel: viewModel)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(5)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(6)
        }
        .onAppear {
            viewModel.loadFromUserDefaults()
            viewModel.requestNotificationAuthorization()
        }
        .tint(.noteAccent)
        .toolbarBackground(Color.noteBackground.opacity(0.94), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

#Preview {
    ContentView()
}
