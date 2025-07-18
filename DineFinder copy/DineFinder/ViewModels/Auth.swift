//
//  Auth.swift
//  DineFinder
//
//  Created by Ana 😋 on 25/04/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth



struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var userIsLoggedIn : UserProperties
    
    var body: some View {
        if userIsLoggedIn.userIsLoggedIn {
            MainTabView()
        }else {
            content
        }
    }
    
    var content: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Fancy background diagonal card
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(
                    .linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 1000, height: 600)
                .rotationEffect(.degrees(150))
                .offset(y: -330)

            VStack(spacing: 20) {
                // Title
                Text("Welcome")
                    .foregroundColor(.white)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .offset(x: -100, y: -100)

                // Email
                TextField("Email", text: $email)
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .padding()
                    .overlay(Rectangle().frame(height: 1).padding(.top, 35))
                    .foregroundColor(.white)

                // Password
                SecureField("Password", text: $password)
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .padding()
                    .overlay(Rectangle().frame(height: 1).padding(.top, 35))
                    .foregroundColor(.white)

                // Sign Up Button
                Button {
                    register()
                } label: {
                    Text("Sign up")
                        .bold()
                        .frame(width: 200, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottomTrailing))
                        )
                        .foregroundColor(.white)
                }
                .padding(.top)
                .offset(y: 100)

                // Login Button
                Button {
                    login()
                } label: {
                    Text("Already have an account? Login")
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.top)
                .offset(y: 110)
            }
            .frame(width: 350)
//            .onAppear {
//                Auth.auth().addStateDidChangeListener { auth, user in
//                    if user != nil {
//                        userIsLoggedIn.userIsLoggedIn.toggle()
//                    }
//                }
//            }
        }
        .ignoresSafeArea()
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
            else{
                userIsLoggedIn.userIsLoggedIn = true
            }
            
        }
    }
    
    
    func register (){
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            } else{
                userIsLoggedIn.userIsLoggedIn = true
            }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(Themes())
        .environmentObject(UserProperties())
    
}

