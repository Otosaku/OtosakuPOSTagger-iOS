# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftPOSTagger is a Swift Package Manager library for part-of-speech tagging. This is a minimal Swift package setup with:

- **Sources/SwiftPOSTagger/SwiftPOSTagger.swift**: Main library implementation (currently contains only boilerplate comments)
- **Tests/SwiftPOSTaggerTests/SwiftPOSTaggerTests.swift**: Test suite using Swift Testing framework
- **Package.swift**: Standard SPM configuration targeting Swift 6.0

## Development Commands

### Building
```bash
swift build
```

### Running Tests
```bash
swift test
```

### Running a Single Test
```bash
swift test --filter testName
```

## Code Architecture

This is a fresh Swift package with minimal structure:

- The main library code goes in `Sources/SwiftPOSTagger/SwiftPOSTagger.swift`
- Tests use the modern Swift Testing framework (not XCTest) with `@Test` annotations
- The package follows standard Swift Package Manager conventions
- Swift 6.0 is the minimum required version

## Testing Framework

The project uses Swift Testing (not XCTest). Tests are written with:
- `@Test` function annotations instead of XCTest's `test` prefix convention
- `#expect(...)` assertions instead of XCTest's `XCTAssert` family
- `@testable import SwiftPOSTagger` for accessing internal APIs