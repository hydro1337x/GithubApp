//
//  AsyncImageView.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import UIKit
import RxCocoa
import RxSwift

final class AsyncImageView: UIView {
    enum Dimension {
        static let retryButtonSpan: CGFloat = 44
    }

    let retryButton = UIButton(type: .custom)
    let imageView = UIImageView()
    let blurView = UIVisualEffectView()
    let placeholderImage = UIImage(systemName: "person.circle")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.layer.cornerRadius = blurView.frame.height / 2
    }

    func configure(with viewModel: AsyncImageViewModel, disposeBag: DisposeBag) {
        setupSubscriptions(with: viewModel, disposeBag: disposeBag)
    }

    private func setupSubscriptions(with viewModel: AsyncImageViewModel, disposeBag: DisposeBag) {
        let retryTrigger = retryButton.rx
            .tap
            .asSignal(onErrorSignalWith: .empty())

        let input = AsyncImageViewModel.Input(
            initialTrigger: .just(()),
            retryTrigger: retryTrigger
        )
        let output = viewModel.transform(input: input)

        output.state
            .asObservable()
            .take(1)
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] state in
                guard let self = self else { return }
                self.handleStateTransition(state)
            })
            .disposed(by: disposeBag)

        output.state
            .skip(1)
            .drive(onNext: { [weak self] state in
                guard let self = self else { return }
                self.animateStateTransition(state)
            })
            .disposed(by: disposeBag)
    }

    private func handleStateTransition(_ state: AsyncImageState) {
        let st = AsyncImageState.failed
        switch st {
        case .initial:
            blurView.isHidden = true
            imageView.image = placeholderImage
        case .loaded(let data):
            blurView.isHidden = true
            imageView.image = UIImage(data: data)
        case .failed:
            blurView.isHidden = false
            imageView.image = placeholderImage
        }
    }

    private func animateStateTransition(_ state: AsyncImageState) {
        self.handleStateTransition(state)
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: { [self] in
            handleStateTransition(state)
            layoutIfNeeded()
        }, completion: nil)
    }
}

extension AsyncImageView: ViewConstructing {
    func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.centerXAnchor.constraint(equalTo: centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: centerYAnchor),
            blurView.heightAnchor.constraint(lessThanOrEqualToConstant: Dimension.retryButtonSpan),
            blurView.widthAnchor.constraint(equalTo: blurView.heightAnchor, multiplier: 1),
            blurView.topAnchor.constraint(lessThanOrEqualTo: topAnchor).withPriority(.defaultHigh),
            blurView.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor).withPriority(.defaultHigh),
            blurView.trailingAnchor.constraint(lessThanOrEqualTo: leadingAnchor).withPriority(.defaultHigh),
            blurView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).withPriority(.defaultHigh)
        ])

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(retryButton)
        NSLayoutConstraint.activate([
            retryButton.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            retryButton.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            retryButton.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            retryButton.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor)
        ])
    }

    func setupStyle() {
        imageView.contentMode = .scaleAspectFit

        let retryImage = UIImage(systemName: "arrow.clockwise")
        retryButton.setImage(retryImage, for: .normal)
        retryButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        retryButton.imageView?.contentMode = .scaleAspectFit

        blurView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        blurView.clipsToBounds = true
    }
}
