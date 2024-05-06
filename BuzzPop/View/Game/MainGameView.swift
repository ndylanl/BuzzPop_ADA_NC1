//
//  MainGameView.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 24/04/24.
//

import SwiftUI

struct MainGameView: View {
    @Binding var Focused: Bool
    @Binding var showAlert: Bool
    @ObservedObject var viewModel: Game
    @Binding var searchText: String

    var body: some View {
        if viewModel.lose{
            VStack{
                if(viewModel.lose){
                    Spacer()
                }
                Text("Score: \(viewModel.curPoints)")
                    .foregroundColor(Color.white)
                
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
                Button(action: {
                    viewModel.loseGame()
                    Focused = false
                }) {
                    Text("New Game")
                }
                .padding()
                Spacer()
                Divider().background(Color.white)
            }
        }else{
            ZStack{
//                if viewModel.correctAnswer{
//                    Color.green
//                        .edgesIgnoringSafeArea(.all)
//                        .opacity(0.05)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
                if Focused{
                    VStack{
                        HStack{
                            Image(systemName: "x.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color.init(red: 20/255, green: 25/255, blue: 35/255))
                            Spacer()
                            Text("Score: \(viewModel.curPoints)")
                                .foregroundColor(Color.white)
                            Spacer()
                            Button(action: {
                                viewModel.playingSingleplayerGame = false
                            }) {
                                Image(systemName: "x.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                                    .background(Color.white.opacity(0.98))
                                    .cornerRadius(50)
                            }
                        }
                        .padding(.horizontal, 40)
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
                                Text(viewModel.curMusic.title)
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
                        Divider().background(Color.white)
                    }
                    .blur(radius: 1.5)
                } else {
                    VStack{
                        HStack{
                            Image(systemName: "x.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color.init(red: 20/255, green: 25/255, blue: 35/255))
                            Spacer()
                            Text("Score: \(viewModel.curPoints)")
                                .foregroundColor(Color.white)
                            Spacer()
                            Button(action: {
                                viewModel.playingSingleplayerGame = false
                            }) {
                                Image(systemName: "x.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                                    .background(Color.white.opacity(0.98))
                                    .cornerRadius(50)
                            }
                        }
                        .padding(.horizontal, 40)
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
                                Text(viewModel.curMusic.title)
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
                        Divider().background(Color.white)
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
        }
    }
}
