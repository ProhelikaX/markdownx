# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-24

### Added
- Initial release
- `MarkdownxParser` for parsing extended markdown syntax
- `MarkdownxElement` model for parsed elements
- `MarkdownxParseResult` for aggregated parse results
- Support for solvable equations: `![$LaTeX$](eq:equation)`
- Support for graphable equations: `![$LaTeX$](grapheq:equation)`
- Support for simulations: `[[Simulation:name]]` and `![alt](simulation:name)`
- Support for inline LaTeX: `$...$`
- Support for block LaTeX: `$$...$$`
- HTML comment stripping
- Integration with markdown package via `markdownxInlineSyntaxes`
