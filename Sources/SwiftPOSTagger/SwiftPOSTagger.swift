// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CoreML

enum SwiftPOSTaggerError: Error {
    case modelLoadingFailed(String)
    case tokenizerInitializationFailed(String)
    case outputExtractionFailed(String)
    case inputTooLong(Int, Int)
    case predictionFailed(String)
}

public class SwiftPOSTagger {
    private let model: MLModel
    private let tokenizer: BertTokenizer
    private let outTokens: [String]
    
    public init(modelDirectoryURL: URL, computeUnits: MLComputeUnits = .all) throws {
        let modelURL = modelDirectoryURL.appendingPathComponent("Model.mlmodelc")
        let vocabURL = modelDirectoryURL.appendingPathComponent("vocab.txt")
        let outTokensURL = modelDirectoryURL.appendingPathComponent("outTokens.txt")
        
        let configuration = MLModelConfiguration()
        configuration.computeUnits = computeUnits
        self.model = try MLModel(contentsOf: modelURL, configuration: configuration)
        self.tokenizer = BertTokenizer(vocab: vocabURL)
        
        // Read outTokens.txt
        let outTokensContent = try String(contentsOf: outTokensURL, encoding: .utf8)
        self.outTokens = outTokensContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
    }
    
    
    
    private func predict(text: String) throws -> Any {
        var tokens = self.tokenizer.tokenizeToIds(text: text)
        tokens.insert(101, at: 0)
        tokens.append(102)
        let input_ids = try! MLMultiArray(shape: [1, 128], dataType: .int32)
        let attention_mask = try! MLMultiArray(shape: [1, 128], dataType: .int32)
        for i in 0..<128 {
            if i < tokens.count {
                input_ids[[0, i as NSNumber]] = tokens[i] as NSNumber
                attention_mask[[0, i as NSNumber]] = 1
            } else {
                input_ids[[0, i as NSNumber]] = 0
                attention_mask[[0, i as NSNumber]] = 0
            }
        }
        let featureProvider = try MLDictionaryFeatureProvider(dictionary: [
            "input_ids": MLFeatureValue(multiArray: input_ids),
            "attention_mask": MLFeatureValue(multiArray: attention_mask),
        ])
        let out = try model.prediction(from: featureProvider)

        guard let tokenScores = out.featureValue(for: "token_scores")?.multiArrayValue else {
            throw SwiftPOSTaggerError.outputExtractionFailed("Failed to extract token_scores from model output")
        }
        print("tokenScores shape:", tokenScores.shape)
        
        // Get the actual number of tokens (excluding CLS and SEP)
        let actualTokenCount = tokens.count - 2  // Remove CLS (101) and SEP (102)
        
        // Calculate argmax for each token position (skip index 0 which is CLS)
        var predictedTags: [String] = []
        
        for tokenIndex in 1..<(actualTokenCount + 1) {  // Start from 1 to skip CLS token
            var maxScore: Float = -Float.infinity
            var maxClassIndex = 0
            
            // Find argmax across all classes for this token
            for classIndex in 0..<outTokens.count {
                let scoreIndex = [0, tokenIndex, classIndex] as [NSNumber]
                let score = tokenScores[scoreIndex].floatValue
                
                if score > maxScore {
                    maxScore = score
                    maxClassIndex = classIndex
                }
            }
            
            // Map to label
            let predictedTag = outTokens[maxClassIndex]
            predictedTags.append(predictedTag)
        }
        
        // Print results
        print("📋 POS Tagging Results:")
        let inputTokens = tokenizer.tokenize(text: text)
        for (index, (token, tag)) in zip(inputTokens, predictedTags).enumerated() {
            print("  \(index + 1). '\(token)' -> \(tag)")
        }
        
        return predictedTags
    }
    
    public func test(text: String) throws -> Any {
        return try predict(text: text)
    }
}
