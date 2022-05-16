import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stream_of_life/src/plane/domain/cell.dart';
import 'package:stream_of_life/src/stream_transformers/conway_stream_transformer.dart';
import 'package:stream_of_life/src/plane/domain/lifetime_state.dart';
import 'package:stream_of_life/src/plane/plane.dart';
import 'package:stream_of_life/src/data/puffer_train_data.dart' as puffer_train;

const double _kCellSize = 3;

class Renderer extends StatefulWidget {
  const Renderer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RendererState();
}

class _RendererState extends State<Renderer> {
  late final Plane plane = Plane.seeded(puffer_train.dataSet);
  late final Stream<Set<Cell>> stream = plane.state.frameBound.conway(plane);

  @override
  Widget build(BuildContext context) => StreamBuilder<Set<Cell>>(
        stream: stream,
        builder: (context, snapshot) => snapshot.hasData
            ? Stack(
                fit: StackFit.expand,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      controller: ScrollController(
                          initialScrollOffset: 10000 - constraints.maxHeight),
                      child: CustomPaint(
                        painter: _Painter(snapshot.requireData),
                        isComplex: false,
                        willChange: true,
                        size: Size(constraints.maxWidth, 10000),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: DefaultTextStyle(
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                      child: Text('#events ${plane.eventCount}'),
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

extension _StreamExtension on Stream<LifetimeState> {
  Stream<LifetimeState> get frameBound =>
      asyncMap((it) => it.isGenerationMilestone
          ? WidgetsBinding.instance!.endOfFrame.then((_) => it)
          : Future.value(it));
}
