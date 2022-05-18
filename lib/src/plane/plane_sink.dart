import 'package:stream_of_life/src/plane/domain/cell.dart';

abstract class PlaneSink {
  void add(Cell cell);

  void remove(Cell cell);

  void markGeneration();

  void dispose();
}
