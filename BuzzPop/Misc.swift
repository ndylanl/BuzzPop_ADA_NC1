//
//  Misc.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 26/04/24.
//

import Foundation
import SwiftUI

enum PlayerAuthState: String{
    case authenticating = "Logging in to Game Center..."
    case unauthenticated = "Please login into Game Center"
    case authenticated = ""
    
    case error = "There was an error logging into Game Center"
}

struct GameOverAlertView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: Game
    var whoWon: String
    
    var body: some View {
        VStack {
            Text("Game Over")
                .font(.title)
                .padding()
            Text("\(whoWon) has won!")
                .padding()
            
            Spacer()
            Divider()
            
            HStack {
                Button(action: {
                    self.isPresented = false
                    viewModel.disconnectGame()
                }) {
                    Text("Disconnect")
                }
                .padding()
                
                Button(action: {
                    self.isPresented = false
                    // Handle action for the second dismiss button
                }) {
                    Text("Play Again")
                }
                .padding()
            }
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

