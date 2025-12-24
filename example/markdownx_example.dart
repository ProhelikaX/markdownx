import 'package:markdownx/markdownx.dart';

void main() {
  print('=== markdownx Examples ===\n');

  final markdown = '''
# Interactive Educational Content

## Physics Equations
![\$F = ma\$](eq:F=m*a)
![\$E = mc^2\$](grapheq:E=m*c^2)

## Interactive Elements
[[Simulation:pendulum]]
[[Quiz:physics_101]]
![Demo Video](video:intro.mp4)
![3D Model](model:molecule.glb)

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

  // Custom protocols (generic)
  print('🔌 Custom Protocols (${result.custom.length}):');
  for (final item in result.custom) {
    print('  - [${item.protocol}] ${item.content}');
    if (item.display != null) {
      print('    alt: ${item.display}');
    }
  }
  print('');

  // By specific protocol
  print('🎮 Simulations: ${result.byProtocol("simulation").length}');
  print('🎬 Videos: ${result.byProtocol("video").length}');
  print('❓ Quizzes: ${result.byProtocol("quiz").length}');
  print('🎨 3D Models: ${result.byProtocol("model").length}');
  print('');

  // All unique protocols
  print('📦 All protocols used: ${result.protocols}');
  print('');

  // Quick checks
  print('✅ Has equations: ${MarkdownxParser.hasEquations(markdown)}');
  print('✅ Has custom: ${MarkdownxParser.hasCustom(markdown)}');
  print(
      '✅ Has simulation: ${MarkdownxParser.hasProtocol(markdown, "simulation")}');
  print('✅ Has video: ${MarkdownxParser.hasProtocol(markdown, "video")}');
  print('✅ Has LaTeX: ${MarkdownxParser.hasLatex(markdown)}');
}
