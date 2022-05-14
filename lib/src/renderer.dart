import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stream_of_life/src/cell.dart';
import 'package:stream_of_life/src/conway_rule_set.dart';
import 'package:stream_of_life/src/puffer_train_data.dart' as puffer_train;

const double _kCellSize = 3;

class Renderer extends StatefulWidget {
  const Renderer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RendererState();
}

class _RendererState extends State<Renderer> {
  late final ConwayRuleSet game = ConwayRuleSet.seeded(
    puffer_train.dataSet,
    readySignal: () => WidgetsBinding.instance!.endOfFrame,
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
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _Painter(snapshot.requireData),
                    isComplex: false,
                    willChange: true,
                  ),
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: DefaultTextStyle(
                      style: const TextStyle(fontSize: 28, color: Colors.white),
                      child: Text('${snapshot.requireData.length}'),
                    ),
                  ),
                ],
              )
            : Container(),
      );
}

class _Painter extends CustomPainter {
  final Set<Cell> grid;

  const _Painter(this.grid);

  @override
  void paint(Canvas canvas, Size size) {
    const o = _kCellSize / 2;
    final paint = Paint()
      ..color = Colors.green
      ..isAntiAlias = false;
    final offsets = grid
        .map((cell) {
          final dx = size.width / 2 + cell.x * _kCellSize,
              dy = size.height + cell.y * _kCellSize;

          return [
            Offset(dx - o, dy - o),
            Offset(dx + o, dy - o),
            Offset(dx - o, dy + o),
            Offset(dx + o, dy + o),
            Offset(dx + o, dy - o),
            Offset(dx - o, dy + o),
          ];
        })
        .expand((it) => it)
        .toList(growable: false);

    canvas.drawVertices(
      Vertices(VertexMode.triangles, offsets),
      BlendMode.srcIn,
      paint,
    );
  }

  @override
  bool shouldRepaint(_Painter oldDelegate) => true;
}
