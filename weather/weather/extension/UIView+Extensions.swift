//
//  UIView+Extensions.swift
//  weather
//
//  Created by Gabriela Sillis on 06/08/21.
//

import Lottie
import UIKit

extension UIView {
    
    func addSubviewLottieAnimation(_ name: String) {
        let animationView = AnimationView(name: name)
        self.addSubview(animationView)
        animationView.play()
    }
}
