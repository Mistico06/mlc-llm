//
//  LLMEngine+Enhanced.swift
//  MLCSwift
//
//  Enhancements built on top of MLCEngine's OpenAI-compatible streaming API.
//  - Simple text streaming for a single prompt
//  - Multi-turn chat streaming with completion signal
//  - Aggregated convenience wrappers
//

import Foundation

// MARK: - Role mapping between app types and engine types

private extension ChatCompletionRole {
    init(from role: ChatRole) {
        switch role {
        case .system:    self = .system
        case .user:      self = .user
        case .assistant: self = .assistant
        }
    }
}

// MARK: - Convenience helpers on MLCEngine

extension MLCEngine {
    /// Stream tokens for a single-prompt completion by consuming the engine's chat stream.
    /// The caller can concatenate deltas in the onToken closure.
    public func generateTextStream(
        prompt: String,
        maxTokens: Int,
        temperature: Double,
        topP: Double,
        onToken: @escaping (String) -> Void
    ) async {
        let messages = [
            ChatCompletionMessage(role: .user, content: prompt)
        ]

        let stream = await self.chat.completions.create(
            messages: messages,
            model: nil,
            frequency_penalty: nil,
            presence_penalty: nil,
            logprobs: false,
            top_logprobs: 0,
            logit_bias: nil,
            max_tokens: maxTokens,
            n: 1,
            seed: nil,
            stop: nil,
            stream: true,
            stream_options: StreamOptions(include_usage: false),
            temperature: Float(temperature),
            top_p: Float(topP),
            tools: nil,
            user: nil,
            response_format: nil
        )

        for await chunk in stream {
            if let choice = chunk.choices.first {
                // In many OpenAI-compatible schemas, `delta` is non-optional, `content` is optional.
                let delta = choice.delta
                if let content = delta.content, !content.isEmpty {
                    onToken(content)
                }
            }
        }
    }

    /// Stream tokens for multi-turn chat by consuming the engine's chat stream.
    /// Calls `onToken(token, false)` for content chunks and `onToken("", true)` once complete.
    public func generateChatCompletion(
        messages: [ChatMessage],
        config: GenerationConfig = GenerationConfig(),
        onToken: @escaping (String, Bool) -> Void
    ) async {
        // Map app roles to engine roles
        let mlcMessages = messages.map {
            ChatCompletionMessage(role: ChatCompletionRole(from: $0.role), content: $0.content)
        }

        let stream = await self.chat.completions.create(
            messages: mlcMessages,
            model: nil,
            frequency_penalty: Float(config.sampling.frequencyPenalty),
            presence_penalty: Float(config.sampling.presencePenalty),
            logprobs: false,
            top_logprobs: 0,
            logit_bias: nil,
            max_tokens: config.sampling.maxTokens,
            n: 1,
            seed: nil,
            stop: config.sampling.stopTokens.isEmpty ? nil : config.sampling.stopTokens,
            stream: true,
            stream_options: StreamOptions(include_usage: false),
            temperature: Float(config.sampling.temperature),
            top_p: Float(config.sampling.topP),
            tools: nil,
            user: nil,
            response_format: nil
        )

        var finished = false
        for await chunk in stream {
            if let choice = chunk.choices.first {
                let delta = choice.delta
                if let content = delta.content, !content.isEmpty {
                    onToken(content, false)
                }
            }
            // When usage is present, the request has finished
            if chunk.usage != nil, !finished {
                finished = true
                onToken("", true)
            }
        }
        // In case no explicit usage arrived, finalize on stream end
        if !finished {
            onToken("", true)
        }
    }

    /// Aggregate a non-streaming result from a prompt using the streaming API.
    /// Returns the full generated text as a single string.
    public func generateTextAggregated(
        prompt: String,
        maxTokens: Int,
        temperature: Double,
        topP: Double
    ) async -> String {
        var aggregated = ""
        await generateTextStream(
            prompt: prompt,
            maxTokens: maxTokens,
            temperature: temperature,
            topP: topP
        ) { delta in
            aggregated += delta
        }
        return aggregated
    }

    /// Aggregate a non-streaming result for a multi-turn chat using the streaming API.
    /// Returns the assistant's complete response as a single string.
    public func generateChatAggregated(
        messages: [ChatMessage],
        config: GenerationConfig = GenerationConfig()
    ) async -> String {
        var aggregated = ""
        await generateChatCompletion(messages: messages, config: config) { token, _ in
            aggregated += token
        }
        return aggregated
    }
}
