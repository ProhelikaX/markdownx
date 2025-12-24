# markdownx

Extended markdown parser with custom syntax for equations, dynamic protocols, and LaTeX math.

[![pub package](https://img.shields.io/pub/v/markdownx.svg)](https://pub.dev/packages/markdownx)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 🧮 **Solvable Equations** - `![$LaTeX$](eq:equation)` syntax
- 📈 **Graphable Equations** - `![$LaTeX$](grapheq:equation)` syntax
- 🔌 **Custom Protocols** - Define your own: `![alt](protocol:value)` or `[[Protocol:value]]`
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
# Interactive Content

![\$F = ma\$](eq:F=m*a)
[[Simulation:pendulum]]
![Demo](video:intro.mp4)
''';

  final result = MarkdownxParser.parse(markdown);
  
  print(result.equations.length);           // 1
  print(result.byProtocol('simulation'));   // [simulation:pendulum]
  print(result.byProtocol('video'));        // [video:intro.mp4]
  print(result.protocols);                  // {simulation, video}
}
```

## Custom Protocols

Define any protocol you need! markdownx supports two syntaxes:

### Image-style syntax
```markdown
![alt text](protocol:value)
```

### Bracket-style syntax
```markdown
[[Protocol:value]]
```

### Examples

```markdown
# Simulations
[[Simulation:pendulum]]
![Physics Demo](simulation:wave_demo)

# Videos
![Intro Video](video:intro.mp4)
[[Video:tutorial.mp4]]

# Quizzes
[[Quiz:physics_101]]

# 3D Models
![Molecule](model:water.glb)

# Any custom protocol
[[MyProtocol:any_value_here]]
```

### Working with protocols

```dart
final result = MarkdownxParser.parse(markdown);

// Get all custom elements
result.custom;

// Filter by protocol
result.byProtocol('simulation');
result.byProtocol('video');
result.byProtocol('quiz');

// Get all unique protocols
result.protocols;  // {simulation, video, quiz, ...}

// Check for specific protocol
MarkdownxParser.hasProtocol(markdown, 'simulation');
```

## Equations

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

## LaTeX Math

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
result.equations;           // All equations
result.custom;              // All custom protocol elements
result.latex;               // All LaTeX expressions
result.byProtocol('video'); // Filter by protocol

// Get all protocols used
result.protocols;           // Set<String>

// Quick checks
MarkdownxParser.hasEquations(markdown);
MarkdownxParser.hasCustom(markdown);
MarkdownxParser.hasProtocol(markdown, 'simulation');
MarkdownxParser.hasLatex(markdown);
MarkdownxParser.hasCustomSyntax(markdown);

// Extract specific types
MarkdownxParser.extractEquations(markdown);
MarkdownxParser.extractCustom(markdown);
MarkdownxParser.extractByProtocol(markdown, 'video');
MarkdownxParser.extractLatex(markdown);
MarkdownxParser.getProtocols(markdown);

// Utility
MarkdownxParser.stripComments(markdown);
```

### MarkdownxElement

```dart
final element = result.custom.first;

element.type;      // MarkdownxElementType.custom
element.protocol;  // 'simulation'
element.content;   // 'pendulum'
element.display;   // alt text (for image syntax)
element.start;     // Start position in source
element.end;       // End position in source

// Check protocol
element.isProtocol('simulation');  // true
```

### Integration with markdown package

```dart
import 'package:markdown/markdown.dart';
import 'package:markdownx/markdownx.dart';

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
| `custom` | `![$](protocol:...)` / `[[Protocol:...]]` | Any custom protocol |
| `latex` | `$...$` | Inline LaTeX |
| `latexBlock` | `$$...$$` | Block LaTeX |
| `text` | - | Regular text |

## License

MIT License - see [LICENSE](LICENSE) for details.
