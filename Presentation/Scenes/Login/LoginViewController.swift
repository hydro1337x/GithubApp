//
//  LoginViewController.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import UIKit
import RxSwift
import RxCocoa

public final class LoginViewController: UIViewController {
    enum Dimension {
        static let padding: CGFloat = 36
        static let textFieldHeight: CGFloat = 44
        static let buttonHeight: CGFloat = 44
        static let stackViewSpacing: CGFloat = 8
        static let stackViewOffset: CGFloat = 50
        static let subStackViewSpacing: CGFloat = 2
    }

    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let emailTextField = UITextField()
    let emailValidityLabel = UILabel()
    let passwordTextField = UITextField()
    let passwordValidityLabel = UILabel()
    let loginButton = UIButton(type: .system)
    let activityIndicatorView = UIActivityIndicatorView()
    let toggleSecureEntryButton = UIButton(type: .system)

    private let viewModel: LoginViewModel
    private let disposeBag = DisposeBag()

    public init(viewModel: LoginViewModel) {
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
        let email = emailTextField.rx
            .text
            .orEmpty
            .skip(1)
            .asDriver(onErrorDriveWith: .empty())
            .distinctUntilChanged()

        let password = passwordTextField.rx
            .text
            .orEmpty
            .skip(1)
            .asDriver(onErrorDriveWith: .empty())
            .distinctUntilChanged()

        let loginTap = loginButton.rx
            .tap
            .asSignal()

        let input = LoginViewModel.Input(
            email: email,
            password: password,
            loginTrigger: loginTap
        )

        let output = viewModel.transform(input: input)

        output.emailValidation
            .drive(onNext: { [unowned self] state in
                switch state {
                case .empty: break
                case .valid: emailValidityLabel.text = ""
                case .invalid(let message): emailValidityLabel.text = message
                }
            })
            .disposed(by: disposeBag)

        output.passwordValidation
            .drive(onNext: { [unowned self] state in
                switch state {
                case .empty: break
                case .valid: passwordValidityLabel.text = ""
                case .invalid(let message): passwordValidityLabel.text = message
                }
            })
            .disposed(by: disposeBag)

        output.areInputsValid
            .drive(onNext: { [unowned self] areInputsValid in
                loginButton.isEnabled = areInputsValid
                loginButton.alpha = areInputsValid ? 1 : 0.5
            })
            .disposed(by: disposeBag)

        output.loginState
            .drive(onNext: { [unowned self] state in
                handleLoginState(state)
            })
            .disposed(by: disposeBag)

        toggleSecureEntryButton.rx
            .tap
            .scan(true) { previous, _ in
                !previous
            }
            .startWith(true)
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [unowned self] toggle in
                let image = UIImage(systemName: toggle ? "eye" : "eye.slash")
                toggleSecureEntryButton.setImage(image, for: .normal)
                passwordTextField.isSecureTextEntry = toggle
            })
            .disposed(by: disposeBag)
    }

    private func handleLoginState(_ state: DiscardableDataState) {
        switch state {
        case .initial:
            break
        case .loading:
            activityIndicatorView.startAnimating()
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
            [emailTextField, passwordTextField].forEach {
                $0.isEnabled = false
            }
        case .loaded:
            activityIndicatorView.stopAnimating()
            loginButton.isEnabled = true
            loginButton.alpha = 1
            [emailTextField, passwordTextField].forEach {
                $0.isEnabled = true
            }
        case .failed(let message):
            activityIndicatorView.stopAnimating()
            loginButton.isEnabled = true
            loginButton.alpha = 1
            [emailTextField, passwordTextField].forEach {
                $0.isEnabled = true
            }
            print("ERROR: ", message)
        }
    }
}

extension LoginViewController: ViewConstructing {

    func setupLayout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
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
            stackView.topAnchor.constraint(lessThanOrEqualTo: scrollView.topAnchor, constant: Dimension.stackViewOffset),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Dimension.padding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Dimension.padding),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])

        [emailTextField, passwordTextField].forEach {
            $0.heightAnchor.constraint(equalToConstant: Dimension.textFieldHeight).isActive = true
        }

        passwordTextField.rightView = toggleSecureEntryButton

        let emailSubStackView = makeSubStackView(with: emailTextField, emailValidityLabel)
        stackView.addArrangedSubview(emailSubStackView)
        let passwordSubStackView = makeSubStackView(with: passwordTextField, passwordValidityLabel)
        stackView.addArrangedSubview(passwordSubStackView)

        loginButton.heightAnchor.constraint(equalToConstant: Dimension.buttonHeight).isActive = true
        stackView.addArrangedSubview(loginButton)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func setupStyle() {

        view.backgroundColor = .systemBackground

        stackView.axis = .vertical
        stackView.spacing = Dimension.stackViewSpacing
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing

        emailTextField.placeholder = "Email"

        passwordTextField.placeholder = "Password"
        passwordTextField.rightViewMode = .always

        [emailTextField, passwordTextField].forEach {
            $0.borderStyle = .roundedRect
        }

        [emailValidityLabel, passwordValidityLabel].forEach {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .light)
            $0.textColor = UIColor.systemOrange
        }

        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.layer.cornerRadius = Dimension.buttonHeight / 2
        loginButton.clipsToBounds = true

        activityIndicatorView.style = .large
        activityIndicatorView.hidesWhenStopped = true

        toggleSecureEntryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
    }

    private func makeSubStackView(with views: UIView...) -> UIView {
        let stackView = UIStackView()

        stackView.axis = .vertical
        stackView.spacing = Dimension.stackViewSpacing
        views.forEach {
            stackView.addArrangedSubview($0)
        }

        return stackView
    }
}
