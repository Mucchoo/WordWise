//
//  WhatIsMasteryRateView.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/16/23.
//

import SwiftUI

struct WhatIsMasteryRateView: View {    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Mastery Rate is the level of memory retention based on the forgetting curve theory.")
                Image("ForgettingCurve")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.leading, 10)
                    .padding(.trailing, 30)
                    .padding(.bottom)
                Text("When you see a card, you have two choices:")
                    .bold()
                HStack {
                    Text("Hard")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    Text("Easy")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom)
                Text("The card will show over and over again until you tap Easy.")
                Text("If you press Easy at the first time, Mastery Rate will proceed to next level.")
                    .bold()
                Text("If you press Hard at the first time, Mastery Rate will go back to zero.")
                    .bold()
                    .padding(.bottom)
                Text("The card is redisplayed based on the forgetting curve. Below are the mastery rates and the intervals between redisplays.")
                    .padding(.bottom)

                VStack(spacing: 0) {
                    MasteryRateTableRow(masteryRate: "Mastery Rate", interval: "Intervals")
                    customDivider()
                    MasteryRateTableRow(masteryRate: "0%", interval: "1 day")
                    customDivider()
                    MasteryRateTableRow(masteryRate: "25%", interval: "2 days")
                    customDivider()
                    MasteryRateTableRow(masteryRate: "50%", interval: "4 days")
                    customDivider()
                    MasteryRateTableRow(masteryRate: "75%", interval: "1 week")
                    customDivider()
                    MasteryRateTableRow(masteryRate: "100%", interval: "2 weeks")
                }
                .frame(width: 300)
                .border(Color.primary, width: 1)
                .padding(.bottom)
                
                Text("Review effectively according to the forgetting curve, leading to life-term memory!")
                    .padding(.bottom, 100)
            }
            .padding(.horizontal)
        }
        .navigationBarTitle("Mastery Rate", displayMode: .large)
    }
    
    func customDivider() -> some View {
        Rectangle()
            .fill(Color.primary)
            .frame(height: 1)
    }
}

struct MasteryRateTableRow: View {
    var masteryRate: String
    var interval: String

    var body: some View {
        HStack(spacing: 0) {
            Text(masteryRate)
                .frame(minWidth: 0, maxWidth: .infinity)
            Rectangle()
                .fill(Color.primary)
                .frame(width: 1)
            Text(interval)
                .frame(minWidth: 0, maxWidth: .infinity)
        }
        .frame(width: 300, height: 30)
    }
}


#Preview {
    NavigationView {
        WhatIsMasteryRateView()
            .injectMockDataViewModelForPreview()
    }
}
