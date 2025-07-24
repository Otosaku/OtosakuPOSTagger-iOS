//
//  ContentView.swift
//  Example
//
//  Created by Marat Zainullin on 24/07/2025.
//

import SwiftUI
import SwiftPOSTagger
import ZIPFoundation

struct ContentView: View {
    @State private var tagger: SwiftPOSTagger?
    @State private var isModelDownloaded = false
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0.0
    @State private var testText = "The quick brown fox jumps over the lazy dog."
    @State private var testResult: [(String, String)] = []
    
    private let modelURL = "https://firebasestorage.googleapis.com/v0/b/my-project-1494707780868.firebasestorage.app/o/quantized-bert-pos-tag.zip?alt=media&token=cd8b9030-8abd-4385-9fb9-9ec27ae5cad7"
    private let modelDirectoryName = "POSModel"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("SwiftPOSTagger Example")
                .font(.title)
                .padding()
            
            if !isModelDownloaded {
                Button(action: downloadModel) {
                    HStack {
                        if isDownloading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isDownloading ? "Downloading..." : "Download Model")
                    }
                }
                .disabled(isDownloading)
                .buttonStyle(.borderedProminent)
                
                if isDownloading {
                    ProgressView(value: downloadProgress)
                        .padding(.horizontal)
                }
            } else {
                Text("Model Ready")
                    .foregroundColor(.green)
                    .font(.headline)
                
                if tagger != nil {
                    Text("Library Initialized Successfully")
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 10) {
                        TextField("Enter text to test", text: $testText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        Button("Test POS Tagging") {
                            testPOSTagging()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if !testResult.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(Array(testResult.enumerated()), id: \.offset) { index, pair in
                                        HStack {
                                            Text(pair.0)
                                                .fontWeight(.medium)
                                            Text("→")
                                                .foregroundColor(.gray)
                                            Text(pair.1)
                                                .foregroundColor(.blue)
                                                .font(.caption)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.blue.opacity(0.1))
                                                .cornerRadius(4)
                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                            .frame(maxHeight: 200)
                        }
                    }
                    .padding(.top)
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            checkModelAvailability()
        }
    }
    
    private func checkModelAvailability() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let modelPath = documentsPath.appendingPathComponent(modelDirectoryName)
        // Files are in subdirectory "quantized-bert-pos-tag"
        let actualModelPath = modelPath.appendingPathComponent("quantized-bert-pos-tag")
        let modelFile = actualModelPath.appendingPathComponent("Model.mlmodelc")
        let vocabFile = actualModelPath.appendingPathComponent("vocab.txt")
        
        if FileManager.default.fileExists(atPath: modelFile.path) && 
           FileManager.default.fileExists(atPath: vocabFile.path) {
            isModelDownloaded = true
            initializeLibrary()
        }
    }
    
    private func downloadModel() {
        isDownloading = true
        downloadProgress = 0.0
        
        guard let url = URL(string: modelURL) else {
            print("Invalid URL")
            isDownloading = false
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let zipPath = documentsPath.appendingPathComponent("model.zip")
        
        let task = URLSession.shared.downloadTask(with: url) { [self] tempURL, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Download failed: \(error)")
                    self.isDownloading = false
                    return
                }
                
                guard let tempURL = tempURL else {
                    print("No temporary URL")
                    self.isDownloading = false
                    return
                }
                
                do {
                    // Copy downloaded file to documents directory
                    if FileManager.default.fileExists(atPath: zipPath.path) {
                        try FileManager.default.removeItem(at: zipPath)
                    }
                    try FileManager.default.copyItem(at: tempURL, to: zipPath)
                    
                    // Extract the zip file
                    self.extractZipFile(at: zipPath)
                } catch {
                    print("Failed to process download: \(error)")
                    self.isDownloading = false
                }
            }
        }
        
        // Observe download progress
        let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                self.downloadProgress = progress.fractionCompleted
            }
        }
        
        task.resume()
    }
    
    private func extractZipFile(at zipPath: URL) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let extractPath = documentsPath.appendingPathComponent(modelDirectoryName)
        
        do {
            // Remove existing model directory if it exists
            if FileManager.default.fileExists(atPath: extractPath.path) {
                try FileManager.default.removeItem(at: extractPath)
            }
            
            // Create model directory
            try FileManager.default.createDirectory(at: extractPath, withIntermediateDirectories: true)
            
            print("📁 Extracting zip to: \(extractPath.path)")
            
            // Extract zip using ZIPFoundation
            try FileManager.default.unzipItem(at: zipPath, to: extractPath)
            
            print("✅ Extraction completed")
            
            // Log extracted contents
            self.logDirectoryContents(at: extractPath)
            
            // Clean up zip file
            try FileManager.default.removeItem(at: zipPath)
            
            // Update UI
            self.isDownloading = false
            self.isModelDownloaded = true
            self.initializeLibrary()
            
        } catch {
            print("❌ Failed to extract zip: \(error)")
            self.isDownloading = false
        }
    }
    
    private func logDirectoryContents(at path: URL) {
        print("📋 Contents of \(path.path):")
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            for item in contents {
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: item.path, isDirectory: &isDirectory)
                let type = isDirectory.boolValue ? "📁" : "📄"
                print("  \(type) \(item.lastPathComponent)")
                
                // If it's a directory, log its contents too
                if isDirectory.boolValue {
                    print("    Contents of \(item.lastPathComponent):")
                    if let subContents = try? FileManager.default.contentsOfDirectory(at: item, includingPropertiesForKeys: nil) {
                        for subItem in subContents {
                            print("      📄 \(subItem.lastPathComponent)")
                        }
                    }
                }
            }
        } catch {
            print("❌ Failed to list directory contents: \(error)")
        }
    }
    
    private func initializeLibrary() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let modelPath = documentsPath.appendingPathComponent(modelDirectoryName)
        
        print("🔍 Checking model directory: \(modelPath.path)")
        self.logDirectoryContents(at: modelPath)
        
        // Files are in subdirectory "quantized-bert-pos-tag"
        let actualModelPath = modelPath.appendingPathComponent("quantized-bert-pos-tag")
        let modelFile = actualModelPath.appendingPathComponent("ModelQuantized.mlmodelc")
        let vocabFile = actualModelPath.appendingPathComponent("vocab.txt")
        
        print("🔍 Looking for model file: \(modelFile.path)")
        print("📄 Model file exists: \(FileManager.default.fileExists(atPath: modelFile.path))")
        print("🔍 Looking for vocab file: \(vocabFile.path)")
        print("📄 Vocab file exists: \(FileManager.default.fileExists(atPath: vocabFile.path))")
        
        do {
            tagger = try SwiftPOSTagger(modelDirectoryURL: actualModelPath)
            print("✅ SwiftPOSTagger initialized successfully")
        } catch {
            print("❌ Failed to initialize SwiftPOSTagger: \(error)")
        }
    }
    
    private func testPOSTagging() {
        guard let tagger = tagger else {
            testResult = [("Error", "Tagger not initialized")]
            return
        }
        
        do {
            let result = try tagger.predict(text: testText)
            testResult = result
        } catch {
            testResult = [("Error", error.localizedDescription)]
        }
    }
}
//
//#Preview {
//    ContentView()
//}
