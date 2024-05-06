//
//  Game+Messages.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 29/04/24.
//

import Foundation
import GameKit
import SwiftUI

/// A message that one player sends to another.
struct Message: Identifiable {
    var id = UUID()
    var content: String
    var playerName: String
    var isLocalPlayer = false
}

extension Game {
    /// Sends a text message from one player to another.
    /// - Tag:sendMessage
    func sendMessage(content: String) {
        // Add the message to the local message view.
        let message = Message(content: content, playerName: GKLocalPlayer.local.displayName, isLocalPlayer: true)
        messages.append(message)
        
        // Encode the game data to send.
        let data = encode(message: content)
        
        do {
            // Send the game data to the opponent.
            try myMatch?.sendData(toAllPlayers: data!, with: GKMatch.SendDataMode.unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
}