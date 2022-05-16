import 'dart:async';

import 'package:stream_of_life/src/plane/domain/cell.dart';
import 'package:stream_of_life/src/plane/domain/lifetime_state.dart';
import 'package:stream_of_life/src/plane/plane_controller.dart';
import 'package:stream_of_life/src/stream_transformers/conway_stream_sink.dart';

/// Creates a new ConwayStreamTransformer.
/// This transformer requires a [PlaneController], it listens for
/// [LifetimeState.mature] events and then uses the `PlaneController` to create
/// a series of [LifetimeState.growing] tasks, followed by a final [LifetimeState.mature] marker.
class ConwayStreamTransformer
    extends StreamTransformerBase<LifetimeState, Set<Cell>> {
  final PlaneController _plane;

  ConwayStreamTransformer(this._plane);

  @override
  Stream<Set<Cell>> bind(Stream<LifetimeState> stream) =>
      Stream.eventTransformed(stream, (sink) => ConwayStreamSink(sink, _plane));
}

/// Shorthand for `(PlaneController plane) => stream.transform(ConwayStreamTransformer(plane))`
extension ConwayExtension on Stream<LifetimeState> {
  Stream<Set<Cell>> conway(PlaneController plane) =>
      transform(ConwayStreamTransformer(plane));
}
