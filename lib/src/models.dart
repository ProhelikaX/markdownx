/// Parsed element types in markdownx.
enum MarkdownxElementType {
  /// Solvable equation: `![$LaTeX$](eq:equation)`
  equation,

  /// Graphable equation: `![$LaTeX$](grapheq:equation)`
  graphEquation,

  /// Simulation embed: `![$alt](simulation:name)` or `[[Simulation:name]]`
  simulation,

  /// Inline LaTeX: `$...$` or `$$...$$`
  latex,

  /// Block LaTeX: `$$...$$`
  latexBlock,

  /// Regular text content
  text,
}

/// A parsed element from markdownx content.
class MarkdownxElement {
  /// The type of this element.
  final MarkdownxElementType type;

  /// The raw content/value of the element.
  /// - For equations: the parseable equation string
  /// - For simulations: the simulation name
  /// - For latex: the LaTeX content
  /// - For text: the text content
  final String content;

  /// Optional display value (for equations, this is the LaTeX display).
  final String? display;

  /// Start position in the original markdown.
  final int start;

  /// End position in the original markdown.
  final int end;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  const MarkdownxElement({
    required this.type,
    required this.content,
    this.display,
    required this.start,
    required this.end,
    this.metadata,
  });

  @override
  String toString() {
    return 'MarkdownxElement(type: $type, content: $content, display: $display)';
  }

  /// Creates an equation element.
  factory MarkdownxElement.equation({
    required String equation,
    required String displayLatex,
    required int start,
    required int end,
    bool graphable = false,
  }) {
    return MarkdownxElement(
      type: graphable
          ? MarkdownxElementType.graphEquation
          : MarkdownxElementType.equation,
      content: equation,
      display: displayLatex,
      start: start,
      end: end,
    );
  }

  /// Creates a simulation element.
  factory MarkdownxElement.simulation({
    required String name,
    required int start,
    required int end,
  }) {
    return MarkdownxElement(
      type: MarkdownxElementType.simulation,
      content: name,
      start: start,
      end: end,
    );
  }

  /// Creates a LaTeX element.
  factory MarkdownxElement.latex({
    required String latex,
    required int start,
    required int end,
    bool isBlock = false,
  }) {
    return MarkdownxElement(
      type: isBlock
          ? MarkdownxElementType.latexBlock
          : MarkdownxElementType.latex,
      content: latex,
      start: start,
      end: end,
    );
  }

  /// Creates a text element.
  factory MarkdownxElement.text({
    required String text,
    required int start,
    required int end,
  }) {
    return MarkdownxElement(
      type: MarkdownxElementType.text,
      content: text,
      start: start,
      end: end,
    );
  }
}

/// Result of parsing markdownx content.
class MarkdownxParseResult {
  /// Original markdown content.
  final String source;

  /// Parsed elements in order of appearance.
  final List<MarkdownxElement> elements;

  /// Markdown content with custom syntax stripped (for standard rendering).
  final String strippedMarkdown;

  const MarkdownxParseResult({
    required this.source,
    required this.elements,
    required this.strippedMarkdown,
  });

  /// Gets all elements of a specific type.
  List<MarkdownxElement> byType(MarkdownxElementType type) {
    return elements.where((e) => e.type == type).toList();
  }

  /// Gets all equations (both solvable and graphable).
  List<MarkdownxElement> get equations {
    return elements
        .where((e) =>
            e.type == MarkdownxElementType.equation ||
            e.type == MarkdownxElementType.graphEquation)
        .toList();
  }

  /// Gets all simulations.
  List<MarkdownxElement> get simulations {
    return byType(MarkdownxElementType.simulation);
  }

  /// Gets all LaTeX elements (inline and block).
  List<MarkdownxElement> get latex {
    return elements
        .where((e) =>
            e.type == MarkdownxElementType.latex ||
            e.type == MarkdownxElementType.latexBlock)
        .toList();
  }

  /// Whether the content has any custom markdownx elements.
  bool get hasCustomElements {
    return elements.any((e) => e.type != MarkdownxElementType.text);
  }
}
