//
//  RepositoryDetailsViewController.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import UIKit
import RxSwift
import RxCocoa

public final class RepositoryDetailsViewController: UIViewController {
    enum Dimension {
        static let padding: CGFloat = 8
        static let imageSpan: CGFloat = 150
        static let spacing: CGFloat = 8
        static let tupleViewSpacing: CGFloat = 2
        static let likeButtonPointSize: CGFloat = 24
    }

    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let avatarImageView = AsyncImageView()
    let activityIndicatorView = UIActivityIndicatorView()
    let likeButton = UIButton(type: .system)

    private let disposeBag = DisposeBag()
    private let viewModel: RepositoryDetailsViewModel

    public init(viewModel: RepositoryDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("Deinited: \(String(describing: self))")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupStyle()
        setupSubscriptions()
    }

    private func setupSubscriptions() {
        let trigger = Signal.just(())

        let input = RepositoryDetailsViewModel.Input(trigger: trigger)

        let output = viewModel.transform(input: input)

        output.state
            .drive(onNext: { [unowned self] state in
                switch state {
                case .initial:
                    break
                case .loading:
                    activityIndicatorView.startAnimating()
                case .loaded(let model):
                    activityIndicatorView.stopAnimating()
                    makeLoadedStateLayout(with: model)

                case .failed(let message):
                    activityIndicatorView.stopAnimating()
                    print("ERROR: ", message)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension RepositoryDetailsViewController: ViewConstructing {
    func setupLayout() {

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Dimension.padding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Dimension.padding),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: Dimension.imageSpan),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor)
        ])

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func setupStyle() {
        view.backgroundColor = .systemBackground
        
        stackView.axis = .vertical
        stackView.spacing = Dimension.spacing
        stackView.alignment = .center
        stackView.distribution = .equalSpacing

        activityIndicatorView.style = .large
        activityIndicatorView.hidesWhenStopped = true

    }

    private func makeLoadedStateLayout(with model: RepositoryDetailsModel) {

        avatarImageView.configure(with: model.ownerImageViewModel, disposeBag: disposeBag)

        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: Dimension.likeButtonPointSize)
        likeButton.setImage(UIImage(systemName: "heart", withConfiguration: imageConfiguration), for: .normal)
        let titleLabel = makeLabel(with: model.name, font: .systemFont(ofSize: 20, weight: .medium))
        let titleWithLikeButtonView = makeSubStackView(with: [titleLabel, likeButton])
        stackView.addArrangedSubview(titleWithLikeButtonView)

        stackView.addArrangedSubview(makeLabel(with: model.ownerName, font: .systemFont(ofSize: 16)))

        let firstRowTuples = [
            ("bell", model.subscribersCount),
            ("smallcircle.filled.circle", model.openIssuesCount)
        ]

        let firstTupleViewsBatch = firstRowTuples.map {
            makeTupleView(imageName: $0.0, text: $0.1)
        }

        stackView.addArrangedSubview(makeSubStackView(with: firstTupleViewsBatch))

        let secondRowTuples = [
            ("arrow.triangle.branch", model.forksCount),
            ("star", model.stargazersCount),
            ("eye", model.watchersCount)
        ]

        let secondTupleViewsBatch = secondRowTuples.map {
            makeTupleView(imageName: $0.0, text: $0.1)
        }

        stackView.addArrangedSubview(makeSubStackView(with: secondTupleViewsBatch))

        if let description = model.description {
            stackView.addArrangedSubview(makeLabel(with: description, font: .systemFont(ofSize: 14)))
        }

        let createdAtTitleLabel = makeLabel(with: viewModel.createdAtTitle, font: .systemFont(ofSize: 14, weight: .medium))
        let createAtLabel = makeLabel(with: model.createdAt, font: .systemFont(ofSize: 14))
        stackView.addArrangedSubview(makeSubStackView(with: [createdAtTitleLabel, createAtLabel]))


        let updatedAtTitleLabel = makeLabel(with: viewModel.updatedAtTitle, font: .systemFont(ofSize: 14, weight: .medium))
        let updatedAtLabel = makeLabel(with: model.updatedAt, font: .systemFont(ofSize: 14))
        stackView.addArrangedSubview(makeSubStackView(with: [updatedAtTitleLabel, updatedAtLabel]))
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

    private func makeSubStackView(with views: [UIView]) -> UIView {
        let stackView = UIStackView()

        stackView.axis = .horizontal
        stackView.spacing = Dimension.spacing
        views.forEach {
            stackView.addArrangedSubview($0)
        }

        return stackView
    }

    private func makeLabel(with text: String, font: UIFont) -> UIView {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = font
        label.text = text
        return label
    }
}
