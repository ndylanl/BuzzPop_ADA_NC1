//
//  MultiplayerGameView.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 30/04/24.
//

import SwiftUI

struct MultiplayerGameView: View {
    @ObservedObject var viewModel: Game
    @State private var filteredSongTitles: [String] = []
    @State private var Focused = false
    @State private var showAlert = false
    @State private var searchText = ""
    
    var body: some View {
        VStack{
            MultiplayerMainGameView(viewModel: viewModel, Focused: $Focused, searchText: $searchText)
            Spacer()
            GameControlView(searchText: $searchText, viewModel: viewModel, Focused: $Focused, showAlert: $showAlert)
                .padding(.bottom, 20)
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
        .alert(item: $viewModel.alertType) { alertType in
            switch alertType {
            case .alertCorrect:
                return Alert(
                        title: Text("Correct!"),
                        message: Text("You have guessed \(viewModel.myScore)/\(viewModel.multiplayerWinGoal) songs correctly!"),
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
                        title: Text("Opponent Correct!"),
                        message: Text("They have guessed \(viewModel.opponentScore)/\(viewModel.multiplayerWinGoal) songs correctly!"),
                        dismissButton: .default(Text("Next"), action: {viewModel.confirmNext()})
                    )
            case .alertGameOver:
                if viewModel.myScore == 5{
                    return Alert(title: Text("Game Over"),
                                 message: Text("You Won!"),
                                 primaryButton: .default(Text("Disconnect")) {
                        viewModel.disconnectGame()
                                 },
                                 secondaryButton: .default(Text("Play Agin")) {
                        viewModel.resetMatch()
                                 })
                } else {
                    return Alert(title: Text("Game Over"),
                                 message: Text("The Opponent Won!"),
                                 primaryButton: .default(Text("Disconnect")) {
                        viewModel.disconnectGame()
                                 },
                                 secondaryButton: .default(Text("Play Again")) {
                        viewModel.resetMatch()
                                 })
                }
            case .alertOpponentDisconnect:
                return Alert(
                    title: Text("The opponent left the game!"),
                    message: Text(""),
                    dismissButton: .default(Text("Dismiss"), action:{ viewModel.disconnectGame()
                        viewModel.curMusic = viewModel.listMusic[0]
                    })
                )
            case .alertOppSkip:
                return Alert(
                    title: Text("The Opponent Skipped this Song!"),
                    message: Text(""),
                    dismissButton: .default(Text("Dismiss"), action:{ viewModel.oppSkipped()})
                )
            }
        }
    }
}

#Preview {
    MultiplayerGameView(viewModel: Game())
}
