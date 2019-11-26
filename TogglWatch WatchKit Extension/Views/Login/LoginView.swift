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
    
    @ObservedObject var store: Store<LoginState, LoginAction, AppEnvironment>
    
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
            SecureField("Password", text: $password)
                .textContentType(.password)
                .multilineTextAlignment(.center)
            Button(action: { self.store.send(.login(self.email, self.password)) }) {
                Text("Login")
            }
            .background(Color(red: 6/255, green: 170/255, blue: 245/255))
            .cornerRadius(CGFloat(20))
        }
        .navigationBarTitle("Toggl")
        .alert(isPresented: hasError) {
            Alert(title: Text(store.state.error!.description))
        }
    }
}
