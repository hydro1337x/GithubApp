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
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let emailTextField = UITextField()
    let emailValidityLabel = UILabel()
    let passwordTextField = UITextField()
    let passwordValidityLabel = UILabel()
    let repeatedPasswordTextField = UITextField()
    let repeatedPasswordValidityLabel = UILabel()
    let passwordsMatchValidityLabel = UILabel()
    let loginButton = UIButton(type: .system)
    let activityIndicatorView = UIActivityIndicatorView()

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

        let repeatedPassword = repeatedPasswordTextField.rx
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
            repeatedPassword: repeatedPassword,
            loginTap: loginTap
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

        output.repeatedPasswordValidation
            .drive(onNext: { [unowned self] state in
                switch state {
                case .empty: break
                case .valid: repeatedPasswordValidityLabel.text = ""
                case .invalid(let message): repeatedPasswordValidityLabel.text = message
                }
            })
            .disposed(by: disposeBag)

        output.passwordsMatchValidation
            .drive(onNext: { [unowned self] state in
                switch state {
                case .empty: break
                case .valid: passwordsMatchValidityLabel.text = ""
                case .invalid(let message): passwordsMatchValidityLabel.text = message
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
    }

    private func handleLoginState(_ state: DiscardableDataState) {
        switch state {
        case .initial:
            break
        case .loading:
            activityIndicatorView.startAnimating()
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
            [emailTextField, passwordTextField, repeatedPasswordTextField].forEach {
                $0.isEnabled = false
            }
        case .loaded:
            activityIndicatorView.stopAnimating()
            loginButton.isEnabled = true
            loginButton.alpha = 1
            [emailTextField, passwordTextField, repeatedPasswordTextField].forEach {
                $0.isEnabled = true
            }
        case .failed(let message):
            activityIndicatorView.stopAnimating()
            loginButton.isEnabled = true
            loginButton.alpha = 1
            [emailTextField, passwordTextField, repeatedPasswordTextField].forEach {
                $0.isEnabled = true
            }
            // TODO: - Handle error and test it
            print("ERROR: ", message)
        }
    }
}

extension LoginViewController: ViewConstructing {

    func setupLayout() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(lessThanOrEqualTo: scrollView.topAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 36),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -36),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])

        [emailTextField, passwordTextField, repeatedPasswordTextField].forEach {
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }

        let emailSubStackView = makeSubStackView(with: emailTextField, emailValidityLabel)
        stackView.addArrangedSubview(emailSubStackView)
        let passwordSubStackView = makeSubStackView(with: passwordTextField, passwordValidityLabel)
        stackView.addArrangedSubview(passwordSubStackView)
        let repeatedPasswordSubStackView = makeSubStackView(with: repeatedPasswordTextField, repeatedPasswordValidityLabel)
        stackView.addArrangedSubview(repeatedPasswordSubStackView)
        stackView.addArrangedSubview(passwordsMatchValidityLabel)
        stackView.addArrangedSubview(loginButton)

        view.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func setupStyle() {

        view.backgroundColor = .systemBackground

        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing

        emailTextField.placeholder = "Email"

        passwordTextField.placeholder = "Password"

        repeatedPasswordTextField.placeholder = "Repeated password"

        [emailTextField, passwordTextField, repeatedPasswordTextField].forEach {
            $0.borderStyle = .roundedRect
        }

        [emailValidityLabel, passwordValidityLabel, repeatedPasswordValidityLabel, passwordsMatchValidityLabel].forEach {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .light)
        }

        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.blue, for: .normal)
        loginButton.backgroundColor = .red

        activityIndicatorView.style = .large
        activityIndicatorView.hidesWhenStopped = true
    }

    private func makeSubStackView(with views: UIView...) -> UIView {
        let stackView = UIStackView()

        stackView.axis = .vertical
        stackView.spacing = 2
        views.forEach {
            stackView.addArrangedSubview($0)
        }

        return stackView
    }
}
