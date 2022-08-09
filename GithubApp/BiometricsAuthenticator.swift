//
//  BiometricsAuthenticator.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import LocalAuthentication
import RxSwift
import Domain

protocol Authenticator {
    func evaluate() -> Completable
}

final class BiometricsAuthenticator: Authenticator {
    private var context = LAContext()

    init() {
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    func evaluate() -> Completable {
        context = LAContext()

        context.localizedCancelTitle = "Enter Email/Password"

        return Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }

            var error: NSError?

            guard self.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                observer(.error(error ?? AuthenticationFailedError()))
                
                return Disposables.create()
            }

            self.context
                .evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in to your account") { isSuccessful, error in
                guard isSuccessful else { return observer(.error(error ?? AuthenticationFailedError())) }

                observer(.completed)
            }

            return Disposables.create()
        }
    }
}
