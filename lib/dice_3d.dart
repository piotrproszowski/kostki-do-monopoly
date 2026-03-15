import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v;

class Dice3D extends StatelessWidget {
  final double size;
  final double rotX;
  final double rotY;
  final double rotZ;
  final Color? highlightColor;

  const Dice3D({
    super.key,
    required this.size,
    required this.rotX,
    required this.rotY,
    required this.rotZ,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DicePainter(
          size: size,
          rotX: rotX,
          rotY: rotY,
          rotZ: rotZ,
          highlightColor: highlightColor,
        ),
      ),
    );
  }
}

class _DicePainter extends CustomPainter {
  final double size;
  final double rotX;
  final double rotY;
  final double rotZ;
  final Color? highlightColor;

  _DicePainter({
    required this.size,
    required this.rotX,
    required this.rotY,
    required this.rotZ,
    this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final double halfSize = size / 2;
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    final matrix = v.Matrix4.identity()
      ..rotateX(rotX)
      ..rotateY(rotY)
      ..rotateZ(rotZ);
    final List<_Face> faces = [
      _Face(
        id: 1,
        vertices: [
          v.Vector3(-halfSize, -halfSize, halfSize),
          v.Vector3(halfSize, -halfSize, halfSize),
          v.Vector3(halfSize, halfSize, halfSize),
          v.Vector3(-halfSize, halfSize, halfSize),
        ],
        normal: v.Vector3(0, 0, 1),
      ),
      _Face(
        id: 6,
        vertices: [
          v.Vector3(halfSize, -halfSize, -halfSize),
          v.Vector3(-halfSize, -halfSize, -halfSize),
          v.Vector3(-halfSize, halfSize, -halfSize),
          v.Vector3(halfSize, halfSize, -halfSize),
        ],
        normal: v.Vector3(0, 0, -1),
      ),
      _Face(
        id: 2,
        vertices: [
          v.Vector3(-halfSize, -halfSize, -halfSize),
          v.Vector3(halfSize, -halfSize, -halfSize),
          v.Vector3(halfSize, -halfSize, halfSize),
          v.Vector3(-halfSize, -halfSize, halfSize),
        ],
        normal: v.Vector3(0, -1, 0),
      ),
      _Face(
        id: 5,
        vertices: [
          v.Vector3(-halfSize, halfSize, halfSize),
          v.Vector3(halfSize, halfSize, halfSize),
          v.Vector3(halfSize, halfSize, -halfSize),
          v.Vector3(-halfSize, halfSize, -halfSize),
        ],
        normal: v.Vector3(0, 1, 0),
      ),
      _Face(
        id: 3,
        vertices: [
          v.Vector3(halfSize, -halfSize, halfSize),
          v.Vector3(halfSize, -halfSize, -halfSize),
          v.Vector3(halfSize, halfSize, -halfSize),
          v.Vector3(halfSize, halfSize, halfSize),
        ],
        normal: v.Vector3(1, 0, 0),
      ),
      _Face(
        id: 4,
        vertices: [
          v.Vector3(-halfSize, -halfSize, -halfSize),
          v.Vector3(-halfSize, -halfSize, halfSize),
          v.Vector3(-halfSize, halfSize, halfSize),
          v.Vector3(-halfSize, halfSize, -halfSize),
        ],
        normal: v.Vector3(-1, 0, 0),
      ),
    ];

    for (var face in faces) {
      face.transform(matrix);
    }

    faces.sort((a, b) => a.centerZ.compareTo(b.centerZ));

    for (var face in faces) {
      if (face.normalTransformed.z < 0) continue;

      _drawFace(canvas, face, center);
    }
  }

  void _drawFace(Canvas canvas, _Face face, Offset center) {
    final base = highlightColor ?? Colors.white;
    final lightDir = v.Vector3(0.5, -0.5, 1.0)..normalize();
    double intensity = face.normalTransformed.dot(lightDir);
    intensity = 0.5 + 0.5 * intensity;
    intensity = 0.6 + 0.4 * intensity;

    final Color faceColor = Color.lerp(Colors.black, base, intensity)!;

    final path = Path();
    final v0 = face.verticesTransformed[0];
    path.moveTo(center.dx + v0.x, center.dy + v0.y);
    for (int i = 1; i < face.verticesTransformed.length; i++) {
      final v = face.verticesTransformed[i];
      path.lineTo(center.dx + v.x, center.dy + v.y);
    }
    path.close();

    final paint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);

    final strokePaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    _drawDots(canvas, face, center);
  }

  void _drawDots(Canvas canvas, _Face face, Offset center) {
    final dotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final v0 = face.verticesTransformed[0];
    final v1 = face.verticesTransformed[1];
    final v3 = face.verticesTransformed[3];

    final right = (v1 - v0) * (1.0 / size);
    final down = (v3 - v0) * (1.0 / size);
    final origin = v0;

    void drawDot(double x, double y) {
      final path = Path();
      const r = 0.09;
      const steps = 16;

      final centerPos = origin + (right * (x * size)) + (down * (y * size));

      for (int i = 0; i < steps; i++) {
        final theta = (i / steps) * 2 * math.pi;
        final dx = r * math.cos(theta);
        final dy = r * math.sin(theta);

        final displacement = (right * (dx * size)) + (down * (dy * size));
        final vertex = centerPos + displacement;

        final offset = Offset(center.dx + vertex.x, center.dy + vertex.y);

        if (i == 0) {
          path.moveTo(offset.dx, offset.dy);
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
      }
      path.close();
      canvas.drawPath(path, dotPaint);
    }

    const mid = 0.5;
    const low = 0.25;
    const high = 0.75;

    switch (face.id) {
      case 1:
        drawDot(mid, mid);
        break;
      case 2:
        drawDot(high, low);
        drawDot(low, high);
        break;
      case 3:
        drawDot(high, low);
        drawDot(mid, mid);
        drawDot(low, high);
        break;
      case 4:
        drawDot(low, low);
        drawDot(high, low);
        drawDot(low, high);
        drawDot(high, high);
        break;
      case 5:
        drawDot(low, low);
        drawDot(high, low);
        drawDot(mid, mid);
        drawDot(low, high);
        drawDot(high, high);
        break;
      case 6:
        drawDot(low, low);
        drawDot(high, low);
        drawDot(low, mid);
        drawDot(high, mid);
        drawDot(low, high);
        drawDot(high, high);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DicePainter oldDelegate) {
    return rotX != oldDelegate.rotX ||
        rotY != oldDelegate.rotY ||
        rotZ != oldDelegate.rotZ ||
        highlightColor != oldDelegate.highlightColor ||
        size != oldDelegate.size;
  }
}

class _Face {
  final int id;
  final List<v.Vector3> vertices;
  final v.Vector3 normal;

  List<v.Vector3> verticesTransformed = [];
  v.Vector3 normalTransformed = v.Vector3.zero();
  double centerZ = 0;

  _Face({required this.id, required this.vertices, required this.normal});

  void transform(v.Matrix4 matrix) {
    verticesTransformed = vertices.map((v) => matrix.transformed3(v)).toList();

    normalTransformed = matrix.transformed3(normal)..normalize();

    double sumZ = 0;
    for (var v in verticesTransformed) {
      sumZ += v.z;
    }
    centerZ = sumZ / vertices.length;
  }
}
