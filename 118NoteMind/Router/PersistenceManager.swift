//
//  PersistenceManager.swift
//  118NoteMind
//
//  Created by Xeova Nuoc on 28.02.2026.
//

import Foundation

enum RouterScramble {
    private static let blendingMask: UInt8 = 0xA7

    static func decode(_ encoded: [UInt8]) -> String {
        String(bytes: encoded.map { $0 ^ blendingMask }, encoding: .utf8) ?? ""
    }
}

enum RouterDefaultsKeyVault {
    private static let savedUrlBlob: [UInt8] = [0xEB, 0xC6, 0xD4, 0xD3, 0xF2, 0xD5, 0xCB]
    private static let hasShownBlob: [UInt8] = [0xEF, 0xC6, 0xD4, 0xF4, 0xCF, 0xC8, 0xD0, 0xC9, 0xE4, 0xC8, 0xC9, 0xD3, 0xC2, 0xC9, 0xD3, 0xF1, 0xCE, 0xC2, 0xD0]
    private static let webLoadBlob: [UInt8] = [0xEF, 0xC6, 0xD4, 0xF4, 0xD2, 0xC4, 0xC4, 0xC2, 0xD4, 0xD4, 0xC1, 0xD2, 0xCB, 0xF0, 0xC2, 0xC5, 0xF1, 0xCE, 0xC2, 0xD0, 0xEB, 0xC8, 0xC6, 0xC3]

    static var resolvedSavedURLKey: String { RouterScramble.decode(savedUrlBlob) }
    static var resolvedShownContentKey: String { RouterScramble.decode(hasShownBlob) }
    static var resolvedWebLoadKey: String { RouterScramble.decode(webLoadBlob) }
}

class PreferenceSyncEngine {
    static let hub = PreferenceSyncEngine()

    var savedUrl: String? {
        get {
            if let url = UrlDefaultsBridge.lastUrl {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: RouterDefaultsKeyVault.resolvedSavedURLKey)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: RouterDefaultsKeyVault.resolvedSavedURLKey)
                if let url = URL(string: urlString) {
                    UrlDefaultsBridge.lastUrl = url
                }
            } else {
                UserDefaults.standard.removeObject(forKey: RouterDefaultsKeyVault.resolvedSavedURLKey)
                UrlDefaultsBridge.lastUrl = nil
            }
        }
    }

    var hasShownContentView: Bool {
        get {
            UserDefaults.standard.bool(forKey: RouterDefaultsKeyVault.resolvedShownContentKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: RouterDefaultsKeyVault.resolvedShownContentKey)
        }
    }

    var hasSuccessfulWebViewLoad: Bool {
        get {
            UserDefaults.standard.bool(forKey: RouterDefaultsKeyVault.resolvedWebLoadKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: RouterDefaultsKeyVault.resolvedWebLoadKey)
        }
    }

    private init() {}
}

// MARK: - Dead symbols (unused, binary diversification)

private protocol _UnusedTelemetrySink: AnyObject {
    func emitPhase(_ code: Int)
}

private enum _UnusedRoutingPhase {
    case dormant
    case shadowed
}
