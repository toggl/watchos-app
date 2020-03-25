//
//  SignInWithAppleService.swift
//  TogglWatch WatchKit Extension
//
//  Created by Juan Laube on 3/3/20.
//  Copyright © 2020 Toggl. All rights reserved.
//

import Foundation
import Combine
import AuthenticationServices

public protocol SignInWithAppleServiceProtocol {
    func getToken() -> AnyPublisher<String, Error>
}

public class SignInWithAppleService: NSObject, SignInWithAppleServiceProtocol, ASAuthorizationControllerDelegate {

    private var subject: PassthroughSubject<String, Error>!

    public func getToken() -> AnyPublisher<String, Error> {
        subject = PassthroughSubject()

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()

        return subject.eraseToAnyPublisher()
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        guard let tokenData = credential.identityToken else { return }
        guard let token = String(data: tokenData, encoding: .utf8) else { return }
        subject.send(token)
        subject.send(completion: .finished)
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Don't return an error if the user cancelled or when the user is not signed in with the apple id
        if let error = error as? ASAuthorizationError, error.code == .canceled || error.code == .unknown {
            return
        }
        subject.send(completion: .failure(error))
    }
}
