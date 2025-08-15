//
//  LLMEngine+Enhanced.swift
//  MLCSwift
//
//  Enhancements built on top of MLCEngine's OpenAI-compatible streaming API.
//  - Simple text streaming for a single prompt
//  - Multi-turn chat streaming with completion signal
//  - No reliance on tokenize/generate/detokenize methods
//

import Foundation

// MARK: - Convenience helpers on MLCEngine

extension MLCEngine {
    /// Stream tokens for a single-prompt completion by consuming the engine's chat stream.
    /// Concatenate deltas in the caller if an aggregated result is required.
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

        // MLCEngine streams OpenAI-style deltas
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
            if let delta = chunk.choices.first?.delta?.content, !delta.isEmpty {
                onToken(delta)
            }
        }
    }

    /// Stream tokens for multi-turn chat by consuming the engine's chat stream.
    /// Calls `onToken(token, false)` as tokens arrive and `onToken("", true)` when complete.
    public func generateChatCompletion(
        messages: [ChatMessage],
        config: GenerationConfig = GenerationConfig(),
        onToken: @escaping (String, Bool) -> Void
    ) async {
        // Convert your ChatMessage to engine's ChatCompletionMessage
        let mlcMessages = messages.map { ChatCompletionMessage(role: $0.role, content: $0.content) }

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
            if let delta = chunk.choices.first?.delta?.content, !delta.isEmpty {
                onToken(delta, false)
            }
            // Final usage indicates the stream is complete for this request
            if chunk.usage != nil, !finished {
                finished = true
                onToken("", true)
            }
        }
        // If no explicit "usage" arrived, still finalize once stream ends
        if !finished {
            onToken("", true)
        }
    }

    /// Aggregate a non-streaming result from a prompt using the streaming API.
    /// This is a convenience wrapper that returns the full generated text.
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
    /// Returns the complete generated assistant message as a single string.
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
