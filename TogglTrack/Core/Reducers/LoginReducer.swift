//
//  LoginReducer.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 15/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public typealias LoginEnvironment = (api: APIProtocol, keychain: KeychainProtocol, pushTokenStorage: PushTokenStorageProtocol, firebaseAPI: FirebaseAPIProtocol)

public var loginReducer: Reducer<User?, LoginAction, LoginEnvironment, AppAction> = Reducer { state, action, userEnv in
    
    switch action {

    case let .login(email, password):
        return Effect.concat(
            Just(.setLoading(true)).eraseToEffect(),
            loginEffect(userEnv.api, email, password),
            Just(.setLoading(false)).eraseToEffect()
        )

    case let .loginWithApple(token):
        return Effect.concat(
            Just(.setLoading(true)).eraseToEffect(),
            loginEffect(userEnv.api, token),
            Just(.setLoading(false)).eraseToEffect()
        )
        
    case let .setUser(user):
        state = user
        userEnv.keychain.setApiToken(token: user.apiToken)
        userEnv.api.setAuth(token: user.apiToken)
        guard let token = userEnv.pushTokenStorage.loadAPNToken()
            else { return Just(.loadAll(force: true)).eraseToEffect() }
        return Effect.concat(
            Just(.user(.subscribeToPushNotifications(token.apnToken))).eraseToEffect(),
            Just(.loadAll(force: true)).eraseToEffect()
        )
        
    case .loadAPITokenAndUser:
        guard let token = userEnv.keychain.getApiToken() else { return .empty }
        userEnv.api.setAuth(token: token)
        return Effect.concat(
            Just(.setLoading(true)).eraseToEffect(),
            loadUserEffect(userEnv.api),
            Just(.setLoading(false)).eraseToEffect()
        )
        
    case .logout:
        state = nil
        
        return Effect.concat(
            unsubscribePushNotificationTokenFromTogglIfNeededEffect(userEnv.api, userEnv.pushTokenStorage),
            Effect.fireAndForget {
                userEnv.keychain.deleteApiToken()
                userEnv.api.setAuth(token: nil)
            },
            Effect.fromActions(
                .workspaces(.clear),
                .clients(.clear),
                .projects(.clear),
                .tasks(.clear),
                .tags(.clear),
                .timeline(.clear)
            )
        )
        
    case let .subscribeToPushNotifications(apnTokenString):
        return Effect.concat(
            unsubscribePushNotificationTokenFromTogglIfNeededEffect(userEnv.api, userEnv.pushTokenStorage, apnTokenString),
            subscribePushNotificationTokenToFCMEffect(userEnv.api, userEnv.firebaseAPI, apnTokenString)
        )

    case let .subscribedToPushNotifications(fcmToken):
        userEnv.pushTokenStorage.save(token: fcmToken)
        return .empty
    }
}

private func loginEffect(_ api: APIProtocol, _ email: String, _ password: String) -> Effect<AppAction>
{
    return api.loginUser(email: email, password: password)
        .toEffect(
            map: { user in .user(.setUser(user)) },
            catch: { error in .setError(error) }
        )
}

private func loginEffect(_ api: APIProtocol, _ token: String) -> Effect<AppAction>
{
    return api.loginUser(appleToken: token)
        .toEffect(
            map: { user in .user(.setUser(user)) },
            catch: { error in .setError(error) }
        )
}

private func loadUserEffect(_ api: APIProtocol) -> Effect<AppAction>
{
    api.loadUser()
        .toEffect(
            map: { user in .user(.setUser(user)) },
            catch: { error in .setError(error) }
        )
}

private func subscribePushNotificationTokenToFCMEffect(_ api: APIProtocol, _ firebaseAPI: FirebaseAPIProtocol, _ apnToken: String) -> Effect<AppAction>
{
    firebaseAPI.getFCMToken(for: FCMPushToken(apnToken))
        .tryFlatMap { (response) in
            guard let fcmToken = response.fcmTokens?.first else { throw UserError.NoFCMResponse }
            guard fcmToken.status == "OK" else { throw UserError.FailedToGetFCMToken(fcmToken.status) }
            guard let togglToken = fcmToken.toTogglPushToken() else { throw UserError.NoFCMTokenAvailable }
            return api.subscribePushNotification(token: togglToken)
                .map { _ in .user(.subscribedToPushNotifications(fcmToken)) }
                .eraseToAnyPublisher()
        }
        .catch { error in Just(.setError(error)) }
        .eraseToEffect()
}

private func unsubscribePushNotificationTokenFromTogglIfNeededEffect(_ api: APIProtocol, _ pushTokenStorage: PushTokenStorageProtocol, _ newAPNToken: String? = nil) -> Effect<AppAction>
{
    guard
        let oldToken = pushTokenStorage.loadAPNToken(),
        oldToken.apnToken != newAPNToken,
        let oldTogglPushToken = oldToken.toTogglPushToken()
    else {
        return .empty
    }

    return api.unsubscribePushNotification(token: oldTogglPushToken)
        .eraseToEmptyEffect(catch: { error in .setError(error) })
}

