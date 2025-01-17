//
//  ProfileOptionsView.swift
//  iosApp
//
//  Created by Sarvesh Sharma on 04/01/25.
//  Copyright © 2025 orgName. All rights reserved.
//

import SwiftUI

struct ProfileOptionsView: View {
  @Environment(\.openURL) private var openURL

  var body: some View {
    ForEach(Constants.options.indices, id: \.self) { index in
      let option = Constants.options[index]
      Button {
        if let url = URL(string: option.redirection) {
          openURL(url)
        }
      } label: {
        HStack(spacing: Constants.hStackSpacing) {
          option.image
            .frame(width: Constants.iconSize, height: Constants.iconSize)
          Text(option.text)
            .font(Constants.font)
            .foregroundColor(Constants.textColor)
          Spacer()
          Image(systemName: "chevron.right")
            .foregroundColor(.white)
        }
        .padding([.horizontal], Constants.hStackPadding)
      }
    }
  }

  struct Options {
    let image: Image
    let text: String
    let redirection: String
  }
}

#Preview {
  ProfileOptionsView()
}

extension ProfileOptionsView {
  enum Constants {
    static let options = [
      Options(
        image: Image("option_chat"),
        text: "Talk to the Team",
        redirection: "https://t.me/+c-LTX0Cp-ENmMzI1"
      ),
      Options(
        image: Image("option_tnc"),
        text: "Terms of service",
        redirection: "https://yral.com/terms-of-service"
      ),
      Options(
        image: Image("option_privacy"),
        text: "Privacy Policy",
        redirection: "https://yral.com/privacy-policy"
      )
    ]
    static let hStackSpacing: CGFloat = 16
    static let hStackPadding: CGFloat = 16
    static let iconSize: CGFloat = 24
    static let font = Font.custom("Kumbh Sans", size: 16)
      .weight(.medium)
    static let textColor = Color.white
  }
}
