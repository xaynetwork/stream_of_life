import 'package:flutter/material.dart';
import 'package:stream_of_life/src/cell.dart';
import 'package:stream_of_life/src/conway_rule_set.dart';
import 'package:stream_of_life/src/puffer_train_data.dart' as puffer_train;

const double _kCellSize = 4;

class Renderer extends StatefulWidget {
  const Renderer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RendererState();
}

class _RendererState extends State<Renderer> {
  late final ConwayRuleSet game = ConwayRuleSet.seeded(
    puffer_train.dataSet,
    readySignal: (state) =>
        WidgetsBinding.instance!.endOfFrame.then((_) => state),
  );
  late final stream = game.events;

  @override
  void dispose() {
    super.dispose();

    game.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<Set<Cell>>(
        stream: stream,
        builder: (context, snapshot) => snapshot.hasData
            ? CustomPaint(painter: _Painter(snapshot.requireData))
            : Container(),
      );
}

class _Painter extends CustomPainter {
  final Set<Cell> grid;

  const _Painter(this.grid);

  @override
  void paint(Canvas canvas, Size size) {
    for (final cell in grid) {
      final dx = size.width / 2 + cell.x * _kCellSize,
          dy = size.height + cell.y * _kCellSize;

      if (size.contains(Offset(dx, dy))) {
        canvas.drawRect(
            Rect.fromCenter(
              center: Offset(dx, dy),
              width: _kCellSize,
              height: _kCellSize,
            ),
            Paint()..color = Colors.green);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
