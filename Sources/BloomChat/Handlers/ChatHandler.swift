//
//  File.swift
//
//
//  Created by Qiwei Li on 1/30/23.
//

import BSON
import Foundation
import MongoKitten
import TelegramBotSDK

class ChatHandler: Handler, TelegramProtocol {
    var bloomChat: BloomChat!

    init(db: MongoDatabase, bot: TelegramBot, endpoint: String, key: String) {
        super.init(db: db, bot: bot)
        self.bloomChat = BloomChat(collection: self.col, key: key, endpoint: endpoint)
    }

    func handle(context: TelegramBotSDK.Context) throws -> Bool {
        if context.slash {
            context.respondAsync("Not supported command")
            return true
        }
        
        if let message = context.message, let text = message.text, let user = message.from {
            Task {
                let previousSession = try await bloomChat.find(from: user)
                let result = try await bloomChat.generateMessage(input: text, previous: previousSession)
                try await bloomChat.save(from: user, prev: previousSession, userMessage: text, response: result)
                context.respondSync(result)
            }
            
            return true
        }
        context.respondSync("You must enter some text input!")
        return false
    }
}
