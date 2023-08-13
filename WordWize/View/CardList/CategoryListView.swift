//
//  CategoryListView.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/13/23.
//

import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var dataViewModel: DataViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(dataViewModel.categories) { category in
                        VStack {
                            HStack(alignment: .top) {
                                NavigationLink(destination: AccountView()){
                                    Image(systemName: "ellipsis.circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.blue)
                                }
                                Text(category.name ?? "")
                                    .fontWeight(.bold)
                                    .lineLimit(2)
                                    .foregroundColor(Color("FontColor"))
                                Spacer()
                                NavigationLink(destination: AccountView()){
                                    Image(systemName: "pencil.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                }
                            }.frame(minHeight: 43)
                            Spacer()
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("重量")
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("FontColor"))
                                    Text("回数")
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("FontColor"))
                                }
                                Spacer()
                                NavigationLink(destination: AccountView()) {
                                    Text("グラフを見る ▶︎")
                                        .foregroundColor(.blue)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .frame(maxHeight: 110)
                        .padding(20)
                        .background(Color("CellColor"))
                        .cornerRadius(20)
                        .shadow(color: Color("FontColor").opacity(0.5), radius: 4, x: 0, y: 2)
                        .padding(.top, 5)
                        .padding(.horizontal, 10)
                        Spacer()
                    }
                }
                .padding(.top, 10)
            }
            .background(Color("BackgroundColor"))
            .navigationBarTitle("筋トレ記録", displayMode: .inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    CategoryListView()
}
