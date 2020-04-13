//
//  OnboardingView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Juan Laube on 2/24/20.
//  Copyright © 2020 Toggl. All rights reserved.
//

import SwiftUI
import AuthenticationServices
import TogglTrack

struct OnboardingView: View {

    @EnvironmentObject var store: Store<AppState, AppAction, AppEnvironment>

    var hasError: Binding<Bool> {
        Binding(
            get: shouldPresentError,
            set: { _ in self.store.send(.setError(nil)) }
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Image("togglLogo")
            VStack {
                Button(action: { self.store.send(.user(.getLoginWithAppleToken)) }) {
                    Text(" Sign in")
                }
                .background(Color.togglBlue)
                .cornerRadius(20)
                NavigationLink(destination: LoginView().environmentObject(store)) {
                    Text("Email sign in")
                }
                .cornerRadius(20)
            }
        }
        .padding(.top, 10)
        .alert(isPresented: hasError) {
            Alert(title: errorMessage,
                  dismissButton: ActionSheet.Button.default(Text("OK"), action: { self.store.send(.setError(nil)) }))
        }
    }

    var errorMessage: Text {
        if case .wrongStatus(403, _) = store.state.error as? NetworkingError {
            return Text("Sign up on iOS first")
        }
        else if store.state.error is ASAuthorizationError {
            return Text("Sign in with Apple failed")
        }
        return Text("Sign in failed")
    }

    private func shouldPresentError() -> Bool {
        if case .wrongStatus(403, _) = store.state.error as? NetworkingError {
            return true
        }
        else if store.state.error is ASAuthorizationError {
            return true
        }
        else {
            return false
        }
    }
}
