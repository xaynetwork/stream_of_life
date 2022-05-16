import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:stream_of_life/src/plane/domain/cell.dart';

class LifetimeState {
  final HashSet<Cell> state;

  /// helper Lists, because creating copies of a HashSet in Dart is super slow :(
  final List<Cell> additions, removals;
  final bool isGenerationMilestone;

  const LifetimeState.growing(
    this.state, {
    required this.additions,
    required this.removals,
  }) : isGenerationMilestone = false;
  const LifetimeState.mature(this.state)
      : additions = const [],
        removals = const [],
        isGenerationMilestone = true;

  @override
  bool operator ==(Object other) {
    if (other is LifetimeState) {
      return other.isGenerationMilestone == isGenerationMilestone &&
          const SetEquality().equals(other.state, state);
    }

    return false;
  }

  @override
  int get hashCode => Object.hashAll([isGenerationMilestone, ...state]);

  @override
  String toString() =>
      'isGenerationMilestone: $isGenerationMilestone, state: $state';
}
