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

    test('parses bracket tags as custom', () {
      final markdown = '[[Simulation:pendulum]]';
      final result = MarkdownxParser.parse(markdown);

      expect(result.custom.length, 1);
      expect(result.custom.first.protocol, 'simulation');
      expect(result.custom.first.content, 'pendulum');
    });

    test('parses image protocols as custom', () {
      final markdown = '![Demo](video:wave_demo.mp4)';
      final result = MarkdownxParser.parse(markdown);

      expect(result.custom.length, 1);
      expect(result.custom.first.protocol, 'video');
      expect(result.custom.first.content, 'wave_demo.mp4');
      expect(result.custom.first.display, 'Demo');
    });

    test('parses multiple custom protocols', () {
      final markdown = '''
[[Simulation:pendulum]]
![Quiz](quiz:physics_1)
[[Video:intro]]
      ''';
      final result = MarkdownxParser.parse(markdown);

      expect(result.custom.length, 3);
      expect(result.protocols, {'simulation', 'quiz', 'video'});
    });

    test('byProtocol filters correctly', () {
      final markdown = '''
[[Simulation:pendulum]]
[[Simulation:wave]]
[[Video:intro]]
      ''';
      final result = MarkdownxParser.parse(markdown);

      expect(result.byProtocol('simulation').length, 2);
      expect(result.byProtocol('video').length, 1);
      expect(result.byProtocol('quiz').length, 0);
    });

    test('hasProtocol works correctly', () {
      final markdown = '[[Simulation:test]] ![alt](video:intro.mp4)';

      expect(MarkdownxParser.hasProtocol(markdown, 'simulation'), isTrue);
      expect(MarkdownxParser.hasProtocol(markdown, 'video'), isTrue);
      expect(MarkdownxParser.hasProtocol(markdown, 'quiz'), isFalse);
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

    test('hasCustom returns correctly', () {
      expect(MarkdownxParser.hasCustom('[[Test:value]]'), isTrue);
      expect(MarkdownxParser.hasCustom('![](video:test)'), isTrue);
      expect(MarkdownxParser.hasCustom('no custom here'), isFalse);
      // Reserved protocols should NOT count as custom
      expect(MarkdownxParser.hasCustom(r'![$x$](eq:x=1)'), isFalse);
    });

    test('hasEquations returns correctly', () {
      expect(MarkdownxParser.hasEquations(r'![$x$](eq:x=1)'), isTrue);
      expect(MarkdownxParser.hasEquations('no equations here'), isFalse);
    });

    test('hasLatex returns correctly', () {
      expect(MarkdownxParser.hasLatex(r'$x^2$'), isTrue);
      expect(MarkdownxParser.hasLatex(r'$$y = mx$$'), isTrue);
      expect(MarkdownxParser.hasLatex('no latex'), isFalse);
    });

    test('URL-decodes equations', () {
      final markdown = r'![$x^2$](eq:y=x%5E2)';
      final result = MarkdownxParser.parse(markdown);

      expect(result.equations.first.content, 'y=x^2');
    });

    test('URL-decodes custom protocols', () {
      final markdown = '![](video:path%2Fto%2Ffile.mp4)';
      final result = MarkdownxParser.parse(markdown);

      expect(result.custom.first.content, 'path/to/file.mp4');
    });

    test('getProtocols returns all unique protocols', () {
      final markdown = '''
[[Simulation:a]]
[[Simulation:b]]
[[Video:c]]
![](quiz:d)
      ''';
      final protocols = MarkdownxParser.getProtocols(markdown);

      expect(protocols, {'simulation', 'video', 'quiz'});
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

      final custom = MarkdownxElement.custom(
        protocol: 'simulation',
        value: 'test',
        start: 0,
        end: 5,
      );
      expect(custom.type, MarkdownxElementType.custom);
      expect(custom.protocol, 'simulation');

      final tex = MarkdownxElement.latex(
        latex: 'x^2',
        start: 0,
        end: 5,
        isBlock: true,
      );
      expect(tex.type, MarkdownxElementType.latexBlock);
    });

    test('isProtocol works correctly', () {
      final element = MarkdownxElement.custom(
        protocol: 'Simulation',
        value: 'test',
        start: 0,
        end: 10,
      );

      expect(element.isProtocol('simulation'), isTrue);
      expect(element.isProtocol('SIMULATION'), isTrue);
      expect(element.isProtocol('video'), isFalse);
    });
  });
}
