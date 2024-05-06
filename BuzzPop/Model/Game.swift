//
//  Game.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 24/04/24.
//

import Foundation
import AVFoundation
import GameKit
import SwiftUI

@MainActor
class Game: NSObject, GKGameCenterControllerDelegate, ObservableObject{

    // The local player's friends, if they grant access.
    @Published var friends: [Friend] = []
    
    // The game interface state.
    @Published var matchAvailable = false
    @Published var playingSingleplayerGame = false
    @Published var playingMultiplayerGame = false
//    @Published var playingMultiplayerGame = true
    @Published var myMatch: GKMatch? = nil
    @Published var automatch = false
    
    // Outcomes of the game for notifing players.
    @Published var youForfeit = false
    @Published var opponentForfeit = false
    @Published var youWon = false
    @Published var opponentWon = false
    
    // The match information.
    @Published var myAvatar = Image(systemName: "person.crop.circle")
    @Published var opponentAvatar = Image(systemName: "person.crop.circle")
    @Published var opponent: GKPlayer? = nil
    @Published var messages: [Message] = []
    @Published var myScore = 0
    @Published var opponentScore = 0
    @Published var authState = PlayerAuthState.unauthenticated
    @Published var opponentGuesses: [String] = []
    @Published var combinedGuesses: [[String]] = [[String]]()
    @Published var multiplayerWinGoal = 5
    
    // solo game properties
    @Published var listMusic: [Music]
    @Published var duration = 5
    @Published var pointsAwarded = 100
    @Published var curMusic: Music
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var curTime = "00:00"
    @Published var filteredSongTitles: [Music] = []
    @Published var guessCount = 0
    @Published var guesses: [String] = []
    @Published var curPoints = 0
    @Published var correctAnswer = false
    @Published var showSkipAlert = false
    @Published var showAddTimeAvailable = false
    @Published var lose = false
    @Published var streak = 0
    @Published var skipsAvailable = 3
    @Published var addTimeAvailable = 3
    @Published var alertType: AlertType?
    private var timer: Timer?

    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    enum AlertType: Identifiable {
        case alertCorrect, alertSkip, alertAddTime, alertOpponentCorrect, alertGameOver, alertOpponentDisconnect, alertOppSkip
        
        var id: AlertType { self }
    }
    
    /// The name of the match.
    var matchName: String {
        "\(opponentName) Match"
    }
    
    /// The local player's name.
    var myName: String {
        GKLocalPlayer.local.displayName
    }
    
    /// The opponent's name.
    var opponentName: String {
        opponent?.displayName ?? "Invitation Pending"
    }
    
    /// Authenticates the local player, initiates a multiplayer game, and adds the access point.
    /// - Tag:authenticatePlayer
    func authenticatePlayer() {
        // Set the authentication handler that GameKit invokes.
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            self.authState = PlayerAuthState.authenticating

            if let viewController = viewController {
                // If the view controller is non-nil, present it to the player so they can
                // perform some necessary action to complete authentication.
                self.rootViewController?.present(viewController, animated: true) { }
                return
            }
            if let error {
                // If you can’t authenticate the player, disable Game Center features in your game.
                self.authState = PlayerAuthState.unauthenticated
                print("Error: \(error.localizedDescription).")
                return
            }
            
            // A value of nil for viewController indicates successful authentication, and you can access
            // local player properties.
            
            // Load the local player's avatar.
            GKLocalPlayer.local.loadPhoto(for: GKPlayer.PhotoSize.small) { image, error in
                if let image {
                    self.myAvatar = Image(uiImage: image)
                }
                if let error {
                    // Handle an error if it occurs.
                    print("Error: \(error.localizedDescription).")
                }
            }

            // Register for real-time invitations from other players.
            GKLocalPlayer.local.register(self)
            
            // Add an access point to the interface.
            GKAccessPoint.shared.location = .topLeading
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = true
            
            // Enable the Start Game button.
            self.matchAvailable = true
            self.authState = PlayerAuthState.authenticated
        }
    }
    
    /// Starts the matchmaking process where GameKit finds a player for the match.
    /// - Tag:findPlayer
    func findPlayer() async {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        let match: GKMatch
        
        // Start automatch.
        do {
            match = try await GKMatchmaker.shared().findMatch(for: request)
        } catch {
            print("Error: \(error.localizedDescription).")
            return
        }

        // Start the game, although the automatch player hasn't connected yet.
        if !playingMultiplayerGame {
            print("sampe start my match")
            startMyMatchWith(match: match)
        }

        // Stop automatch.
        GKMatchmaker.shared().finishMatchmaking(for: match)
        automatch = false
    }
    
    /// Presents the matchmaker interface where the local player selects and sends an invitation to another player.
    /// - Tag:choosePlayer
    func choosePlayer() {
        // Create a match request.
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        
        // Present the interface where the player selects opponents and starts the game.
        if let viewController = GKMatchmakerViewController(matchRequest: request) {
            viewController.matchmakerDelegate = self
            rootViewController?.present(viewController, animated: true) { }
        }
    }
    
    /// Starts a match.
    /// - Parameter match: The object that represents the real-time match.
    /// - Tag:startMyMatchWith
    func startMyMatchWith(match: GKMatch) {
        GKAccessPoint.shared.isActive = false
        playingMultiplayerGame = true
        myMatch = match
        myMatch?.delegate = self
        
        // For automatch, check whether the opponent connected to the match before loading the avatar.
        if myMatch?.expectedPlayerCount == 0 {
            opponent = myMatch?.players[0]
            
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
    }
    
    /// Quits a match and saves the game data.
    /// - Tag:endMatch
    func endMatch() {
        let myOutcome = myScore >= opponentScore ? "won" : "lost"
        let opponentOutcome = opponentScore > myScore ? "won" : "lost"
        
        // Notify the opponent that they won or lost, depending on the score.
        do {
            let data = encode(outcome: opponentOutcome)
            try myMatch?.sendData(toAllPlayers: data!, with: GKMatch.SendDataMode.unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
        
        // Notify the local player that they won or lost.
        if myOutcome == "won" {
            youWon = true
        } else {
            opponentWon = true
        }
    }
    
    /// Forfeits a match without saving the score.
    /// - Tag:forfeitMatch
    func forfeitMatch() {
        // Notify the opponent that you forfeit the game.
        do {
            let data = encode(outcome: "forfeit")
            try myMatch?.sendData(toAllPlayers: data!, with: GKMatch.SendDataMode.unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }

        youForfeit = true
    }
    
    func disconnectGame() {
        // send disc state
        do {
            let data = encode(opponentDC: "DC")
            try myMatch?.sendData(toAllPlayers: data!, with: GKMatch.SendDataMode.unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
        
        curMusic = listMusic[0]
        
        print("test disconnect function")
        // Reset the game data.
        playingMultiplayerGame = false
        myMatch?.disconnect()
        myMatch?.delegate = nil
        myMatch = nil
        opponent = nil
        opponentAvatar = Image(systemName: "person.crop.circle")
        messages = []
        GKAccessPoint.shared.isActive = true
        youForfeit = false
        opponentForfeit = false
        youWon = false
        opponentWon = false
        combinedGuesses.removeAll()
        
        // Reset the score.
        myScore = 0
        opponentScore = 0
        
        youForfeit = true
        
        curMusic = listMusic[0]
    }
    
    func resetMatch() {
        correctAnswer = false
        youForfeit = false
        opponentForfeit = false
        youWon = false
        opponentWon = false
        combinedGuesses.removeAll()
        nextMusic()
        //curMusic = listMusic[0]

        
        // Reset the score.
        myScore = 0
        opponentScore = 0
        
        
    }
    
    
    /// Ini all the solo mode stuff, diatas focus on gamecenter/ gamekit
    override init() {
        self.listMusic = [
            Music(url: "Joji", title: "Slow Dancing In The Dark", artist: "Joji"),
            Music(url: "Laufey - From The Start", title: "From the Start", artist: "Laufey"),
            Music(url: "Tame Impala - The Less I Know The Better", title: "The Less I Know The Better", artist: "Tame Impala"),
            Music(url: "Franz Ferdinand - This Fire", title: "This Fire", artist: "Franz Ferdinand"),
            Music(url: "ZICO - Any Song", title: "Any Song", artist: "ZICO"),
            Music(url: "Doja Cat - Kiss Me More", title: "Kiss Me More", artist: "Doja Cat"),
            Music(url: "Radiohead -  Creep", title: "Creep", artist: "Radiohead"),
            Music(url: "George Michael - Careless Whisper", title: "Careless Whisper", artist: "George Michael"),
            Music(url: "Labrinth - Jealous", title: "Jealous", artist: "Labrinth"),
            Music(url: "Rick Astley - Never Gonna Give You Up", title: "Never Gonna Give You Up", artist: "Rick Astley"),
            Music(url: "Coldplay - The Scientist", title: "The Scientist", artist: "Coldplay"),
            Music(url: "Smash Mouth - All Star", title: "All Star", artist: "Smash Mouth"),
            Music(url: "Hers - Harvey", title: "Harvey", artist: "Hers"),
            Music(url: "YOASOBI - Racing Into The Night", title: "Racing Into The Night", artist: "YOASOBI"),
            Music(url: "PinkPantheress Ice Spice - Boys a liar Pt 2", title: "Boys a liar Pt 2", artist: "PinkPantheress Ice Spice"),
            Music(url: "Doja Cat - Say So", title: "Say So", artist: "Doja Cat"),
            Music(url: "Joseph Vincent - Cant Take My Eyes Off You Lyrics", title: "Cant Take My Eyes Off You Lyrics", artist: "Joseph Vincent"),
            Music(url: "Jungle - Back on 74", title: "Back on 74", artist: "Jungle"),
            Music(url: "The Killers - Mr.Brightside", title: "Mr.Brightside", artist: "The Killers"),
        ]
        curMusic = Music(url: "Tame Impala - The Less I Know The Better", title: "The Less I Know The Better", artist: "Tame Impala")
        super.init()
        if(playingSingleplayerGame){
            initializeMusic()
        }
        
        if(playingMultiplayerGame){
            sendSongList(songList: listMusic)
        }
    }
    
    func sendSongList(songList: [Music]){
        do {
            let data = encode(guesses: guesses)
            try myMatch?.sendData(toAllPlayers: data!, with: GKMatch.SendDataMode.unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
    
    func decideSongList(songList: [Music]){
        listMusic = songList
    }
    
    func increaseDuration(amount: Int){
        if addTimeAvailable > 0{
            duration += amount
            pointsAwarded -= 10
            addTimeAvailable -= 1
        } else {
            alertType = .alertAddTime
        }
    }
    
    func confirmNext(){
        nextMusic()
        guesses.removeAll()
        if(playingSingleplayerGame){
            curPoints += pointsAwarded
            pointsAwarded = 100
            guessCount = 0
            streak += 1
            correctAnswer = false
        } else {
//            sendWinState(state: true)
            correctAnswer = false
            combinedGuesses.removeAll()
        }
    }
    
    func checkOpponentCorrect(oppGuess: String){
        if oppGuess.lowercased().contains(curMusic.title.lowercased()){
            alertType = .alertOpponentCorrect
            opponentCorrect()
        }
    }
    
    func opponentCorrect(){
        audioPlayer?.play()
        duration = 30
        correctAnswer = true
        opponentScore += 1
        opponentGuesses.removeAll()
        checkWin()
    }
    
    func resetListMusic(){
        curMusic = listMusic[0]
        guard let songURL = Bundle.main.url(forResource: curMusic.url, withExtension: "mp3") else {
            print(curMusic.url)
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: songURL)
            audioPlayer?.prepareToPlay()

            // Start a timer to check the current time every second
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.checkPlaybackTime()
            }

            RunLoop.current.add(timer!, forMode: .common) // Add the timer to the current run loop
        } catch {
            print("Failed to play the audio: \(error.localizedDescription)")
        }
    }
    
    func guessAnswer(guess: String){
        if(guess.isEmpty){
            return
        }
        if playingSingleplayerGame{
            if(guess.lowercased().contains(curMusic.title.lowercased())){
                if(!isPlaying){
//                    audioPlayer?.currentTime = TimeInterval(duration)
                    audioPlayer?.play()
                }
                duration = 30
                alertType = .alertCorrect
                correctAnswer = true
                myScore += 1
                checkWin()
            }else{
                guessCount += 1
                guesses.append(guess)
                pointsAwarded -= 20
                if(guessCount >= 5){
                    lose = true
                }
            }
        }
        
        if playingMultiplayerGame{
            if(guess.lowercased().contains(curMusic.title.lowercased())){
                if(!isPlaying){
//                    audioPlayer?.currentTime = TimeInterval(duration)
                    audioPlayer?.play()
                }
                duration = 30
                alertType = .alertCorrect
                correctAnswer = true
                guesses.append(guess)
//                sendGuessData()
//                guesses.removeLast()
//                opponentGuesses.removeAll()
//                myScore += 1
//                checkWin()
                // Perform long-running tasks asynchronously on a background queue
                DispatchQueue.global().async {
                    self.sendGuessData() // Move sendGuessData() to the background queue
                    
                    DispatchQueue.main.async {
                        // Update UI or perform any UI-related tasks on the main queue
                        self.guesses.removeLast()
                        self.opponentGuesses.removeAll()
                        self.myScore += 1
                        self.checkWin()
                    }
                }
                
                // check the latency here, habis alertcorrect lama loading e , nyandet di alert e
                
            }else{
                guesses.append(guess)
                sendGuessData()
            }
        }
    }
    
    func checkWin(){
        if opponentScore == multiplayerWinGoal || myScore == multiplayerWinGoal {
            alertType = .alertGameOver
        } else {
            return
        }
    }
    
    func sendGuessData(){
        do {
            let data = encode(guesses: guesses)
            try myMatch?.sendData(toAllPlayers: data!, with: GKMatch.SendDataMode.unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
    
//    func sendWinState(state: Bool){
//        do {
//            let data = encode(opponentCorrect: state)
//            try myMatch?.sendData(toAllPlayers: data!, with: GKMatch.SendDataMode.unreliable)
//        } catch {
//            print("Error: \(error.localizedDescription).")
//        }
//    }
    
    func loseGame(){
        lose = false
        nextMusic()
        curPoints = 0
        pointsAwarded = 100
        guesses.removeAll()
        guessCount = 0
        streak = 0
        addTimeAvailable = 3
        skipsAvailable = 3
    }
    
    func updateFilteredSongTitles(guess: String) {
        filteredSongTitles = listMusic.filter {
            $0.title.lowercased().contains(guess.lowercased()) ||
            $0.artist.lowercased().contains(guess.lowercased())
        }
    }
    
    func nextMusic(){
        audioPlayer?.pause()
        isPlaying = false
        duration = 5
        let id_music: Int = listMusic.firstIndex(where: {$0 == curMusic}) ?? 0
        if id_music == listMusic.count-1{
            curMusic = listMusic[0]
        } else{
            curMusic = listMusic[id_music + 1]
        }
        guard let songURL = Bundle.main.url(forResource: curMusic.url, withExtension: "mp3") else {
            print(curMusic.url)
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: songURL)
            audioPlayer?.prepareToPlay()

            // Start a timer to check the current time every second
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.checkPlaybackTime()
            }

            RunLoop.current.add(timer!, forMode: .common) // Add the timer to the current run loop
        } catch {
            print("Failed to play the audio: \(error.localizedDescription)")
        }
    }
    
    func skipSong(){
        if skipsAvailable > 0{
            if playingMultiplayerGame{
                sendSkipData()
                guesses.removeAll()
                nextMusic()
                guessCount = 0
                skipsAvailable -= 1
            } else {
                guesses.removeAll()
                nextMusic()
                pointsAwarded = 100
                guessCount = 0
                skipsAvailable -= 1
            }
        } else {
            alertType = .alertSkip
        }
    }
    
    func sendSkipData(){
        do {
            let data = encode(oppSkip: "test")
            try myMatch?.sendData(toAllPlayers: data!, with: GKMatch.SendDataMode.unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
    
    func oppSkipped(){
        guesses.removeAll()
        nextMusic()
        guessCount = 0
    }
    
    func initializeMusic(){
        if playingMultiplayerGame{
            curMusic = listMusic[0]
        } else{
            listMusic.shuffle()
            curMusic = listMusic[0]
        }
    }
    
    func playMusic(){
        if(isPlaying){
            audioPlayer?.pause()
            isPlaying = false
            print("defak")
        }else{
            isPlaying = true
            if(audioPlayer == nil ){
                // Initialize the audio player with the song's URL
                guard let songURL = Bundle.main.url(forResource: curMusic.url, withExtension: "mp3") else {
                    print(curMusic.url)
                    return
                }
                
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: songURL)
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()

                    // Start a timer to check the current time every second
                    timer = Timer.scheduledTimer(withTimeInterval: 0.00001, repeats: true) { [weak self] _ in
                        self?.checkPlaybackTime()
                    }

                    RunLoop.current.add(timer!, forMode: .common) // Add the timer to the current run loop
                    print("test")
                } catch {
                    print("Failed to play the audio: \(error.localizedDescription)")
                }
                print("woi")
            }else{
                audioPlayer?.play()
                print("kfnvk")
            }
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Start updating the current time periodically
    func startUpdatingCurrentTime() {
        stopUpdatingCurrentTime() // Stop the timer if it's already running

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkPlaybackTime()
        }
    }
    
    private func checkPlaybackTime() {
        guard let audioPlayer = audioPlayer else {
            return
        }

        // Check if the player has passed 5 seconds of play time
        if audioPlayer.currentTime >= Double(duration) {
            audioPlayer.pause() // Pause the audio playback
            audioPlayer.currentTime = 0.0
            timer?.invalidate() // Stop the timer
            isPlaying = false
        }

        updateCurrentTime()
    }

    // Stop updating the current time
    func stopUpdatingCurrentTime() {
        timer?.invalidate()
        timer = nil
    }

    // Update the current time using the audio player's current time
    private func updateCurrentTime() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        curTime = formatTime(audioPlayer.currentTime)

    }
}
