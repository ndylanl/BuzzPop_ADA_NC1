//
//  Music.swift
//  BuzzPop
//
//  Created by Nicholas Dylan Lienardi on 24/04/24.
//

import Foundation

struct Music: Equatable, Hashable, Decodable, Encodable {
    var url: String
    var title: String
    var artist: String
    
    init(url: String, title: String, artist: String) {
        self.url = url
        self.title = title
        self.artist = artist
    }
}
