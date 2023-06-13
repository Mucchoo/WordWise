//
//  ReauthentcateView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI

struct ReauthenticateView: View {
    @ObservedObject private var viewModel = ViewModel()
    @FocusState private var focus: Focus?
    @State private var error = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingAlert = false
    @State private var isShowingChangeInfo = false
    @State private var isShowingResetPassword = false
    
    enum Focus {
        case email, password
    }
    
    var body: some View {
        ZStack{
            Color("ClearColor")
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    focus = nil
                }
            VStack(spacing: 0){

                Text("ログイン")
                    .font(.headline)
                    .padding(.bottom, 10)
                    .foregroundColor(Color("FontColor"))

                Text("アカウント情報を変更するには一度ログインする必要があります。")
                    .font(.body)
                    .padding(.bottom, 20)
                    .foregroundColor(Color("FontColor"))
                    .multilineTextAlignment(.center)

                TextFieldView(title: "メールアドレス", text: $email, placeHolder: "example@example.com", isSecure: false)
                    .focused($focus, equals: .email)

                TextFieldView(title: "パスワード", text: $password, placeHolder: "password", isSecure: true)
                    .focused($focus, equals: .password)

                Button( action: {
                    error = ""
                    if email.isEmpty {
                        error = "メールアドレスが入力されていません"
                    } else if password.isEmpty {
                        error = "パスワードが入力されていません"
                    } else {
                        error = ""
                    }
                    if error.isEmpty {
                        isShowingChangeInfo = true
                    } else {
                        isShowingAlert = true
                    }
                }){
                    ButtonView(text: "ログイン").padding(.top, 20)
                }

                .sheet(isPresented: $isShowingChangeInfo) {
                    ChangeInfoView()
                }

                Button {
                    isShowingResetPassword = true
                } label: {
                    Text("パスワードを忘れた")
                        .font(.headline)
                        .padding(.top, 30)
                }

                .sheet(isPresented: $isShowingResetPassword) {
                    ResetPasswordView()
                }

                .alert(isPresented: $isShowingAlert) {
                    return Alert(title: Text(""), message: Text(error), dismissButton: .destructive(Text("OK")))
                }
                Spacer()
            }.padding(20)
        }
    }
}


struct ReauthentcateView_Previews: PreviewProvider {
    static var previews: some View {
        ReauthenticateView()
    }
}
