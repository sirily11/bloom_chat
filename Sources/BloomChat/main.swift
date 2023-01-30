//
//  File.swift
//
//
//  Created by Qiwei Li on 1/30/23.
//

import Foundation
import TelegramBotSDK
import MongoKitten

// Get api key from environment variables
guard let token = ProcessInfo.processInfo.environment[EnvironmentVariable.TELEGRAM_API.rawValue] else {
    fatalError("\(EnvironmentVariable.TELEGRAM_API.rawValue) environment variable not set")
}

// Get mongodb connection string from environment variables
guard let mongoConnectionString = ProcessInfo.processInfo.environment[EnvironmentVariable.MONGODB_URL.rawValue] else {
    fatalError("\(EnvironmentVariable.MONGODB_URL.rawValue) environment variable not set")
}

guard let modelURL = ProcessInfo.processInfo.environment[EnvironmentVariable.MODEL_URL.rawValue] else {
    fatalError("\(EnvironmentVariable.MODEL_URL.rawValue) environment variable not set")
}


guard let modelKey = ProcessInfo.processInfo.environment[EnvironmentVariable.MODEL_KEY.rawValue] else {
    fatalError("\(EnvironmentVariable.MODEL_KEY.rawValue) environment variable not set")
}

// prepare the bot and db
let bot = TelegramBot(token: token)
let router = Router(bot: bot)
let db = try await MongoDatabase.connect(to: mongoConnectionString)

router[Command.help.rawValue] = HelpHandler(db: db, bot: bot).handle
router[Command.clear.rawValue] = ClearHandler(db: db, bot: bot, endpoint: modelURL, key: modelKey).handle

router[.newChatMembers] = { context in
    guard let users = context.message?.newChatMembers else { return false }
    for user in users {
        guard user.id != bot.user.id else { continue }
        context.respondAsync("Welcome, \(user.firstName)!")
    }
    return true
}

router.unmatched = ChatHandler(db: db, bot: bot, endpoint: modelURL, key: modelKey).handle

while let update = bot.nextUpdateSync() {
    try router.process(update: update)
}

fatalError("Server stopped due to error: \(String(describing: bot.lastError))")
