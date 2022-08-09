//
//  ActivityIndicatorTableViewCell.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 03.08.2022..
//

import Foundation

import UIKit

final class ActivityIndicatorTableViewCell: UITableViewCell {

    enum Dimension {
        static let padding: CGFloat = 12
    }

    let activityIndicatorView = UIActivityIndicatorView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        if !activityIndicatorView.isAnimating {
            activityIndicatorView.startAnimating()
        }
    }
}

extension ActivityIndicatorTableViewCell: ViewConstructing {
    func setupLayout() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: Dimension.padding),
            activityIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Dimension.padding)
        ])
    }

    func setupStyle() {
        activityIndicatorView.style = .large
    }
}
