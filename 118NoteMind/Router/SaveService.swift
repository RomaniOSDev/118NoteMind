//
//  SaveService.swift
//  118NoteMind
//
//  Created by Xeova Nuoc on 28.02.2026.
//

import Foundation

struct UrlDefaultsBridge {
    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: RouterDefaultsKeyVault.resolvedSavedURLKey) }
        set { UserDefaults.standard.set(newValue, forKey: RouterDefaultsKeyVault.resolvedSavedURLKey) }
    }
}
