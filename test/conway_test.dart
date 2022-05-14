import 'package:stream_of_life/src/cell.dart';
import 'package:stream_of_life/src/conway_rule_set.dart';
import 'package:test/test.dart';

const Matcher kIsDateTime = TypeMatcher<DateTime>();

void main() {
  test('WHEN only 1 cell THEN cell dies', () {
    final game = ConwayRuleSet.seeded({const Cell(x: 0, y: 0)});

    expect(
        game.events,
        emitsInOrder([
          {const Cell(x: 0, y: 0)},
          <Cell>{},
        ]));
  });

  test('WHEN only 2 cells THEN both cells die', () {
    final game =
        ConwayRuleSet.seeded({const Cell(x: 0, y: 0), const Cell(x: 1, y: 0)});

    expect(
        game.events,
        emitsInOrder([
          {const Cell(x: 0, y: 0), const Cell(x: 1, y: 0)},
          <Cell>{},
        ]));
  });
}