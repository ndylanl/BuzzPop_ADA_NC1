//
//  GameView.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 24/04/24.
//

import SwiftUI
import AVFoundation


struct GameView: View {
    @ObservedObject var viewModel: Game
    @State private var filteredSongTitles: [String] = []
    @State private var Focused = false
    @State private var showAlert = false
    @State private var searchText = ""
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack{
            VStack(){
                MainGameView(Focused: $Focused, showAlert: $showAlert, viewModel: viewModel, searchText: $searchText)
                Spacer()
                if(!viewModel.lose){
                    GameControlView(searchText: $searchText, viewModel: viewModel, Focused: $Focused, showAlert: $showAlert)
                        .padding(.bottom)
                        .padding(.bottom)
                        .padding(.bottom)
                                        }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.init(red: 20/255, green: 25/255, blue: 35/255))
            .onAppear {
                // Start updating the current time when the view appears
                viewModel.startUpdatingCurrentTime()
            }
            .onDisappear {
                // Stop updating the current time when the view disappears
                viewModel.stopUpdatingCurrentTime()
            }
        }
        .alert(item: $viewModel.alertType) { alertType in
            switch alertType {
            case .alertCorrect:
                return Alert(
                        title: Text("Correct!"),
                        message: Text("\(viewModel.guessCount + 1)/5 guesses used! +\(viewModel.pointsAwarded)"),
                        dismissButton: .default(Text("Next"), action: {viewModel.confirmNext()})
                    )
            case .alertSkip:
                return Alert(
                    title: Text("Out of skips!"),
                    message: Text("Unable to skip anymore!"),
                    dismissButton: .default(Text("Dismiss"), action:{ viewModel.showSkipAlert = false})
                )
            case .alertAddTime:
                return Alert(
                    title: Text("Out of add time!"),
                    message: Text("Unable to add time anymore!"),
                    dismissButton: .default(Text("Dismiss"), action:{ viewModel.showAddTimeAvailable = false}))
            case .alertOpponentCorrect:
                return Alert(
                    title: Text("Out of add time!"),
                    message: Text("Unable to add time anymore!"),
                    dismissButton: .default(Text("Dismiss"), action:{ viewModel.showAddTimeAvailable = false}))
                
            case .alertGameOver:
                return Alert(
                    title: Text("Out of add time!"),
                    message: Text("Unable to add time anymore!"),
                    dismissButton: .default(Text("Dismiss"), action:{ viewModel.showAddTimeAvailable = false}))
            case .alertOpponentDisconnect:
                return Alert(
                    title: Text("Out of add time!"),
                    message: Text("Unable to add time anymore!"),
                    dismissButton: .default(Text("Dismiss"), action:{ viewModel.showAddTimeAvailable = false}))
            case .alertOppSkip:
                return Alert(
                    title: Text("The Opponent Skipped this Song!"),
                    message: Text(""),
                    dismissButton: .default(Text("Dismiss"))
                )
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(viewModel: Game())
    }
}

