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
    
    @ObservedObject var store: Store<UserState, UserAction, AppEnvironment>
    
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
            TextField("Password", text: $password)
                .textContentType(.password)
            Button(action: { self.store.send(.login(self.email, self.password)) }) {
                Text("Login")
            }
            .background(/*@START_MENU_TOKEN@*/Color.red/*@END_MENU_TOKEN@*/)
            .cornerRadius(CGFloat(20))
        }
        .navigationBarTitle("Toggl Login")
        .alert(isPresented: hasError) {
            Alert(title: Text(store.state.error!.description))
        }
    }
}
