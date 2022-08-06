//
//  RepositoryTableViewCell.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import UIKit
import RxSwift

final class RepositoryTableViewCell: UITableViewCell {

    enum Dimension {
        static let padding: CGFloat = 8
        static let imageSpan: CGFloat = 40
        static let spacing: CGFloat = 8
        static let tupleViewSpacing: CGFloat = 2
    }

    let avatarImageView = AsyncImageView()
    let ownerNameLabel = UILabel()
    let nameLabel = UILabel()
    let stackView = UIStackView()

    private var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        disposeBag = DisposeBag()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func configure(with viewModel: RepositoryViewModel) {
        self.nameLabel.text = viewModel.name
        self.ownerNameLabel.text = viewModel.ownerName

        avatarImageView.configure(with: viewModel.imageViewModel, disposeBag: disposeBag)

        let tuples = [
            ("smallcircle.filled.circle", viewModel.openIssuesCount),
            ("arrow.triangle.branch", viewModel.forksCount),
            ("star", viewModel.stargazersCount),
            ("eye", viewModel.watchersCount)
        ]

        tuples.forEach {
            stackView.addArrangedSubview(
                makeTupleView(
                    imageName: $0.0,
                    text: $0.1
                )
            )
        }
    }

}

extension RepositoryTableViewCell: ViewConstructing {
    func setupLayout() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Dimension.padding),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Dimension.padding),
            avatarImageView.heightAnchor.constraint(equalToConstant: Dimension.imageSpan),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor)
        ])

        ownerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ownerNameLabel)
        NSLayoutConstraint.activate([
            ownerNameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            ownerNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Dimension.padding),
            ownerNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Dimension.padding)
        ])

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Dimension.padding),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: ownerNameLabel.trailingAnchor)
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Dimension.padding),
            stackView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: nameLabel.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Dimension.padding).withPriority(.defaultHigh)
        ])
    }

    func setupStyle() {
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.cornerRadius = Dimension.imageSpan / 2
        avatarImageView.layer.borderWidth = 1
        avatarImageView.clipsToBounds = true

        nameLabel.numberOfLines = 2
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)

        stackView.spacing = Dimension.spacing
    }

    private func makeTupleView(imageName: String, text: String) -> UIView {
        let stackView = UIStackView()
        stackView.backgroundColor = .secondarySystemBackground
        stackView.spacing = Dimension.tupleViewSpacing
        stackView.axis = .horizontal

        let image = UIImage(systemName: imageName)
        let imageView = UIImageView(image: image)

        stackView.addArrangedSubview(imageView)

        let label = UILabel()
        label.text = text

        stackView.addArrangedSubview(label)

        return stackView
    }
}
