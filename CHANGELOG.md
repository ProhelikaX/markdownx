# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [1.0.1] - 2026-01-21

### Fixed
- Bumped `test` dev dependency and updated resolved `pubspec.lock`.
- Added explicit `platforms` declaration to `pubspec.yaml` so pub.dev can detect platform support.
- Added CI workflow and `analysis_options.yaml` for consistent static analysis and docs.
- Added dartdoc comments for several constructors to improve documentation coverage.

### Changed
- Minor maintenance and infrastructure updates.

## [1.0.0] - 2024-12-24

### Added
- Initial release
- `MarkdownxParser` for parsing extended markdown syntax
- `MarkdownxElement` model for parsed elements
- `MarkdownxParseResult` for aggregated parse results
- **Generic custom protocols** - Define any protocol you need:
  - Image syntax: `![alt](protocol:value)`
  - Bracket syntax: `[[Protocol:value]]`
- Support for solvable equations: `![$LaTeX$](eq:equation)`
- Support for graphable equations: `![$LaTeX$](grapheq:equation)`
- Support for inline LaTeX: `$...$`
- Support for block LaTeX: `$$...$$`
- Protocol filtering: `result.byProtocol('video')`
- Protocol discovery: `result.protocols` returns all unique protocols
- `hasProtocol(markdown, 'name')` to check for specific protocols
- HTML comment stripping
- Integration with markdown package via `markdownxInlineSyntaxes`
