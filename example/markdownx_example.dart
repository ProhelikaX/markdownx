import 'package:markdownx/markdownx.dart';

void main() {
  print('=== markdownx Examples ===\n');

  final markdown = '''
# Physics Equations

## Newton's Second Law
![\$F = ma\$](eq:F=m*a)

## Energy-Mass Equivalence
![\$E = mc^2\$](grapheq:E=m*c^2)

## Interactive Demo
[[Simulation:pendulum]]

## Math Examples
Inline LaTeX: \$\\alpha + \\beta = \\gamma\$

Block LaTeX:
\$\$
\\int_0^\\infty e^{-x^2} dx = \\frac{\\sqrt{\\pi}}{2}
\$\$

<!-- This comment should be stripped -->
''';

  // Parse the markdown
  final result = MarkdownxParser.parse(markdown);

  // Show results
  print('Source length: ${result.source.length} chars');
  print('Total elements: ${result.elements.length}');
  print('');

  // Equations
  print('📐 Equations (${result.equations.length}):');
  for (final eq in result.equations) {
    final type = eq.type == MarkdownxElementType.graphEquation
        ? 'graphable'
        : 'solvable';
    print('  - ${eq.display} → ${eq.content} ($type)');
  }
  print('');

  // Simulations
  print('🎮 Simulations (${result.simulations.length}):');
  for (final sim in result.simulations) {
    print('  - ${sim.content}');
  }
  print('');

  // LaTeX
  print('📝 LaTeX (${result.latex.length}):');
  for (final tex in result.latex) {
    final type =
        tex.type == MarkdownxElementType.latexBlock ? 'block' : 'inline';
    print(
        '  - ${tex.content.substring(0, tex.content.length.clamp(0, 30))}... ($type)');
  }
  print('');

  // Quick checks
  print('✅ Has equations: ${MarkdownxParser.hasEquations(markdown)}');
  print('✅ Has simulations: ${MarkdownxParser.hasSimulations(markdown)}');
  print('✅ Has LaTeX: ${MarkdownxParser.hasLatex(markdown)}');
  print('✅ Has custom syntax: ${MarkdownxParser.hasCustomSyntax(markdown)}');
}
