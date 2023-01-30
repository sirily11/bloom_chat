//
//  File.swift
//  
//
//  Created by Qiwei Li on 1/30/23.
//

import Foundation
import TelegramBotSDK
import MongoKitten

class ClearHandler: Handler, TelegramProtocol {
    var bloomChat: BloomChat!

    init(db: MongoDatabase, bot: TelegramBot, endpoint: String, key: String) {
        super.init(db: db, bot: bot)
        self.bloomChat = BloomChat(collection: self.col, key: key, endpoint: endpoint)
    }
    
    func handle(context: TelegramBotSDK.Context) throws -> Bool {
        guard let user = context.message?.from else { return false }
        Task {
            try await bloomChat.clear(from: user)
            context.respondSync("Message cleared!")
        }
        return true
    }
}
