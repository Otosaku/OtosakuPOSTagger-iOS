// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CoreML

public class SwiftPOSTagger {
    private let model: MLModel
    private let tokenizer: BertTokenizer
    
    public init(modelDirectoryURL: URL, computeUnits: MLComputeUnits = .all) throws {
        let modelURL = modelDirectoryURL.appendingPathComponent("Model.mlmodelc")
        let vocabURL = modelDirectoryURL.appendingPathComponent("vocab.txt")
        
        let configuration = MLModelConfiguration()
        configuration.computeUnits = computeUnits
        self.model = try MLModel(contentsOf: modelURL, configuration: configuration)
        self.tokenizer = BertTokenizer(vocab: vocabURL)
    }
}
