//
//  ChangeInfoView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI

struct ChangeInfoView: View {
    @ObservedObject private var viewModel = ViewModel()
    @FocusState private var focus: Focus?
    @State private var error = ""
    @State private var email = ""
    @State private var confirm = ""
    @State private var password = ""
    @State private var isShowingEmailAlert = false
    @State private var isShowingPasswordAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    enum Focus {
        case email, password, confirm
    }
    
    var body: some View {
        SimpleNavigationView(title: "アカウント情報変更") {
            ZStack{
                Color("ClearColor")
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        focus = nil
                    }
                VStack(spacing: 0){

                    TextFieldView(title: "新しいメールアドレス", text: $email, placeHolder: "example@example.com", isSecure: false)
                        .focused($focus, equals: .email)

                    Button( action: {
                        if email.isEmpty {
                            error = "メールアドレスが入力されていません"
                        } else {
                            error = ""
                        }
                        isShowingEmailAlert = true
                    }, label: {
                        ButtonView(text: "メールアドレスを変更").padding(.vertical, 20)
                    })
                    .alert(isPresented: $isShowingEmailAlert) {
                        if error.isEmpty {
                            return Alert(title: Text("メールアドレスが更新されました"), message: Text(""), dismissButton: .default(Text("OK"), action: {
                                presentationMode.wrappedValue.dismiss()
                            }))
                        } else {
                            return Alert(title: Text(error), message: Text(""), dismissButton: .default(Text("OK")))
                        }
                    }

                    TextFieldView(title: "新しいパスワード", text: $password, placeHolder: "password", isSecure: true)
                        .focused($focus, equals: .password)
                    TextFieldView(title: "確認用パスワード", text: $confirm, placeHolder: "password", isSecure: true)
                        .focused($focus, equals: .confirm)

                    Button( action: {
                        if password.isEmpty {
                            error = "パスワードが入力されていません"
                        } else if confirm.isEmpty {
                            error = "確認用パスワードが入力されていません"
                        } else if password.compare(self.confirm) != .orderedSame {
                            error = "パスワードと確認パスワードが一致しません"
                        } else {
                            error = ""
                        }
                        isShowingPasswordAlert = true
                    }, label: {
                        ButtonView(text: "パスワードを変更").padding(.top, 20)
                    })
                    .alert(isPresented: $isShowingPasswordAlert) {
                        if error.isEmpty {
                            return Alert(title: Text("パスワードが更新されました"), message: Text(""), dismissButton: .default(Text("OK"), action: {
                                presentationMode.wrappedValue.dismiss()
                            }))
                        } else {
                            return Alert(title: Text(error), message: Text(""), dismissButton: .default(Text("OK")))
                        }
                    }
                    Spacer()
                }
                .padding(20)
            }
        }
    }
}


struct ChangeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeInfoView()
    }
}
