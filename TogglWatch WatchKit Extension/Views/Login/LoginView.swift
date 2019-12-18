//
//  LoginView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 14/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import TogglTrack

struct LoginView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    
    @EnvironmentObject var store: Store<AppState, AppAction, AppEnvironment>
    
    var hasError: Binding<Bool> {
        Binding(
            get: { self.store.state.error != nil },
            set: { _ in self.store.send(.setError(nil)) }
        )
    }

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
            SecureField("Password", text: $password)
                .textContentType(.password)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
            Spacer()
            Button(action: { self.store.send(.user(.login(self.email, self.password))) }) {
                Text("Login")
            }
            .background(Color.togglBlue)
            .cornerRadius(CGFloat(20))
        }
        .navigationBarTitle("Toggl")
        .alert(isPresented: hasError) {
            Alert(title: Text(store.state.error!.description))
        }
    }
}
