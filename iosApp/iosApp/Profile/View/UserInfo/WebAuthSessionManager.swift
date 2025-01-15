//
//  WebAuthSessionManager.swift
//  iosApp
//
//  Created by Sarvesh Sharma on 15/01/25.
//  Copyright © 2025 orgName. All rights reserved.
//

import AuthenticationServices
import SwiftUI

/// A helper to run ASWebAuthenticationSession from SwiftUI
final class WebAuthSessionManager: NSObject, ASWebAuthenticationPresentationContextProviding {

  private var completion: ((Result<URL, Error>) -> Void)?

  // 1) Start the ASWebAuthenticationSession
  func startAuthSession(authURL: URL,
                        callbackScheme: String,
                        completion: @escaping (Result<URL, Error>) -> Void) {
    self.completion = completion

    let session = ASWebAuthenticationSession(
      url: authURL,
      callbackURLScheme: callbackScheme
    ) { callbackURL, error in
      if let error = error {
        completion(.failure(error))
      } else if let callbackURL = callbackURL {
        completion(.success(callbackURL))
      }
    }

    session.presentationContextProvider = self
    session.start()
  }

  // 2) Provide the window anchor for the session
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    // We need a window. We can try to get the key window via UIApplication:
    // (This approach works on iOS 15/16, though Apple has changed window APIs over time.)
    guard let windowScene = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .first(where: { $0.activationState == .foregroundActive }),
          let window = windowScene.windows.first(where: { $0.isKeyWindow })
    else {
      return ASPresentationAnchor()
    }
    return window
  }
}
