//
//  SettingsView.swift
//  118NoteMind
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        rateApp()
                    } label: {
                        SettingsRowLabel(
                            title: "Rate us",
                            icon: "star.fill",
                            tint: .noteSuccess
                        )
                    }

                    Button {
                        openURL(AppExternalLink.privacyPolicy)
                    } label: {
                        SettingsRowLabel(
                            title: "Privacy Policy",
                            icon: "hand.raised.fill",
                            tint: .noteAccent
                        )
                    }

                    Button {
                        openURL(AppExternalLink.termsOfUse)
                    } label: {
                        SettingsRowLabel(
                            title: "Terms of Use",
                            icon: "doc.plaintext.fill",
                            tint: .noteAccent
                        )
                    }
                } header: {
                    Text("Support & Legal")
                        .foregroundColor(.gray)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(NoteMindScreenBackdrop())
            .foregroundColor(.white)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .tint(.noteAccent)
    }

    private func openURL(_ link: AppExternalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

private struct SettingsRowLabel: View {
    let title: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(
                    LinearGradient(colors: [tint, tint.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 28, alignment: .center)
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.35))
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    SettingsView()
}
