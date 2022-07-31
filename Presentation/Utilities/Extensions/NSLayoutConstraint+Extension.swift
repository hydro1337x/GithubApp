//
//  NSLayoutConstraint+Extension.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import UIKit

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}
