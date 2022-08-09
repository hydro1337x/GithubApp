//
//  ToastView.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 09.08.2022..
//

import UIKit

final class ToastView: UIView {
    enum Dimension {
        static let imageViewSpan: CGFloat = 24
        static let padding: CGFloat = 8
        static let minimumHeight: CGFloat = imageViewSpan + 2 * padding
    }

    private let imageView = UIImageView()
    private let label = UILabel()

    init() {
        super.init(frame: .zero)
        setupLayout()
        setupStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with title: String) {
        label.text = title
    }
}

extension ToastView: ViewConstructing {
    func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Dimension.padding),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: Dimension.imageViewSpan),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1)
        ])

        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: Dimension.padding),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Dimension.padding),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Dimension.padding),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Dimension.padding),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: Dimension.minimumHeight)
        ])
    }

    func setupStyle() {
        backgroundColor = .systemOrange

        imageView.image = UIImage(systemName: "exclamationmark.bubble.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit

        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
    }
}
