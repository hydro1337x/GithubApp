//
//  UIViewController+ToastView.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 09.08.2022..
//

import UIKit

extension UIViewController {
    private var padding: CGFloat { 8 }
    private var delayInSeconds: DispatchTime { DispatchTime.now() + 5 }

    func showToast(with message: String) {
        let view = makeToastView(with: message)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            view.alpha = 1
        }, completion: { [hideToastViewAfterDeadline] _ in
            hideToastViewAfterDeadline(view)
        })
    }

    private func hideToastViewAfterDeadline(_ view: UIView) {
        DispatchQueue.main.asyncAfter(deadline: delayInSeconds) { [animateToastViewHidding] in
            animateToastViewHidding(view)
        }
    }

    private func animateToastViewHidding(_ view: UIView) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            view.alpha = 0
        } completion: { _ in
            view.removeFromSuperview()
        }
    }

    private func makeToastView(with message: String) -> UIView {
        let toastView = ToastView()
        toastView.alpha = 0
        toastView.layer.cornerRadius = 4
        toastView.clipsToBounds = true
        let bottomOffset = view.safeAreaInsets.bottom
        toastView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastView)
        NSLayoutConstraint.activate([
            toastView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            toastView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            toastView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(bottomOffset + padding))
        ])
        toastView.configure(with: message)
        return toastView
    }
}
