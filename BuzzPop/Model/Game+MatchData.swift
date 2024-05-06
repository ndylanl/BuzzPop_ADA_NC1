//
//  Game+MatchData.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 29/04/24.
//

import Foundation
import GameKit
import SwiftUI

// MARK: Game Data Objects

struct GameData: Codable {
    var matchName: String
    var playerName: String
    var score: Int?
    var message: String?
    var outcome: String?
    var guesses: [String]?
    var opponentDC: String?
    var songList: [Music]?
    var oppSkip: String?
}

extension Game {
    
    // MARK: Codable Game Data
    
    /// Creates a data representation of the local player's score for sending to other players.
    ///
    /// - Returns: A representation of game data that contains only the score.
    func encode(score: Int) -> Data? {
        let gameData = GameData(matchName: matchName, playerName: GKLocalPlayer.local.displayName, score: score, message: nil, outcome: nil, guesses: nil, opponentDC: nil, songList: nil, oppSkip: nil)
        return encode(gameData: gameData)
    }
    
    /// Creates a data representation of a text message for sending to other players.
    ///
    /// - Parameter message: The message that the local player enters.
    /// - Returns: A representation of game data that contains only a message.
    func encode(message: String?) -> Data? {
        let gameData = GameData(matchName: matchName, playerName: GKLocalPlayer.local.displayName, score: nil, message: message, outcome: nil, guesses: nil, opponentDC: nil, songList: nil, oppSkip: nil)
        return encode(gameData: gameData)
    }
    
    /// Creates a data representation of the game outcome for sending to other players.
    ///
    /// - Returns: A representation of game data that contains only the game outcome.
    func encode(outcome: String) -> Data? {
        let gameData = GameData(matchName: matchName, playerName: GKLocalPlayer.local.displayName, score: nil, message: nil, outcome: outcome, guesses: nil,opponentDC: nil, songList: nil, oppSkip: nil)
        return encode(gameData: gameData)
    }
    
    func encode(guesses: [String]) -> Data? {
        let gameData = GameData(matchName: matchName, playerName: GKLocalPlayer.local.displayName, score: nil, message: nil, outcome: nil, guesses: guesses,opponentDC: nil, songList: nil, oppSkip: nil)
        return encode(gameData: gameData)
    }
    
    func encode(opponentDC: String) -> Data? {
        let gameData = GameData(matchName: matchName, playerName: GKLocalPlayer.local.displayName, score: nil, message: nil, outcome: nil, guesses: nil, opponentDC: opponentDC, songList: nil, oppSkip: nil)
        return encode(gameData: gameData)
    }
    
    func encode(songList: [Music]) -> Data? {
        let gameData = GameData(matchName: matchName, playerName: GKLocalPlayer.local.displayName, score: nil, message: nil, outcome: nil, guesses: guesses, opponentDC: nil, songList: songList, oppSkip: nil)
        return encode(gameData: gameData)
    }
    
    func encode(oppSkip: String) -> Data? {
        let gameData = GameData(matchName: matchName, playerName: GKLocalPlayer.local.displayName, score: nil, message: nil, outcome: nil, guesses: nil, opponentDC: nil, songList: nil, oppSkip: "oppSkip")
        return encode(gameData: gameData)
    }
    
    /// Creates a data representation of game data for sending to other players.
    ///
    /// - Returns: A representation of game data.
    func encode(gameData: GameData) -> Data? {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        do {
            let data = try encoder.encode(gameData)
            return data
        } catch {
            print("Error: \(error.localizedDescription).")
            return nil
        }
    }
    
    /// Decodes a data representation of match data from another player.
    ///
    /// - Parameter matchData: A data representation of the game data.
    /// - Returns: A game data object.
    func decode(matchData: Data) -> GameData? {
        // Convert the data object to a game data object.
        return try? PropertyListDecoder().decode(GameData.self, from: matchData)
    }
}
