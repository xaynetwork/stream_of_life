import 'package:stream_of_life/src/plane/domain/cell.dart';

abstract class PlaneController {
  void add(Cell cell);

  void remove(Cell cell);

  void markGeneration();

  void dispose();
}
