import Foundation

@MainActor
public class ConversationManager: ObservableObject {
    @Published public var conversations: [Conversation] = []
    @Published public var activeConversation: Conversation?
    
    public func createNewConversation(systemPrompt: String = "You are a helpful AI assistant.") -> Conversation {
        let conversation = Conversation(systemPrompt: systemPrompt)
        conversations.insert(conversation, at: 0)
        activeConversation = conversation
        return conversation
    }
    
    public func addMessage(to conversationId: UUID, role: ChatRole, content: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        let msg = ChatMessage(role: role, content: content)
        conversations[index].messages.append(msg)
        conversations[index].updatedAt = Date()
    }
    
    public func deleteConversation(_ conversationId: UUID) {
        conversations.removeAll { $0.id == conversationId }
        if activeConversation?.id == conversationId {
            activeConversation = conversations.first
        }
    }
}
