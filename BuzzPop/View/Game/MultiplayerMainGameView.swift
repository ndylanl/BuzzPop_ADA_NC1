//
//  MultiplayerMainGameView.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 30/04/24.
//

import SwiftUI

struct MultiplayerMainGameView: View {
    @ObservedObject var viewModel: Game
    @Binding var Focused: Bool
    @Binding var searchText: String


    var body: some View {
        VStack{
            VStack{
                HStack {
                    viewModel.myAvatar
                        .resizable()
                        .frame(width: 35.0, height: 35.0)
                        .clipShape(Circle())
                        .foregroundColor(Color.white)
                    
                    Text("\(viewModel.myName)")
                        .lineLimit(2)
                        .foregroundColor(Color.white)
                    Spacer()
                    Button(action: {
                        
                        viewModel.disconnectGame()
                        
                    }) {
                        Image(systemName: "x.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                            .background(Color.white.opacity(0.98))
                            .cornerRadius(50)
                    }
                }
                
                HStack{
                    viewModel.opponentAvatar
                        .resizable()
                        .frame(width: 35.0, height: 35.0)
                        .clipShape(Circle())
                        .foregroundColor(Color.white)
                    
                    Text("\(viewModel.opponentName)")
                        .lineLimit(2)
                        .foregroundColor(Color.white)
                    Spacer()
                }
                
            }
            .padding(.horizontal, 30)
            Divider().background(Color.white)

            
            Spacer()
            ZStack{
                VStack{
                    ScrollView{
                        ForEach(0..<viewModel.combinedGuesses.count, id: \.self) { x in
                            HStack {
                                Image(systemName: "xmark.app")
                                    .foregroundColor(.red)
                                Text(viewModel.combinedGuesses[x][0])
                                    .foregroundColor(Color.white)
                                    .padding(.leading)
                                Spacer()
                            }
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .padding([.leading, .trailing])
                        }
                        ForEach(viewModel.guesses, id: \.self){guess in
                            HStack {
                                Image(systemName: "xmark.app")
                                    .foregroundColor(.red)
                                Text(guess)
                                    .foregroundColor(Color.white)
                                    .padding(.leading)
                                Spacer()
                            }
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .padding([.leading, .trailing])
                        }
                        if viewModel.correctAnswer{
                            HStack {
                                Image(systemName: "checkmark.rectangle")
                                    .foregroundColor(.green)
                                Text("\(viewModel.curMusic.artist) - \(viewModel.curMusic.title)")
                                    .foregroundColor(Color.white)
                                    .padding(.leading)
                                Spacer()
                            }
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .padding([.leading, .trailing])
                        }
                        Spacer()
                        //Divider().background(Color.white)
                    }
                }
                
                VStack{
                    Spacer()
                    if Focused{
                        ScrollView{
                            Spacer()
                            ForEach(viewModel.filteredSongTitles, id: \.self){guess in
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.init(red: 0/255.0, green: 105/255.0, blue: 102/255.0), lineWidth: 1)
                                    .background(Color.init(red: 0/255.0, green: 105/255.0, blue: 102/255.0))
                                    .frame(width: .infinity, height: 80)
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity)
                                .padding([.leading, .trailing])
                                .overlay(
                                    HStack {
                                        Button(action:  {
                                            searchText = "\(guess.artist) - \(guess.title)"
                                            viewModel.guessAnswer(guess: searchText)
                                            searchText = ""
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        }){
                                            Spacer()
                                            Text("\(guess.artist) - \(guess.title)")
                                                .foregroundColor(Color.white)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                )
                            }
                        }
                        .frame(maxHeight: 200)
                        .overlay(
                            Rectangle()
                                .stroke(Color.white, lineWidth: 0.1)
                        )
                    }
                }
            }
            
            Spacer()
        }
        
        
        
    }
    @ViewBuilder
        private func opponentWrongGuessView(_ element: Any) -> some View {
            if let text = element as? String {
                HStack {
                    Image(systemName: "xmark.app")
                        .foregroundColor(.red)
                    Text(text)
                        .foregroundColor(Color.white)
                        .padding(.leading)
                    Spacer()
                }
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 1)
                )
                .padding([.leading, .trailing])
                .background(.gray)
            } else {
                // Handle other types if needed
                EmptyView()
            }
        }
    @ViewBuilder
        private func selfWrongGuessView(_ element: Any) -> some View {
            if let text = element as? String {
                HStack {
                    Image(systemName: "xmark.app")
                        .foregroundColor(.red)
                    Text(text)
                        .foregroundColor(Color.white)
                        .padding(.leading)
                    Spacer()
                }
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 1)
                )
                .padding([.leading, .trailing])
            } else {
                // Handle other types if needed
                EmptyView()
            }
        }
}
