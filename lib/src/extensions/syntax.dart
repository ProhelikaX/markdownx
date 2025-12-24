import 'package:markdown/markdown.dart';

/// Custom inline syntax for LaTeX expressions using `$...$`.
class LatexInlineSyntax extends InlineSyntax {
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

/// Custom inline syntax for generic custom protocols: `![$alt](protocol:value)`.
///
/// This captures any protocol that's not a reserved one (eq, grapheq).
class CustomProtocolSyntax extends InlineSyntax {
  /// Reserved protocols that have their own handlers.
  static const _reservedProtocols = {'eq', 'grapheq'};

  CustomProtocolSyntax()
      : super(r'!\[([^\]]*)\]\(([a-zA-Z][a-zA-Z0-9_]*):([^)]+)\)');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final alt = match.group(1) ?? '';
    final protocol = match.group(2)!.toLowerCase();
    final value = Uri.decodeComponent(match.group(3) ?? '');

    // Skip reserved protocols
    if (_reservedProtocols.contains(protocol)) {
      return false;
    }

    final element = Element.text('custom', value);
    element.attributes['protocol'] = protocol;
    if (alt.isNotEmpty) {
      element.attributes['alt'] = alt;
    }
    parser.addNode(element);
    return true;
  }
}

/// Custom inline syntax for bracket tags: `[[Protocol:value]]`.
class BracketTagSyntax extends InlineSyntax {
  BracketTagSyntax() : super(r'\[\[([a-zA-Z][a-zA-Z0-9_]*):([^\]]+)\]\]');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final protocol = match.group(1)!.toLowerCase();
    final value = match.group(2) ?? '';

    final element = Element.text('custom', value);
    element.attributes['protocol'] = protocol;
    parser.addNode(element);
    return true;
  }
}

/// All markdownx inline syntaxes for use with the markdown package.
///
/// Use with:
/// ```dart
/// final html = markdownToHtml(
///   markdown,
///   inlineSyntaxes: markdownxInlineSyntaxes,
/// );
/// ```
List<InlineSyntax> get markdownxInlineSyntaxes => [
      LatexBlockSyntax(),
      LatexInlineSyntax(),
      EquationSyntax(),
      CustomProtocolSyntax(),
      BracketTagSyntax(),
    ];

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
      inlineSyntaxes: markdownxInlineSyntaxes,
    );
  }
}
