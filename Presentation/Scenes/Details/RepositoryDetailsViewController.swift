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

    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let avatarImageView = AsyncImageView()

    private let disposeBag = DisposeBag()
    private let viewModel: RepositoryDetailsViewModel

    public init(viewModel: RepositoryDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        output.imageViewModel
            .drive(onNext: { [unowned self] viewModel in
                avatarImageView.configure(with: viewModel, disposeBag: disposeBag)
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
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor)
        ])

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor)
        ])
    }

    func setupStyle() {
        view.backgroundColor = .red
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
    }
}
