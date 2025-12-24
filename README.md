# markdownx

Extended markdown parser with custom syntax for equations, simulations, and LaTeX math.

[![pub package](https://img.shields.io/pub/v/markdownx.svg)](https://pub.dev/packages/markdownx)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 🧮 **Solvable Equations** - `![$LaTeX$](eq:equation)` syntax
- 📈 **Graphable Equations** - `![$LaTeX$](grapheq:equation)` syntax
- 🎮 **Simulation Embeds** - `[[Simulation:name]]` or `![alt](simulation:name)`
- 📐 **LaTeX Math** - Inline `$...$` and block `$$...$$`
- 🔍 **Pure Dart** - No Flutter dependency, works everywhere

## Installation

```yaml
dependencies:
  markdownx: ^1.0.0
```

## Quick Start

```dart
import 'package:markdownx/markdownx.dart';

void main() {
  final markdown = '''
# Physics Equation

Newton's second law:
![\$F = ma\$](eq:F=m*a)

Energy: \$E = mc^2\$

[[Simulation:pendulum]]
''';

  final result = MarkdownxParser.parse(markdown);
  
  print('Equations: ${result.equations.length}'); // 1
  print('LaTeX: ${result.latex.length}'); // 1
  print('Simulations: ${result.simulations.length}'); // 1
}
```

## Custom Syntax

### Solvable Equations

```markdown
![$F = ma$](eq:F=m*a)
```

- **Display**: `$F = ma$` - The LaTeX to render
- **Equation**: `F=m*a` - Parseable equation for solving

### Graphable Equations

```markdown
![$y = x^2$](grapheq:y=x^2)
```

Same as equations, but indicates the equation can be graphed.

### Simulations

Two syntaxes supported:

```markdown
[[Simulation:pendulum]]
![Pendulum Demo](simulation:pendulum)
```

### LaTeX Math

```markdown
Inline: $E = mc^2$

Block:
$$
\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}
$$
```

## API Reference

### MarkdownxParser

```dart
// Parse markdown and get all elements
final result = MarkdownxParser.parse(markdown);

// Access by type
result.equations;    // All equations
result.simulations;  // All simulations
result.latex;        // All LaTeX expressions

// Quick checks
MarkdownxParser.hasEquations(markdown);
MarkdownxParser.hasSimulations(markdown);
MarkdownxParser.hasLatex(markdown);
MarkdownxParser.hasCustomSyntax(markdown);

// Extract specific types
MarkdownxParser.extractEquations(markdown);
MarkdownxParser.extractSimulations(markdown);
MarkdownxParser.extractLatex(markdown);

// Utility
MarkdownxParser.stripComments(markdown); // Remove HTML comments
```

### MarkdownxElement

```dart
final element = result.equations.first;

element.type;     // MarkdownxElementType.equation
element.content;  // 'F=m*a'
element.display;  // '$F = ma$'
element.start;    // Start position in source
element.end;      // End position in source
```

### Integration with markdown package

```dart
import 'package:markdown/markdown.dart';
import 'package:markdownx/markdownx.dart';

// Use markdownx syntaxes with the markdown package
final document = Document(
  inlineSyntaxes: markdownxInlineSyntaxes,
);

final html = markdownToHtml(
  markdown,
  inlineSyntaxes: markdownxInlineSyntaxes,
);
```

## Element Types

| Type | Syntax | Description |
|------|--------|-------------|
| `equation` | `![$](eq:...)` | Solvable equation |
| `graphEquation` | `![$](grapheq:...)` | Graphable equation |
| `simulation` | `[[Simulation:...]]` | Interactive simulation |
| `latex` | `$...$` | Inline LaTeX |
| `latexBlock` | `$$...$$` | Block LaTeX |
| `text` | - | Regular text |

## License

MIT License - see [LICENSE](LICENSE) for details.
