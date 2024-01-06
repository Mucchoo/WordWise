//
//  AccountView.swift
//  MuscleRecord
//
//  Created by Musa Yazuju on 2022/03/25.
//

import SwiftUI

struct AccountView: View {
    @StateObject private var vm: AccountViewModel
    
    init(vm: AccountViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    MasteryRateBars(vm: .init(container: vm.container, category: ""))
                        .blurBackground()
                    
                    VStack {
                        nativeLanguageView
                        Divider()
                        navigationLinkView
                        Divider()
                        shareAppView
                        Divider()
                        feedbackView
                    }
                    .blurBackground()
                }
            }
            .gradientBackground()
            .navigationBarTitle("Account", displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var nativeLanguageView: some View {
        HStack {
            Text("Native Language")
            Spacer()
            Picker(selection: $vm.nativeLanguage, label: EmptyView(), content: {
                    ForEach(PickerOptions.language, id: \.self) { language in
                        Text(language.name).tag(language.code)
                    }
                }
            )
            .cornerRadius(15)
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    private var navigationLinkView: some View {
        HStack {
            NavigationLink("What is Mastery Rate?", destination: WhatIsMasteryRateView())
                .padding(.vertical, 8)
            Spacer()
        }
    }
    
    private var shareAppView: some View {
        Button(action: vm.showShareSheet) {
            HStack {
                Text("\(Image(systemName: "square.and.arrow.up")) Share App")
                Spacer()
            }
        }
        .accessibilityIdentifier("shareAppButton")
        .padding(.vertical, 8)
        .sheet(isPresented: $vm.isShowingShareSheet) {
            ActivityViewController(shareItems: [vm.productURL])
        }
    }
    
    private var feedbackView: some View {
        Button(action: vm.showMail) {
            HStack {
                Text("\(Image(systemName: "envelope")) Feedback")
                Spacer()
            }
        }
        .accessibilityIdentifier("feedbackButton")
        .padding(.vertical, 8)
        .sheet(isPresented: $vm.isShowingMail) {
            MailView() { result in }
        }
    }
}

#Preview {
    AccountView(vm: .init(container: .mock()))
}
