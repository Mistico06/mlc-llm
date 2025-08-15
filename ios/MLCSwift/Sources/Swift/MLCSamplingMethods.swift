import Foundation

// Pure sampling utilities kept as an extension for convenience.
// These do not depend on any private engine state or unsupported APIs.
extension MLCEngine {
    // Temperature scaling + optional top-k + nucleus (top-p) sampling over logits.
    public func sampleWithNucleus(
        logits: [Double],
        temperature: Double,
        topP: Double,
        topK: Int = 0
    ) -> Int {
        // Guard against degenerate inputs
        guard !logits.isEmpty else { return 0 }

        // Temperature scaling (avoid divide-by-zero)
        let invTemp = 1.0 / max(temperature, 1e-8)
        let scaled = logits.map { $0 * invTemp }

        // Numerically stable softmax
        let maxL = scaled.max() ?? 0
        let expScores = scaled.map { exp($0 - maxL) }
        let sum = expScores.reduce(0, +)
        if sum <= 0 {
            // Fallback: pick argmax if probabilities collapse
            return logits.indices.max(by: { logits[$0] < logits[$1] }) ?? 0
        }
        let probs = expScores.map { $0 / sum }

        // Sort by probability descending
        let sorted = probs.enumerated().sorted { $0.element > $1.element }

        // Optional top-k filtering
        let kFiltered =
