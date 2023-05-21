//
//  Tweet.swift
//  TwitterClone
//
//  Created by Ahmet Utlu on 26.04.2023.
//

import Foundation

struct Tweet: Codable, Identifiable {
    var id = UUID().uuidString
    let author: TwitterUser
    let authorId: String
    let tweetContent: String
    var likesCount: Int
    var likers: [String]
    let isReply: BooleanLiteralType
    let parentReference: String?
}
