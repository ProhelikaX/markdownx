import 'package:markdown/markdown.dart';

/// Custom inline syntax for LaTeX expressions using `$...$`.
///
/// This syntax recognizes inline LaTeX like `$E = mc^2$` and converts
/// it to a custom element that can be handled by a custom renderer.
class LatexInlineSyntax extends InlineSyntax {
  /// Creates a LaTeX inline syntax parser.
  LatexInlineSyntax() : super(r'\$([^\$\n]+)\$');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final latex = match.group(1) ?? '';
    final element = Element.text('latex', latex);
    element.attributes['type'] = 'inline';
    parser.addNode(element);
    return true;
  }
}

/// Custom inline syntax for LaTeX blocks using `$$...$$`.
class LatexBlockSyntax extends InlineSyntax {
  /// Creates a LaTeX block syntax parser.
  LatexBlockSyntax() : super(r'\$\$([^\$]+)\$\$');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final latex = match.group(1) ?? '';
    final element = Element.text('latex', latex.trim());
    element.attributes['type'] = 'block';
    parser.addNode(element);
    return true;
  }
}

/// Custom inline syntax for equations: `![$LaTeX$](eq:equation)`.
class EquationSyntax extends InlineSyntax {
  /// Creates an equation syntax parser.
  EquationSyntax() : super(r'!\[([^\]]*)\]\((eq|grapheq):([^)]+)\)');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final displayLatex = match.group(1) ?? '';
    final type = match.group(2)!.toLowerCase();
    final equation = Uri.decodeComponent(match.group(3) ?? '');

    final element = Element.text('equation', equation);
    element.attributes['display'] = displayLatex;
    element.attributes['graphable'] = (type == 'grapheq').toString();
    parser.addNode(element);
    return true;
  }
}

/// Custom inline syntax for simulations: `![$alt](simulation:name)`.
class SimulationImageSyntax extends InlineSyntax {
  /// Creates a simulation image syntax parser.
  SimulationImageSyntax() : super(r'!\[([^\]]*)\]\(simulation:([^)]+)\)');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final alt = match.group(1) ?? '';
    final name = match.group(2) ?? '';

    final element = Element.text('simulation', name);
    element.attributes['alt'] = alt;
    parser.addNode(element);
    return true;
  }
}

/// Custom block syntax for simulation tags: `[[Simulation:name]]`.
class SimulationTagSyntax extends InlineSyntax {
  /// Creates a simulation tag syntax parser.
  SimulationTagSyntax() : super(r'\[\[Simulation:([a-zA-Z0-9_\-]+)\]\]');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final name = match.group(1) ?? '';
    final element = Element.text('simulation', name);
    parser.addNode(element);
    return true;
  }
}

/// Extension to create markdown documents with markdownx syntax support.
extension MarkdownxExtension on Document {
  /// Creates a markdown document with markdownx inline syntaxes.
  static Document withMarkdownxSyntax({
    ExtensionSet? extensionSet,
    Resolver? linkResolver,
    Resolver? imageLinkResolver,
    bool encodeHtml = true,
  }) {
    return Document(
      extensionSet: extensionSet,
      linkResolver: linkResolver,
      imageLinkResolver: imageLinkResolver,
      encodeHtml: encodeHtml,
      inlineSyntaxes: [
        LatexBlockSyntax(),
        LatexInlineSyntax(),
        EquationSyntax(),
        SimulationImageSyntax(),
        SimulationTagSyntax(),
      ],
    );
  }
}

/// All markdownx inline syntaxes for use with the markdown package.
List<InlineSyntax> get markdownxInlineSyntaxes => [
      LatexBlockSyntax(),
      LatexInlineSyntax(),
      EquationSyntax(),
      SimulationImageSyntax(),
      SimulationTagSyntax(),
    ];
