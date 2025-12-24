import 'package:test/test.dart';
import 'package:markdownx/markdownx.dart';

void main() {
  group('MarkdownxParser', () {
    test('parses solvable equations', () {
      final markdown = r'![$F = ma$](eq:F=m*a)';
      final result = MarkdownxParser.parse(markdown);

      expect(result.equations.length, 1);
      expect(result.equations.first.type, MarkdownxElementType.equation);
      expect(result.equations.first.content, 'F=m*a');
      expect(result.equations.first.display, r'$F = ma$');
    });

    test('parses graphable equations', () {
      final markdown = r'![$y = x^2$](grapheq:y=x^2)';
      final result = MarkdownxParser.parse(markdown);

      expect(result.equations.length, 1);
      expect(result.equations.first.type, MarkdownxElementType.graphEquation);
      expect(result.equations.first.content, 'y=x^2');
    });

    test('parses simulation tags', () {
      final markdown = '[[Simulation:pendulum]]';
      final result = MarkdownxParser.parse(markdown);

      expect(result.simulations.length, 1);
      expect(result.simulations.first.content, 'pendulum');
    });

    test('parses simulation images', () {
      final markdown = '![Demo](simulation:wave_demo)';
      final result = MarkdownxParser.parse(markdown);

      expect(result.simulations.length, 1);
      expect(result.simulations.first.content, 'wave_demo');
    });

    test('parses inline LaTeX', () {
      final markdown = r'The equation $E = mc^2$ is famous.';
      final result = MarkdownxParser.parse(markdown);

      expect(result.latex.length, 1);
      expect(result.latex.first.type, MarkdownxElementType.latex);
      expect(result.latex.first.content, 'E = mc^2');
    });

    test('parses block LaTeX', () {
      final markdown = r'$$\int_0^1 x^2 dx$$';
      final result = MarkdownxParser.parse(markdown);

      expect(result.latex.length, 1);
      expect(result.latex.first.type, MarkdownxElementType.latexBlock);
    });

    test('strips HTML comments', () {
      final markdown = 'Hello <!-- comment --> World';
      final result = MarkdownxParser.parse(markdown);

      expect(result.strippedMarkdown, 'Hello  World');
    });

    test('parses multiple elements', () {
      final markdown = '''
![\$F = ma\$](eq:F=m*a)
[[Simulation:demo]]
\$E = mc^2\$
      ''';
      final result = MarkdownxParser.parse(markdown);

      expect(result.equations.length, 1);
      expect(result.simulations.length, 1);
      expect(result.latex.length, greaterThanOrEqualTo(1));
      expect(result.hasCustomElements, isTrue);
    });

    test('hasEquations returns correctly', () {
      expect(MarkdownxParser.hasEquations(r'![$x$](eq:x=1)'), isTrue);
      expect(MarkdownxParser.hasEquations('no equations here'), isFalse);
    });

    test('hasSimulations returns correctly', () {
      expect(MarkdownxParser.hasSimulations('[[Simulation:test]]'), isTrue);
      expect(MarkdownxParser.hasSimulations('![](simulation:test)'), isTrue);
      expect(MarkdownxParser.hasSimulations('no simulations'), isFalse);
    });

    test('hasLatex returns correctly', () {
      expect(MarkdownxParser.hasLatex(r'$x^2$'), isTrue);
      expect(MarkdownxParser.hasLatex(r'$$y = mx$$'), isTrue);
      expect(MarkdownxParser.hasLatex('no latex'), isFalse);
    });

    test('URL-decodes equations', () {
      // %5E is URL-encoded ^
      final markdown = r'![$x^2$](eq:y=x%5E2)';
      final result = MarkdownxParser.parse(markdown);

      expect(result.equations.first.content, 'y=x^2');
    });
  });

  group('MarkdownxElement', () {
    test('factory constructors work', () {
      final eq = MarkdownxElement.equation(
        equation: 'F=m*a',
        displayLatex: r'$F=ma$',
        start: 0,
        end: 10,
      );
      expect(eq.type, MarkdownxElementType.equation);

      final sim = MarkdownxElement.simulation(
        name: 'test',
        start: 0,
        end: 5,
      );
      expect(sim.type, MarkdownxElementType.simulation);

      final tex = MarkdownxElement.latex(
        latex: 'x^2',
        start: 0,
        end: 5,
        isBlock: true,
      );
      expect(tex.type, MarkdownxElementType.latexBlock);
    });
  });
}
