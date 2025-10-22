<div align="center">

[![Build Status][build status badge]][build status]
[![Platforms][platforms badge]][platforms]
[![Matrix][matrix badge]][matrix]

</div>

# Gramophone

Swift library for working with [Extended Backus–Naur Form][ebnf] (EBNF) notation and the resulting grammars.

Features:
- Accepts a variety of BNF syntaxes
- Computes FIRST and FOLLOW sets

> [!WARNING]
> This library is still a work-in-progress. It definitely still has some issues.

## Integration

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/Gramophone")
]
```

## Supported Syntax

```
single_quote_terminal = 'value';
angled_quote_terminal = `value´;
double_quote_terminal = "value";
unicode_scalar = U+0000;
unicode_scalar_range = [U+0000-U+0005];
bnf_nonterminal = <value>;

concatenation = a, b, c;
implicit_concatenation = a b c;
alternation = a | b | c;
optional = [a, b];
tailing_optional = a?;
repetition = {a};
tailing_plus_repetition = a+;
tailing_star_repetition = a*;
grouping = (a, b, c);
exception = a - b;
multiple_alternation = a;
multiple_alternation = b;

arrow_assigment → a;
colon_colon_equals_assigment ::= a;

mult_line_expressions = a |
                        b |
                        c;
newline_statement_end = a

```

There's also a bunch of additional notation used by the W3C's [XQuery specification](https://www.w3.org/TR/xquery-31/#EBNFNotation), which may be work looking into.

## Usage

```swift
let grammar = try parser.parseGrammar("test = 'a' | 'b';")

let firstMap = grammar.computeFirstMap()
let followMap = grammar.computeFollowMap()
```

## Grammar Conversion

I made a dumb script that converts Swift's [formal grammar](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/summaryofthegrammar) to EBNF because, for some reason, it is not in that format right now. I would have liked to implement that itself in Swift, but it Got Hard. So I fell back to Ruby. If you want to get involved with this, I would recommend [rbenv](https://github.com/rbenv/rbenv).

```
# cd Scripts
# bundle exec ruby convert_swift_grammar.rb > ../Grammars/Swift.ebnf
```

It's pretty hard to eyeball the conversion correctness because the grammar is complex and uses some facilities that are not typical of EBNF (shocker!). This library cannot yet correctly parse or even represent all of the things the grammar needs, but it's getting closer.

## Contributing and Collaboration

I would love to hear from you! Issues or pull requests work great. Both a [Matrix space][matrix] and [Discord][discord] are available for live help, but I have a strong bias towards answering in the form of documentation. You can also find me on [mastodon](https://mastodon.social/@mattiem).

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

[build status]: https://github.com/ChimeHQ/Gramophone/actions
[build status badge]: https://github.com/ChimeHQ/Gramophone/workflows/CI/badge.svg
[platforms]: https://swiftpackageindex.com/ChimeHQ/Gramophone
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FGramophone%2Fbadge%3Ftype%3Dplatforms
[matrix]: https://matrix.to/#/%23chimehq%3Amatrix.org
[matrix badge]: https://img.shields.io/matrix/chimehq%3Amatrix.org?label=Matrix
[discord]: https://discord.gg/esFpX6sErJ
[ebnf]: https://en.wikipedia.org/wiki/Extended_Backus–Naur_form
