//
//  UIView+Extension.swift
//  AceQR
//
//  Created by Roman Rakhlin on 25.05.2020.
//  Copyright © 2020 Roman Rakhlin. All rights reserved.
//

import UIKit

extension UIView {

    // Fade In Animation
    func fadeIn(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(
            withDuration: duration!,
            animations: { self.alpha = 1 },
            completion: { (value: Bool) in
                if let complete = onCompletion { complete() }
            }
        )
    }

    // Fade Out Animation
    func fadeOut(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration!,
            animations: { self.alpha = 0 },
            completion: { (value: Bool) in
                self.isHidden = true
                if let complete = onCompletion { complete() }
            }
        )
    }
}
