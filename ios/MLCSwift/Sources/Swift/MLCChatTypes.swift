import Foundation

public enum ChatRole: String, Codable {
    case system, user, assistant
}

public struct ChatMessage: Codable, Identifiable {
    public let id: UUID = UUID()
    public let role: ChatRole
    public let content: String
    public let timestamp: Date = Date()
    public var tokenCount: Int { content.count / 4 } // Approximate
}

public struct Conversation: Identifiable, Codable {
    public let id: UUID = UUID()
    public var title: String = "New Chat"
    public var messages: [ChatMessage]
    public let createdAt: Date = Date()
    public var updatedAt: Date = Date()
    
    public var tokenCount: Int { messages.reduce(0) { $0 + $1.tokenCount } }
    public var lastMessage: ChatMessage? { messages.last }
    
    public init(systemPrompt: String) {
        messages = [ChatMessage(role: .system, content: systemPrompt)]
    }
}

public struct SamplingParameters {
    public var temperature: Double = 0.7
    public var topP: Double = 0.9
    public var topK: Int = 40
    public var frequencyPenalty: Double = 0.0
    public var presencePenalty: Double = 0.0
    public var maxTokens: Int = 2048
    public var stopTokens: [String] = []
}

public struct GenerationConfig {
    public var sampling: SamplingParameters = SamplingParameters()
    public var systemPrompt: String = "You are a helpful AI assistant."
    public var contextWindow: Int = 8192
    public var streamingEnabled: Bool = true
}
