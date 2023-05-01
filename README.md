[![Github CI](https://github.com/ChimeHQ/Gramophone/workflows/CI/badge.svg)](https://github.com/ChimeHQ/Gramophone/actions)

# Gramophone

Swift library for parsing [Extended Backus–Naur Form]() (EBNF) notation.

## Integration

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/Gramophone")
]
```

## Usage

```swift
let result = parser.parse("test = 'a' | 'b';")
```

## Suggestions or Feedback

We'd love to hear from you! Get in touch via an issue or pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
