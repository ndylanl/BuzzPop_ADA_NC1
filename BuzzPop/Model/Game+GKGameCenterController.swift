//
//  Game+GKGameCenterController.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 29/04/24.
//

import Foundation
import GameKit
import SwiftUI

extension Game {
    
    /// Presents the local player's achievement in the dashboard.
    func showProgress() {
        let viewController = GKGameCenterViewController(achievementID: "1234")
        viewController.gameCenterDelegate = self
        
        rootViewController?.present(viewController, animated: true) { }
    }
    
    /// Presents the top score on the leaderboard in the dashboard.
    /// - Tag:topScore
    func topScore() {
        let viewController = GKGameCenterViewController(leaderboardID: "123", playerScope: GKLeaderboard.PlayerScope.global,
                                                        timeScope: GKLeaderboard.TimeScope.allTime)
        viewController.gameCenterDelegate = self
        rootViewController?.present(viewController, animated: true) { }
    }
    
    /// Cleans up the view's state when the local player closes the dashboard.
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        // Dismiss the view controller.
        gameCenterViewController.dismiss(animated: true)
    }
}
