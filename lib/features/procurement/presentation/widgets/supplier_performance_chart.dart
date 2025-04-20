import 'package:flutter/material.dart';

/// Data model for supplier performance
class SupplierPerformance {
  final String name;
  final double score;
  SupplierPerformance({required this.name, required this.score});
}

/// Robust, feature-rich SupplierPerformanceChart widget
class SupplierPerformanceChart extends StatefulWidget {
  final List<SupplierPerformance> data;
  final String title;
  final Color barColor;
  final Color backgroundColor;

  const SupplierPerformanceChart({
    Key? key,
    required this.data,
    this.title = 'Supplier Performance',
    this.barColor = Colors.blue,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  State<SupplierPerformanceChart> createState() =>
      _SupplierPerformanceChartState();
}

class _SupplierPerformanceChartState extends State<SupplierPerformanceChart> {
  int? _tappedBarIndex;
  Offset? _tapPosition;

  void _onTapDown(TapDownDetails details, int index) {
    setState(() {
      _tappedBarIndex = index;
      _tapPosition = details.localPosition;
    });
  }

  void _onTapCancel() {
    setState(() {
      _tappedBarIndex = null;
      _tapPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return Card(
      color: widget.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (data.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('No data available',
                    style: Theme.of(context).textTheme.bodyMedium),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      // Find which bar was tapped
                      final RenderBox box =
                          context.findRenderObject() as RenderBox;
                      final localPos =
                          box.globalToLocal(details.globalPosition);
                      final barIndex = _getBarIndexAtPosition(localPos,
                          constraints.maxWidth, constraints.maxHeight, data);
                      if (barIndex != null) {
                        _onTapDown(details, barIndex);
                      } else {
                        _onTapCancel();
                      }
                    },
                    onTapUp: (_) => _onTapCancel(),
                    onTapCancel: _onTapCancel,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: _BarChartPainter(
                              data: data,
                              barColor: widget.barColor,
                              tappedBarIndex: _tappedBarIndex,
                            ),
                          ),
                        ),
                        if (_tappedBarIndex != null && _tapPosition != null)
                          Positioned(
                            left: _tapPosition!.dx,
                            top: _tapPosition!.dy - 40,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${data[_tappedBarIndex!].name}: ${data[_tappedBarIndex!].score.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  int? _getBarIndexAtPosition(
      Offset pos, double width, double height, List<SupplierPerformance> data) {
    final barCount = data.length;
    if (barCount == 0) return null;
    final barWidth = width / (barCount * 2);
    for (int i = 0; i < barCount; i++) {
      final x = (i * 2 + 1) * barWidth;
      if (pos.dx >= x && pos.dx <= x + barWidth) {
        return i;
      }
    }
    return null;
  }
}

class _BarChartPainter extends CustomPainter {
  final List<SupplierPerformance> data;
  final Color barColor;
  final int? tappedBarIndex;

  _BarChartPainter(
      {required this.data, required this.barColor, this.tappedBarIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = barColor;
    final labelStyle = const TextStyle(fontSize: 11, color: Colors.black87);
    final maxScore = data
        .map((e) => e.score)
        .fold<double>(0, (prev, e) => e > prev ? e : prev);
    final barCount = data.length;
    final barWidth = size.width / (barCount * 2);
    final chartHeight = size.height - 32;
    final yOffset = 16.0;

    for (int i = 0; i < barCount; i++) {
      final score = data[i].score;
      final barHeight = maxScore == 0 ? 0 : (score / maxScore) * chartHeight;
      final x = (i * 2 + 1) * barWidth;
      final y = size.height - barHeight - yOffset;
      paint.color =
          (tappedBarIndex == i) ? barColor.withOpacity(0.7) : barColor;
      final rect = Rect.fromLTWH(
        x.toDouble(),
        y.toDouble(),
        barWidth.toDouble(),
        barHeight.toDouble(),
      );
      canvas.drawRect(rect, paint);
      // Draw supplier name
      final tp = TextPainter(
        text: TextSpan(text: data[i].name, style: labelStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: barWidth + 10);
      tp.paint(canvas,
          Offset(x + barWidth / 2 - tp.width / 2, size.height - yOffset + 2));
      // Draw score above bar
      final scoreTp = TextPainter(
        text: TextSpan(
            text: score.toStringAsFixed(1),
            style: labelStyle.copyWith(fontWeight: FontWeight.bold)),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: barWidth + 10);
      scoreTp.paint(
          canvas, Offset(x + barWidth / 2 - scoreTp.width / 2, y - 18));
    }
    // Draw axis
    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - yOffset),
        Offset(size.width, size.height - yOffset), axisPaint);
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.tappedBarIndex != tappedBarIndex ||
        oldDelegate.barColor != barColor;
  }
}
