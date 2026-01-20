/// Parsed element types in markdownx.
enum MarkdownxElementType {
  /// Solvable equation: `![$LaTeX$](eq:equation)`
  equation,

  /// Graphable equation: `![$LaTeX$](grapheq:equation)`
  graphEquation,

  /// Custom protocol: `![$alt](protocol:value)` or `[[Protocol:value]]`
  custom,

  /// Inline LaTeX: `$...$`
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
  /// - For custom: the value after the protocol
  /// - For latex: the LaTeX content
  /// - For text: the text content
  final String content;

  /// Optional display value (for equations, this is the LaTeX display).
  final String? display;

  /// The protocol/tag name for custom elements (e.g., "simulation", "video", "quiz").
  final String? protocol;

  /// Start position in the original markdown.
  final int start;

  /// End position in the original markdown.
  final int end;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a new [MarkdownxElement].
  ///
  /// Provide the [type] and [content]; other fields are optional metadata
  /// that describe the element's location and presentation.
  const MarkdownxElement({
    required this.type,
    required this.content,
    this.display,
    this.protocol,
    required this.start,
    required this.end,
    this.metadata,
  });

  @override
  String toString() {
    if (protocol != null) {
      return 'MarkdownxElement(type: $type, protocol: $protocol, content: $content)';
    }
    return 'MarkdownxElement(type: $type, content: $content)';
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

  /// Creates a custom protocol element.
  factory MarkdownxElement.custom({
    required String protocol,
    required String value,
    String? alt,
    required int start,
    required int end,
  }) {
    return MarkdownxElement(
      type: MarkdownxElementType.custom,
      content: value,
      protocol: protocol.toLowerCase(),
      display: alt,
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

  /// Whether this is a custom element with the given protocol.
  bool isProtocol(String name) {
    return type == MarkdownxElementType.custom &&
        protocol?.toLowerCase() == name.toLowerCase();
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

  /// Creates a [MarkdownxParseResult] for the given [source], [elements],
  /// and a [strippedMarkdown] representation for standard rendering.
  const MarkdownxParseResult({
    required this.source,
    required this.elements,
    required this.strippedMarkdown,
  });

  /// Gets all elements of a specific type.
  List<MarkdownxElement> byType(MarkdownxElementType type) {
    return elements.where((e) => e.type == type).toList();
  }

  /// Gets all custom elements with a specific protocol.
  List<MarkdownxElement> byProtocol(String protocol) {
    return elements.where((e) => e.isProtocol(protocol)).toList();
  }

  /// Gets all equations (both solvable and graphable).
  List<MarkdownxElement> get equations {
    return elements
        .where((e) =>
            e.type == MarkdownxElementType.equation ||
            e.type == MarkdownxElementType.graphEquation)
        .toList();
  }

  /// Gets all custom protocol elements.
  List<MarkdownxElement> get custom {
    return byType(MarkdownxElementType.custom);
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

  /// Gets all unique protocol names used in custom elements.
  Set<String> get protocols {
    return custom
        .where((e) => e.protocol != null)
        .map((e) => e.protocol!)
        .toSet();
  }
}
