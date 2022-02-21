//
//  ContentView.swift
//  dialog
//
//  Created by 宮本光直 on 2022/02/16.
//

import SwiftUI

struct ContentView: View {
    
    @State var isPresented: Bool = false
    
    var body: some View {
        VStack {
            Button (action: {
                isPresented = true
            }) {
                Text("open")
                    .foregroundColor(Color.white)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 250, height: 50)
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .background(Color.white)
        .fullOverFullScreenView(isPresented: $isPresented){
            ModalView(isPresented: $isPresented)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
