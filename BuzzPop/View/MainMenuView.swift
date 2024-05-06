//
//  MainMenuView.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 24/04/24.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var viewModel = Game()

    var body: some View {
        
        NavigationView{
            VStack{
                Spacer()
                
                Image("logo")
                    .resizable()
                    .frame(width: 300, height: 300)
                
                HStack{
                    Spacer()
                    Button(action: {
                        viewModel.playingSingleplayerGame = true
                    }) {
                        Text("Singleplayer")
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.white, lineWidth: 1)
                                    .frame(width: 140, height: 60)
                                    .background(Color.init(red: 0/255.0, green: 105/255.0, blue: 102/255.0))
                            )
                            .foregroundColor(Color.init(red: 233/255.0, green: 198/255.0, blue: 120/255.0))
                    }

                    Spacer()
                    
                    if viewModel.matchAvailable{
                        
                        Button(action: {
                            Task {
                                viewModel.choosePlayer()
                                viewModel.resetListMusic()
                                print("test")
                            }
                        }) {
                            Text("Multiplayer")
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.white, lineWidth: 1)
                                        .frame(width: 140, height: 60)
                                        .background(viewModel.authState != .authenticated ?  .gray: Color.init(red: 0/255.0, green: 105/255.0, blue: 102/255.0))
                                )
                                .foregroundColor(Color.init(red: 233/255.0, green: 198/255.0, blue: 120/255.0))
                        }
                    } else{
                        Button(action: {
//                            viewModel.authenticatePlayer()
                        }) {
                            Text("Multiplayer")
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.white, lineWidth: 1)
                                        .frame(width: 140, height: 60)
                                        .background(viewModel.authState != .authenticated ?  .gray: Color.init(red: 0/255.0, green: 105/255.0, blue: 102/255.0))
                                )
                                .foregroundColor(Color.init(red: 233/255.0, green: 198/255.0, blue: 120/255.0))
                        }
                    }
                    Spacer()
                }
                
                HStack{
                    if viewModel.authState == .authenticating{
                        ProgressView()//loading circle here
                            .accentColor(.white)
                            .foregroundColor(.white)
                    }
                    Text(viewModel.authState.rawValue)
                        .foregroundColor(.white)
                }
                .padding(.top, 30)
                
                Spacer()
                if viewModel.authState == .authenticated{
//                    Button(action: {
//                        //viewModel.authenticatePlayer()
//                    }) {
//                        Text("Logout")
//                            .background(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .stroke(.white, lineWidth: 1)
//                                    .frame(width: 140, height: 60)
//                                    .background(Color.init(red: 0/255.0, green: 105/255.0, blue: 102/255.0))
//                            )
//                            .foregroundColor(Color.init(red: 233/255.0, green: 198/255.0, blue: 120/255.0))
//                    }
//                    .padding(.top, -80)
                } else {
                    Button(action: {
                        viewModel.authenticatePlayer()
                    }) {
                        Text("Login")
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.white, lineWidth: 1)
                                    .frame(width: 140, height: 60)
                                    .background(Color.init(red: 0/255.0, green: 105/255.0, blue: 102/255.0))
                            )
                            .foregroundColor(Color.init(red: 233/255.0, green: 198/255.0, blue: 120/255.0))
                    }
                    .padding(.top, -80)
                }
            }
            .padding(.top, -80)

            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.init(red: 0/255.0, green: 85/255.0, blue: 82/255.0))
        }
        .fullScreenCover(isPresented: $viewModel.playingSingleplayerGame) {
            GameView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $viewModel.playingMultiplayerGame) {
            MultiplayerGameView(viewModel: viewModel)
        }
    }
}
