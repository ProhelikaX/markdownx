/// Extended markdown parser with custom syntax for equations, simulations, and LaTeX.
///
/// markdownx provides parsing for:
/// - **Equations**: `![$LaTeX$](eq:equation)` for solvable equations
/// - **Graph Equations**: `![$LaTeX$](grapheq:equation)` for graphable equations
/// - **Simulations**: `![$alt](simulation:name)` or `[[Simulation:name]]`
/// - **LaTeX**: `$...$` for inline and `$$...$$` for block math
///
/// ## Quick Start
///
/// ```dart
/// import 'package:markdownx/markdownx.dart';
///
/// void main() {
///   final markdown = '''
/// # Physics Equation
///
/// Newton's second law:
/// ![\$F = ma\$](eq:F=m*a)
///
/// Energy equation: \$E = mc^2\$
/// ''';
///
///   final result = MarkdownxParser.parse(markdown);
///   print('Equations: ${result.equations.length}');
///   print('LaTeX: ${result.latex.length}');
/// }
/// ```
library;

export 'src/models.dart';
export 'src/parser.dart';
export 'src/extensions/syntax.dart';
