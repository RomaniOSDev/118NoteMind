//
//  AppExternalLink.swift
//  118NoteMind
//

import Foundation

enum AppExternalLink: String, CaseIterable {
    case privacyPolicy = "https://www.termsfeed.com/live/43c3b61c-87d3-4363-8e9b-fa40228770ab"
    case termsOfUse = "https://www.termsfeed.com/live/190a54ee-5bf3-493d-88c5-8b7daa348832"

    var url: URL? {
        URL(string: rawValue)
    }
}
