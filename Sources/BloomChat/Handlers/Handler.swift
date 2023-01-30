//
//  File.swift
//  
//
//  Created by Qiwei Li on 1/30/23.
//

import Foundation
import MongoKitten
import TelegramBotSDK

protocol TelegramProtocol {
    func handle(context: Context) throws -> Bool
}

class Handler {
    let db: MongoDatabase
    let bot: TelegramBot
    let col: MongoCollection
    
    init(db: MongoDatabase, bot: TelegramBot) {
        self.db = db
        self.bot = bot
        self.col = db["sessions"]
    }
}
