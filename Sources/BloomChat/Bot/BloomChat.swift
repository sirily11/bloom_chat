import BSON
import Foundation
import MongoKitten
import TelegramBotSDK

public class BloomChat {
    let collection: MongoCollection
    let endpoint: String
    let key: String
    
    let prePromptURL = Bundle.module.url(forResource: "pre-prompt", withExtension: ".txt")
    let prePrompt: String
    
    init(collection: MongoCollection, key: String, endpoint: String) {
        self.collection = collection
        self.endpoint = endpoint
        self.key = key
        prePrompt = try! String(contentsOf: prePromptURL!)
        print(prePrompt)
    }
    
    func generateMessage(input: String, previous session: ChatSession?) async throws -> String {
        let prompt = combineHistoryWithPrompt(previous: session?.history, userMessage: input)
        print("====\nPrompt: \(prompt)\n====")
        let body = ["inputs": prompt]
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let result = try decoder.decode([BloomResponse].self, from: data)
        print("====\nResult: \(result)\n====")
        let response = getBotResponse(from: result.first?.generated_text, userMessage: input)
        return response
    }
    
    func find(from user: User) async throws -> ChatSession? {
        let document = try await collection.findOne("user.id" == Int(user.id))
        if let document = document {
            let decoder = BSONDecoder()
            return try decoder.decode(ChatSession.self, from: document)
        }
        return nil
    }
    
    func clear(from user: User) async throws {
        try await collection.deleteOne(where: ["user.id": Int(user.id)])
    }
    
    func save(from user: User, prev session: ChatSession?, userMessage: String, response: String) async throws {
        let encoder = BSONEncoder()
        let newHistory = combineHistory(previous: session?.history, response: response, userMessage: userMessage)
        let data = ChatSession(user: user, history: newHistory)
        let document = try encoder.encode(data)
        if let session = session {
            try await collection.updateOne(where: ["user.id": Int(session.user.id)], to: document)
        } else {
            try await collection.insert(document)
        }
    }
    
    private func combineHistoryWithPrompt(previous: String?, userMessage: String) -> String {
        if let previous = previous {
            return "\(previous)\nUser:\(userMessage)\nBot: "
        } else {
            return "User: \(userMessage)\nBot: "
        }
    }
    
    private func combineHistory(previous: String?, response: String, userMessage: String) -> String {
        if let previous = previous {
            return "\(previous)\nUser: \(userMessage)\nBot: \(response)"
        } else {
            return "\(prePrompt)\nUser:\(userMessage)\nBot:\(response)"
        }
    }
    
    /**
     * Always returns the first bot response next to the user's userMessage
     * For example Given the userMessage is Hi.
     * User: Hi
     * Bot: Hi
     * User: How are you
     * Bot: I am good
     *
     * Will return Hi.
     */
    private func getBotResponse(from response: String?, userMessage: String) -> String {
        guard let response = response else { return "Error!" }
        let responseLines = response.replacingOccurrences(of: prePrompt, with: "").components(separatedBy: "\n")
        for (index, line) in responseLines.enumerated() {
            if line == "User: \(userMessage)" {
                for i in index + 1..<responseLines.count {
                    let nextLine = responseLines[i]
                    if nextLine.hasPrefix("Bot: ") {
                        return String(nextLine.dropFirst(5))
                    }
                }
                return "Error!"
            }
        }
        return "Error!"
    }


}
