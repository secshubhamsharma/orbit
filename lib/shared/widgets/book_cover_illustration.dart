import 'dart:math' as math;

import 'package:flutter/material.dart';

class BookCoverIllustration extends StatelessWidget {
  final String bookId;
  final double width;
  final double height;
  final double borderRadius;

  const BookCoverIllustration({
    super.key,
    required this.bookId,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 8,
  });

  static const _palettes = [
    [Color(0xFF7C6FE8), Color(0xFF4ECDC4)],
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
    [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    [Color(0xFFF093FB), Color(0xFFF5576C)],
    [Color(0xFF43CBFF), Color(0xFF9708CC)],
    [Color(0xFFFA709A), Color(0xFFFEE140)],
    [Color(0xFF30CFD0), Color(0xFF330867)],
    [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
    [Color(0xFF0BA360), Color(0xFF3CBA92)],
    [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
  ];

  List<Color> _paletteFor(String id) {
    int hash = 0;
    for (final ch in id.codeUnits) {
      hash = (hash * 31 + ch) & 0xFFFFFFFF;
    }
    return _palettes[hash.abs() % _palettes.length];
  }

  String _labelFor(String id) {
    final clean = id.replaceAll(RegExp(r'[-_]'), ' ').trim();
    if (clean.length <= 6) return clean.toUpperCase();
    final parts = clean.split(' ');
    if (parts.length >= 2) {
      return parts.map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();
    }
    return clean.substring(0, 4).toUpperCase();
  }

  String _subtitleFor(String id) {
    return id
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(bookId);
    final label = _labelFor(bookId);
    final subtitle = _subtitleFor(bookId);
    final seed = bookId.isEmpty ? 0 : bookId.codeUnitAt(0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _CoverPainter(
            topColor: palette[0],
            bottomColor: palette[1],
            seed: seed,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopAccent(color: palette[1]),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopAccent extends StatelessWidget {
  final Color color;
  const _TopAccent({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 8,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _CoverPainter extends CustomPainter {
  final Color topColor;
  final Color bottomColor;
  final int seed;

  const _CoverPainter({
    required this.topColor,
    required this.bottomColor,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [topColor, bottomColor],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final r = math.Random(seed);
    for (var i = 0; i < 5; i++) {
      final cx = r.nextDouble() * size.width;
      final cy = r.nextDouble() * size.height;
      final radius = 20.0 + r.nextDouble() * 50;
      canvas.drawCircle(Offset(cx, cy), radius, circlePaint);
    }

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    for (var i = 0; i < 6; i++) {
      final y = (i + 1) * size.height / 7;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final cornerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final cornerPath = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.35)
      ..lineTo(size.width * 0.65, 0)
      ..close();
    canvas.drawPath(cornerPath, cornerPaint);
  }

  @override
  bool shouldRepaint(_CoverPainter old) =>
      old.topColor != topColor ||
      old.bottomColor != bottomColor ||
      old.seed != seed;
}
