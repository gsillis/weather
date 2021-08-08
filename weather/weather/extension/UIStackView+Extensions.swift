//
//  UIStackView+Extensions.swift
//  weather
//
//  Created by Gabriela Sillis on 08/08/21.
//

import UIKit
import Lottie

extension UIStackView {
    func addStackLottieAnimation(_ name: String, index: Int) {
         let animationView = AnimationView(name: name)
        self.insertArrangedSubview(animationView, at: index)
        animationView.play()
    }
}
