# SwiftPOSTagger

A Swift package for Part-of-Speech (POS) tagging using BERT-based machine learning models with CoreML integration.

## Features

- 🧠 **BERT-based Model**: Utilizes a quantized BERT model for accurate POS tagging
- 📱 **iOS/macOS Support**: Compatible with iOS 16+ and macOS 12+
- ⚡ **CoreML Integration**: Optimized for Apple Silicon and GPU acceleration
- 🔄 **Automatic Model Management**: Built-in model download and extraction
- 🎯 **Simple API**: Clean, easy-to-use interface
- 📦 **Swift Package Manager**: Easy integration into your projects

## Installation

### Swift Package Manager

Add SwiftPOSTagger to your project using Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/YourUsername/SwiftPOSTagger`
3. Select the version you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/YourUsername/SwiftPOSTagger", from: "1.0.0")
]
```

## Usage

### Basic Usage

```swift
import SwiftPOSTagger

// Initialize the tagger with model directory
let modelDirectoryURL = // URL to directory containing model files
let tagger = try SwiftPOSTagger(modelDirectoryURL: modelDirectoryURL)

// Perform POS tagging
let text = "The quick brown fox jumps over the lazy dog."
let results = try tagger.predict(text: text)

// Results is an array of (word, tag) tuples
for (word, tag) in results {
    print("\(word) -> \(tag)")
}
```

### Example Output

```
The -> DT
quick -> JJ
brown -> JJ
fox -> NN
jumps -> VBZ
over -> IN
the -> DT
lazy -> JJ
dog -> NN
. -> .
```

### Model Setup

The library expects a directory containing:
- `ModelQuantized.mlmodelc` - The CoreML model file
- `vocab.txt` - BERT vocabulary file
- `outTokens.txt` - POS tag labels

You can download the pre-trained model or use your own compatible BERT-based POS tagging model.

### Compute Units

You can specify which compute units to use for inference:

```swift
// Use Neural Engine (default)
let tagger = try SwiftPOSTagger(modelDirectoryURL: modelURL, computeUnits: .all)

// Use CPU only
let tagger = try SwiftPOSTagger(modelDirectoryURL: modelURL, computeUnits: .cpuOnly)

// Use GPU only
let tagger = try SwiftPOSTagger(modelDirectoryURL: modelURL, computeUnits: .cpuAndGPU)
```

## Model Information

This library uses a quantized BERT model specifically fine-tuned for Part-of-Speech tagging. The model:

- **Architecture**: BERT-base with classification head
- **Quantization**: INT8 quantized for efficient mobile inference
- **Input**: Tokenized text with BERT tokenization
- **Output**: POS tags following Penn Treebank tagset
- **Context Length**: Supports up to 128 tokens per inference

### Supported POS Tags

The model outputs tags from the Penn Treebank tagset, including:
- **NN** (Noun, singular), **NNS** (Noun, plural)
- **VB** (Verb, base form), **VBZ** (Verb, 3rd person singular)
- **JJ** (Adjective), **RB** (Adverb)
- **DT** (Determiner), **IN** (Preposition)
- **CC** (Coordinating conjunction)
- And many more...

## Example App

The repository includes a complete example iOS app demonstrating:
- Automatic model download and setup
- Real-time POS tagging with visual results
- Error handling and user feedback

To run the example:
1. Open `Example/Example.xcodeproj`
2. Build and run on iOS Simulator or device
3. Download the model and test with your own text

## Error Handling

The library provides comprehensive error handling:

```swift
do {
    let results = try tagger.predict(text: text)
    // Process results
} catch SwiftPOSTaggerError.modelLoadingFailed(let message) {
    print("Model loading failed: \(message)")
} catch SwiftPOSTaggerError.outputExtractionFailed(let message) {
    print("Output extraction failed: \(message)")
} catch {
    print("Other error: \(error)")
}
```

## Requirements

- iOS 16.0+ / macOS 12.0+
- Xcode 14.0+
- Swift 6.0+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- Built with Apple's CoreML framework
- Uses BERT architecture for natural language understanding
- Tokenization based on BERT WordPiece tokenizer