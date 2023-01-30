//
//  File.swift
//  
//
//  Created by Qiwei Li on 1/30/23.
//

import Foundation
import MongoKitten
import TelegramBotSDK

struct CreateChatSessionDto: Codable {
    var user: User
    var history: String
}

struct ChatSession: Codable {
    var user: User
    var history: String
    
    func toCreate() -> CreateChatSessionDto {
        return CreateChatSessionDto(user: user, history: history)
    }
}
