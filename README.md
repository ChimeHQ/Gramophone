[![Build Status][build status badge]][build status]
[![License][license badge]][license]
[![Platforms][platforms badge]][platforms]

# Gramophone

Swift library for parsing [Extended Backus–Naur Form]() (EBNF) notation.

## Integration

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/Gramophone")
]
```

## Supported Syntax

```
definition = 'value';
concatenation = a, b, c;
alternation = a | b | c;
optional = [a, b];
repetition = {a};
```

## Usage

```swift
let result = parser.parse("test = 'a' | 'b';")
```

## Suggestions or Feedback

We'd love to hear from you! Get in touch via an issue or pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

[build status]: https://github.com/ChimeHQ/Gramophone/actions
[build status badge]: https://github.com/ChimeHQ/Gramophone/workflows/CI/badge.svg
[license]: https://opensource.org/licenses/BSD-3-Clause
[license badge]: https://img.shields.io/github/license/ChimeHQ/Gramophone
[platforms]: https://swiftpackageindex.com/ChimeHQ/Gramophone
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FGramophone%2Fbadge%3Ftype%3Dplatforms
