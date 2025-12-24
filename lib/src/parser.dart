import 'models.dart';

/// Parses extended markdown syntax into structured elements.
///
/// Supports:
/// - Equations: `![$LaTeX$](eq:equation)` and `![$LaTeX$](grapheq:equation)`
/// - Simulations: `![$alt](simulation:name)` and `[[Simulation:name]]`
/// - LaTeX: `$...$` inline and `$$...$$` block
///
/// Example:
/// ```dart
/// final result = MarkdownxParser.parse('''
/// # Newton's Second Law
///
/// The equation is:
/// ![$F = ma$](eq:F=m*a)
///
/// Inline math: $E = mc^2$
/// ''');
///
/// print(result.equations.length); // 1
/// print(result.latex.length); // 1
/// ```
class MarkdownxParser {
  MarkdownxParser._();

  // Regex patterns
  static final _equationPattern = RegExp(
    r'!\[([^\]]*)\]\((eq|grapheq):([^)]+)\)',
    caseSensitive: false,
  );

  static final _simulationTagPattern = RegExp(
    r'\[\[Simulation:([a-zA-Z0-9_\-]+)\]\]',
    caseSensitive: false,
  );

  static final _simulationImgPattern = RegExp(
    r'!\[([^\]]*)\]\(simulation:([^)]+)\)',
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

    // Parse equations
    for (final match in _equationPattern.allMatches(markdown)) {
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

    // Parse simulation tags [[Simulation:name]]
    for (final match in _simulationTagPattern.allMatches(markdown)) {
      final name = match.group(1) ?? '';
      elements.add(MarkdownxElement.simulation(
        name: name,
        start: match.start,
        end: match.end,
      ));
    }

    // Parse simulation images ![alt](simulation:name)
    for (final match in _simulationImgPattern.allMatches(markdown)) {
      final name = match.group(2) ?? '';
      elements.add(MarkdownxElement.simulation(
        name: name,
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

  /// Extracts all simulations from markdown.
  static List<MarkdownxElement> extractSimulations(String markdown) {
    return parse(markdown).simulations;
  }

  /// Extracts all LaTeX expressions from markdown.
  static List<MarkdownxElement> extractLatex(String markdown) {
    return parse(markdown).latex;
  }

  /// Checks if markdown contains any equations.
  static bool hasEquations(String markdown) {
    return _equationPattern.hasMatch(markdown);
  }

  /// Checks if markdown contains any simulations.
  static bool hasSimulations(String markdown) {
    return _simulationTagPattern.hasMatch(markdown) ||
        _simulationImgPattern.hasMatch(markdown);
  }

  /// Checks if markdown contains any LaTeX.
  static bool hasLatex(String markdown) {
    return _latexBlockPattern.hasMatch(markdown) ||
        _latexInlinePattern.hasMatch(markdown);
  }

  /// Checks if markdown contains any custom markdownx syntax.
  static bool hasCustomSyntax(String markdown) {
    return hasEquations(markdown) ||
        hasSimulations(markdown) ||
        hasLatex(markdown);
  }
}
