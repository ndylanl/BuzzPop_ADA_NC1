//
//  ContentView.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 24/04/24.
//

import SwiftUI

struct ContentView: View {
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(red: 20/255, green: 25/255, blue: 35/255, alpha: 0.99)
        UITabBar.appearance().barTintColor = UIColor.gray
        }
    
    var body: some View{
        MainMenuView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
