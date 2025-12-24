import 'models.dart';

/// Parses extended markdown syntax into structured elements.
///
/// Supports:
/// - Equations: `![$LaTeX$](eq:equation)` and `![$LaTeX$](grapheq:equation)`
/// - Custom protocols: `![$alt](protocol:value)` and `[[Protocol:value]]`
/// - LaTeX: `$...$` inline and `$$...$$` block
///
/// Example:
/// ```dart
/// final result = MarkdownxParser.parse('''
/// # Interactive Content
///
/// ![$F = ma$](eq:F=m*a)
/// [[Simulation:pendulum]]
/// ![Video](video:intro.mp4)
/// ''');
///
/// print(result.equations.length); // 1
/// print(result.byProtocol('simulation').length); // 1
/// print(result.byProtocol('video').length); // 1
/// ```
class MarkdownxParser {
  MarkdownxParser._();

  /// Reserved protocols that are handled specially.
  static const _reservedProtocols = {'eq', 'grapheq'};

  // Regex patterns
  static final _equationPattern = RegExp(
    r'!\[([^\]]*)\]\((eq|grapheq):([^)]+)\)',
    caseSensitive: false,
  );

  // Generic custom protocol: ![alt](protocol:value)
  // Excludes reserved protocols (eq, grapheq)
  static final _customImgPattern = RegExp(
    r'!\[([^\]]*)\]\(([a-zA-Z][a-zA-Z0-9_]*):([^)]+)\)',
    caseSensitive: false,
  );

  // Generic bracket tag: [[Protocol:value]]
  static final _customTagPattern = RegExp(
    r'\[\[([a-zA-Z][a-zA-Z0-9_]*):([^\]]+)\]\]',
    caseSensitive: false,
  );

  static final _latexBlockPattern = RegExp(
    r'\$\$([^\$]+)\$\$',
  );

  static final _latexInlinePattern = RegExp(
    r'(?<!\$)\$([^\$\n]+)\$(?!\$)',
  );

  static final _htmlCommentPattern = RegExp(
    r'<!--[\s\S]*?-->',
  );

  /// Parses markdown content and extracts all markdownx elements.
  static MarkdownxParseResult parse(String markdown) {
    final elements = <MarkdownxElement>[];
    var strippedMarkdown = markdown;

    // Strip HTML comments first
    strippedMarkdown = strippedMarkdown.replaceAll(_htmlCommentPattern, '');

    // Parse equations first (they take precedence)
    final equationMatches = <Match>{};
    for (final match in _equationPattern.allMatches(markdown)) {
      equationMatches.add(match);
      final displayLatex = match.group(1) ?? '';
      final type = match.group(2)!.toLowerCase();
      final equation = Uri.decodeComponent(match.group(3) ?? '');

      elements.add(MarkdownxElement.equation(
        equation: equation,
        displayLatex: displayLatex,
        start: match.start,
        end: match.end,
        graphable: type == 'grapheq',
      ));
    }

    // Parse custom image protocols: ![alt](protocol:value)
    for (final match in _customImgPattern.allMatches(markdown)) {
      final protocol = match.group(2)!.toLowerCase();

      // Skip reserved protocols (already handled above)
      if (_reservedProtocols.contains(protocol)) continue;

      // Skip if this match overlaps with an equation match
      if (equationMatches.any((eq) =>
          (match.start >= eq.start && match.start < eq.end) ||
          (match.end > eq.start && match.end <= eq.end))) {
        continue;
      }

      final alt = match.group(1) ?? '';
      final value = Uri.decodeComponent(match.group(3) ?? '');

      elements.add(MarkdownxElement.custom(
        protocol: protocol,
        value: value,
        alt: alt.isNotEmpty ? alt : null,
        start: match.start,
        end: match.end,
      ));
    }

    // Parse custom bracket tags: [[Protocol:value]]
    for (final match in _customTagPattern.allMatches(markdown)) {
      final protocol = match.group(1)!.toLowerCase();
      final value = match.group(2) ?? '';

      elements.add(MarkdownxElement.custom(
        protocol: protocol,
        value: value,
        start: match.start,
        end: match.end,
      ));
    }

    // Parse LaTeX blocks $$...$$
    for (final match in _latexBlockPattern.allMatches(markdown)) {
      final latex = match.group(1) ?? '';
      elements.add(MarkdownxElement.latex(
        latex: latex.trim(),
        start: match.start,
        end: match.end,
        isBlock: true,
      ));
    }

    // Parse LaTeX inline $...$
    for (final match in _latexInlinePattern.allMatches(markdown)) {
      final latex = match.group(1) ?? '';
      elements.add(MarkdownxElement.latex(
        latex: latex.trim(),
        start: match.start,
        end: match.end,
        isBlock: false,
      ));
    }

    // Sort by position
    elements.sort((a, b) => a.start.compareTo(b.start));

    return MarkdownxParseResult(
      source: markdown,
      elements: elements,
      strippedMarkdown: strippedMarkdown,
    );
  }

  /// Strips HTML comments from markdown.
  static String stripComments(String markdown) {
    return markdown.replaceAll(_htmlCommentPattern, '');
  }

  /// Extracts all equations from markdown.
  static List<MarkdownxElement> extractEquations(String markdown) {
    return parse(markdown).equations;
  }

  /// Extracts all custom protocol elements from markdown.
  static List<MarkdownxElement> extractCustom(String markdown) {
    return parse(markdown).custom;
  }

  /// Extracts custom elements with a specific protocol.
  static List<MarkdownxElement> extractByProtocol(
      String markdown, String protocol) {
    return parse(markdown).byProtocol(protocol);
  }

  /// Extracts all LaTeX expressions from markdown.
  static List<MarkdownxElement> extractLatex(String markdown) {
    return parse(markdown).latex;
  }

  /// Checks if markdown contains any equations.
  static bool hasEquations(String markdown) {
    return _equationPattern.hasMatch(markdown);
  }

  /// Checks if markdown contains any custom protocol elements.
  static bool hasCustom(String markdown) {
    // Check for bracket tags
    if (_customTagPattern.hasMatch(markdown)) return true;

    // Check for image protocols (excluding reserved)
    for (final match in _customImgPattern.allMatches(markdown)) {
      final protocol = match.group(2)?.toLowerCase() ?? '';
      if (!_reservedProtocols.contains(protocol)) return true;
    }

    return false;
  }

  /// Checks if markdown contains a specific protocol.
  static bool hasProtocol(String markdown, String protocol) {
    // Check bracket tags
    final tagPattern = RegExp(
      r'\[\[' + RegExp.escape(protocol) + r':([^\]]+)\]\]',
      caseSensitive: false,
    );
    if (tagPattern.hasMatch(markdown)) return true;

    // Check image protocols
    final imgPattern = RegExp(
      r'!\[([^\]]*)\]\(' + RegExp.escape(protocol) + r':([^)]+)\)',
      caseSensitive: false,
    );
    return imgPattern.hasMatch(markdown);
  }

  /// Checks if markdown contains any LaTeX.
  static bool hasLatex(String markdown) {
    return _latexBlockPattern.hasMatch(markdown) ||
        _latexInlinePattern.hasMatch(markdown);
  }

  /// Checks if markdown contains any custom markdownx syntax.
  static bool hasCustomSyntax(String markdown) {
    return hasEquations(markdown) || hasCustom(markdown) || hasLatex(markdown);
  }

  /// Gets all unique protocols used in the markdown.
  static Set<String> getProtocols(String markdown) {
    return parse(markdown).protocols;
  }
}
