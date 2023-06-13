//
//  ResetPasswordView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel = ViewModel()
    @FocusState private var focus: Bool
    @State private var email = ""
    @State private var errorMessage = ""
    @State private var isSignedIn = false
    @State private var isShowingAlert = false
    
    var body: some View {
        ZStack{

            Color("ClearColor")
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    focus = false
                }
            VStack(spacing: 0){

                Text("パスワードを再設定")
                    .font(.headline)
                    .padding(.bottom, 20)
                    .foregroundColor(Color("FontColor"))

                TextFieldView(title: "メールアドレス", text: $email, placeHolder: "example@example.com", isSecure: false)
                    .focused($focus)

                Button( action: {
                    errorMessage = ""
                    if email.isEmpty {
                        errorMessage = "メールアドレスが入力されていません"
                    }
                    isShowingAlert = true
                }){
                    ButtonView(text: "パスワードを再設定").padding(.top, 20)
                }
                .alert(isPresented: $isShowingAlert) {
                    if errorMessage.isEmpty {
                        return Alert(title: Text("メールを送信しました"), message: Text("受け取ったメールを開いてパスワードを再設定してください。"), dismissButton: .default(Text("OK"), action: {
                            dismiss()
                        }))
                    } else {
                        return Alert(title: Text("エラーが発生しました"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    }
                }
                Spacer()
            }.padding(20)

        }.onAppear {
            focus = true
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
