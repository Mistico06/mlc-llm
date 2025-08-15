import Foundation

extension LLMEngine {
    public func generateTextStream(
        prompt: String,
        maxTokens: Int,
        temperature: Double,
        topP: Double,
        onToken: @escaping (String) -> Void
    ) async throws {
        let inputs = try GPTTokenizer.shared.encode(prompt)
        _ = try await generate(
            inputs: inputs,
            maxTokens: maxTokens,
            temperature: temperature,
            topP: topP
        ) { tokens, _ in
            if let last = tokens.last {
                if let tokenText = try? GPTTokenizer.shared.decode([last]) {
                    onToken(tokenText)
                }
            }
        }
    }
    
    public func generateChatCompletion(
        messages: [ChatMessage],
        config: GenerationConfig = GenerationConfig(),
        onToken: @escaping (String, Bool) -> Void
    ) async throws {
        let tokenizer = GPTTokenizer.shared
        let contextTokens = try tokenizer.encodeChat(messages)
        var tokens = contextTokens + [tokenizer.specialTokens["<|assistant|>"] ?? 0]
        var generatedText = ""
        for step in 0..<config.sampling.maxTokens {
            let logits = try await getLogits(for: tokens)
            var penalized = logits
            applyPenalties(
                logits: &penalized,
                generatedTokens: tokens,
                frequencyPenalty: config.sampling.frequencyPenalty,
                presencePenalty: config.sampling.presencePenalty
            )
            let nextToken = sampleWithNucleus(
                logits: penalized,
                temperature: config.sampling.temperature,
                topP: config.sampling.topP,
                topK: config.sampling.topK
            )
            tokens.append(nextToken)
            let tokenText = try tokenizer.decode([nextToken])
            generatedText += tokenText
            let isDone = step >= config.sampling.maxTokens - 1
            onToken(tokenText, isDone)
            if isDone { break }
            try await Task.sleep(nanoseconds: UInt64.random(in: 20_000_000...80_000_000))
        }
    }
    
    // Placeholder to integrate with your real Tensor inference
    private func getLogits(for tokens: [Int]) async throws -> [Double] {
        // Replace with real model inference call.
        let vocabSize = 32000
        return (0..<vocabSize).map { _ in Double.random(in: -8.0...8.0) }
    }
}
