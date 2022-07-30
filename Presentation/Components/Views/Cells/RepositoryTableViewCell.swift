//
//  RepositoryTableViewCell.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import UIKit

final class RepositoryTableViewCell: UITableViewCell {

    let avatarImageView = UIImageView()
    let ownerNameLabel = UILabel()
    let nameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: RepositoryViewModel) {
        self.nameLabel.text = viewModel.name
        self.ownerNameLabel.text = viewModel.ownerName
    }

}

extension RepositoryTableViewCell: ViewConstructing {
    func setupLayout() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            avatarImageView.heightAnchor.constraint(equalToConstant: 20),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor)
        ])

        ownerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ownerNameLabel)
        NSLayoutConstraint.activate([
            ownerNameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            ownerNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            ownerNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 8)
        ])

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: ownerNameLabel.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func setupStyle() {
        avatarImageView.image = UIImage(systemName: "pencil")
        avatarImageView.layer.cornerRadius = 8
        avatarImageView.clipsToBounds = true

        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
}
