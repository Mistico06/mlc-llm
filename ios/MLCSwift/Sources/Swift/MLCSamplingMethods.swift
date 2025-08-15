import Foundation

extension LLMEngine {
    public func sampleWithNucleus(
        logits: [Double],
        temperature: Double,
        topP: Double,
        topK: Int = 0
    ) -> Int {
        let scaled = logits.map { $0 / max(temperature, 1e-8) }
        let maxL = scaled.max() ?? 0
        let expScores = scaled.map { exp($0 - maxL) }
        let sum = expScores.reduce(0, +)
        let probs = expScores.map { $0 / max(sum, 1e-8) }
        let sorted = probs.enumerated().sorted { $0.element > $1.element }
        let kFiltered = topK > 0 ? Array(sorted.prefix(topK)) : sorted
        var total = 0.0
        var nucleus: [(Int, Double)] = []
        for (index, prob) in kFiltered {
            total += prob
            nucleus.append((index, prob))
            if total >= topP { break }
        }
        let norm = nucleus.map { $0.1 }.reduce(0, +)
        let normalized = nucleus.map { ($0.0, $0.1 / norm) }
        let rand = Double.random(in: 0..<1)
        var acc = 0.0
        for (index, prob) in normalized {
            acc += prob
            if rand < acc { return index }
        }
        return normalized.last?.0 ?? 0
    }
    
    public func applyPenalties(
        logits: inout [Double],
        generatedTokens: [Int],
        frequencyPenalty: Double,
        presencePenalty: Double
    ) {
        guard frequencyPenalty != 0 || presencePenalty != 0 else { return }
        var tokenCounts: [Int: Int] = [:]
        for token in generatedTokens { tokenCounts[token, default: 0] += 1 }
        for (token, count) in tokenCounts where token < logits.count {
            logits[token] -= frequencyPenalty * Double(count)
            logits[token] -= presencePenalty
        }
    }
}
