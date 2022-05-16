import 'package:stream_of_life/src/plane/domain/lifetime_state.dart';

abstract class PlaneStream {
  Stream<LifetimeState> get state;
}
