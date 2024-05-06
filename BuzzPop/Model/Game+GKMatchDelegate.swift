//
//  Game+GKMatchDelegate.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 29/04/24.
//

import Foundation
import GameKit
import SwiftUI

extension Game: GKMatchDelegate {
    /// Handles a connected, disconnected, or unknown player state.
    /// - Tag:didChange
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            print("\(player.displayName) Connected")
            
            // For automatch, set the opponent and load their avatar.
            if match.expectedPlayerCount == 0 {
                opponent = match.players[0]
                
                // Load the opponent's avatar.
                opponent?.loadPhoto(for: GKPlayer.PhotoSize.small) { (image, error) in
                    if let image {
                        self.opponentAvatar = Image(uiImage: image)
                    }
                    if let error {
                        print("Error: \(error.localizedDescription).")
                    }
                }
            }
        case .disconnected:
            print("\(player.displayName) Disconnected")
            alertType = .alertOpponentDisconnect
            if isPlaying{
                audioPlayer?.pause()
                isPlaying = false
            }
        default:
            print("\(player.displayName) Connection Unknown")
        }
    }
    
    /// Handles an error during the matchmaking process.
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        print("\n\nMatch object fails with error: \(error!.localizedDescription)")
    }

    /// Reinvites a player when they disconnect from the match.
    func match(_ match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
        return false
    }
    
    /// Handles receiving a message from another player.
    /// - Tag:didReceiveData
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        // Decode the data representation of the game data.
        let gameData = decode(matchData: data)
        
        // Update the interface from the game data.
        if let score = gameData?.score {
            // Show the opponent's score.
            opponentScore = score
        } else if let guesses = gameData?.guesses{
            opponentGuesses = guesses
            if let lastGuess = opponentGuesses.last {
                if !lastGuess.lowercased().contains(curMusic.title.lowercased()) {
                    let test = [opponentGuesses.last ?? "nil" , "0"] as [String]
                    combinedGuesses.append(test)
                }
                checkOpponentCorrect(oppGuess: opponentGuesses.last!)
            } else {
                //combinedGuesses.removeAll()
            }
        } else if let songList = gameData?.songList{
            decideSongList(songList: songList)
        } else if (gameData?.opponentDC) != nil {
            alertType = .alertOpponentDisconnect
            
        } else if let oppSkip = (gameData?.oppSkip){
            print("Skip Test")
            if oppSkip.contains("oppSkip"){
                alertType = .alertOppSkip
            }
        }
    }
}
