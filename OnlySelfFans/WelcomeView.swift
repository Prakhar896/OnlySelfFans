//
//  WelcomeView.swift
//  OnlySelfFans
//
//  Created by Prakhar Trivedi on 26/6/23.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .center) {
            Image("OnlySelfFansIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(10)
                .shadow(radius: 5)
            
            Text("OnlySelfFans")
                .font(.largeTitle.weight(.heavy))
                .padding(.bottom, 80)
            
            Text("OnlySelfFans is an app that allows you to customise notifications for yourself!\nYou can choose the title, body, time interval/date of notification and more!\n\nMight be useful when you need to interrupt your 4 hour long texting spree! ;)\n\nDeveloped with ❤️ by Prakhar Trivedi")
                .padding(.bottom, 70)
                .multilineTextAlignment(.center)
            
            Button {
                AppManager.firstLaunchCompleted()
                dismiss()
            } label: {
                Text("Continue")
                    .foregroundColor(.white)
                    .frame(width: 0.7 * UIScreen.main.bounds.width, height: 44)
                    .background(.blue)
                    .bold()
                    .cornerRadius(15)
            }
        }
        .padding(20)
        .interactiveDismissDisabled()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
