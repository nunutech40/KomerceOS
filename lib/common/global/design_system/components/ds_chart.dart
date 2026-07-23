import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_radius.dart';
import 'package:komtim_partner/common/global/design_system/app_spacing.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';

class DsChart extends StatefulWidget {
  final List<FlSpot> omzet;
  final List<FlSpot> orders;

  // Ekspos konfigurasi axis agar komponen tetap fleksibel dan reusable
  final double? minX;
  final double? maxX;
  final double? minY;
  final double? maxY;
  final String yAxisUnit; // Contoh: 'Jt', 'Rb', dll.

  const DsChart({
    super.key,
    required this.omzet,
    required this.orders,
    this.minX,
    this.maxX,
    this.minY,
    this.maxY,
    this.yAxisUnit = 'Jt',
  });

  @override
  State<DsChart> createState() => DsChartState();
}

class DsChartState extends State<DsChart> {
  // Index spot yang sedang di-highlight (sticky tooltip)
  int? _stickySpotIndex;

  // Key untuk RepaintBoundary agar bisa di-screenshot
  final GlobalKey _chartKey = GlobalKey();
  bool isSaving = false;

  /// Capture grafik sebagai gambar PNG dan simpan ke Gallery
  Future<void> saveChartToGallery() async {
    if (isSaving) return;
    setState(() => isSaving = true);

    try {
      // Cari RenderObject dari key
      final boundary = _chartKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Capture ke ui.Image dengan pixel ratio 3x agar resolusinya tajam
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Simpan ke Gallery menggunakan package gal
      await Gal.putImageBytes(pngBytes,
          name: 'komship_grafik_${DateTime.now().millisecondsSinceEpoch}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grafik berhasil disimpan ke Gallery!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan grafik: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Cari nilai maksimum
    double maxOmzet = 0;
    for (var spot in widget.omzet) {
      if (spot.y > maxOmzet) maxOmzet = spot.y;
    }
    double maxOrder = 0;
    for (var spot in widget.orders) {
      if (spot.y > maxOrder) maxOrder = spot.y;
    }

    // 2. Hitung interval dan maxY untuk Y-Axis agar angkanya "cantik" (nice numbers)
    double rawMaxY = maxOmzet > 0 ? maxOmzet : 100.0;

    // Target ~15 langkah (bukan 14) agar sesuai format web
    double rawInterval = rawMaxY / 15;

    // Cari interval cantik dengan pembulatan integer murni ke atas
    double yInterval;
    if (rawInterval > 0) {
      double order = math
          .pow(10, (math.log(rawInterval) / math.ln10).floorToDouble())
          .toDouble();
      double normalized = rawInterval / order;
      yInterval = normalized.ceil() * order;
    } else {
      yInterval = 1.0;
    }
    if (yInterval <= 0) yInterval = 1.0;

    // maxY = bulatkan maxOmzet ke atas ke kelipatan yInterval terdekat
    final finalMaxY = widget.maxY ?? ((rawMaxY / yInterval).ceil() * yInterval);

    // Hitung max X dan min X untuk membagi label X menjadi 15 titik
    double maxDay = 31;
    double minDay = 1;
    if (widget.omzet.isNotEmpty) {
      maxDay = widget.omzet.first.x;
      minDay = widget.omzet.first.x;
      for (var spot in widget.omzet) {
        if (spot.x > maxDay) maxDay = spot.x;
        if (spot.x < minDay) minDay = spot.x;
      }
    }

    // Secara manual tentukan 15 titik X yang akan di render agar absolut presisi
    Set<int> xLabels = {};
    if (maxDay == 31) {
      xLabels = {1, 3, 5, 7, 9, 12, 14, 16, 18, 20, 22, 24, 27, 29, 31};
    } else if (maxDay == 30) {
      xLabels = {1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 22, 24, 26, 28, 30};
    } else if (maxDay == 29) {
      xLabels = {1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 22, 24, 26, 28, 29};
    } else if (maxDay == 28) {
      xLabels = {1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 22, 24, 26, 28};
    } else {
      if (maxDay > minDay) {
        double step = (maxDay - minDay) / 14;
        for (int i = 0; i <= 14; i++) {
          xLabels.add((minDay + (i * step)).round());
        }
      } else {
        xLabels.add(minDay.toInt());
      }
    }

    // 3. Scale spot agar sesuai dengan Y-Axis
    List<FlSpot> scaledOmzet = widget.omzet; // Omzet menggunakan nilai aktual

    // Scale order agar titik tertingginya menyesuaikan range Y-Axis
    double orderRatio = maxOrder > 0 ? finalMaxY / maxOrder : 1.0;
    List<FlSpot> scaledOrders =
        widget.orders.map((e) => FlSpot(e.x, e.y * orderRatio)).toList();

    // Definisikan bar data terlebih dahulu agar bisa direferensikan oleh showingTooltipIndicators
    final omzetBar = LineChartBarData(
      spots: scaledOmzet,
      isCurved: true,
      preventCurveOverShooting: true,
      color: const Color(0xFFFACC15),
      barWidth: 4,
      dotData: const FlDotData(show: false),
    );
    final ordersBar = LineChartBarData(
      spots: scaledOrders,
      isCurved: true,
      preventCurveOverShooting: true,
      color: const Color(0xFF3B82F6),
      barWidth: 3,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF3B82F6).withValues(alpha: 0.65),
            const Color(0xFF3B82F6).withValues(alpha: 0.08),
          ],
        ),
      ),
    );

    // Bangun showingTooltipIndicators dari sticky spot yang disimpan di state
    final stickyTooltip = <ShowingTooltipIndicators>[];
    final idx = _stickySpotIndex;
    if (idx != null) {
      final safeOmzetIdx = idx.clamp(0, scaledOmzet.length - 1);
      final safeOrderIdx = idx.clamp(0, scaledOrders.length - 1);
      if (scaledOmzet.isNotEmpty && scaledOrders.isNotEmpty) {
        stickyTooltip.add(ShowingTooltipIndicators([
          LineBarSpot(omzetBar, 0, scaledOmzet[safeOmzetIdx]),
          LineBarSpot(ordersBar, 1, scaledOrders[safeOrderIdx]),
        ]));
      }
    }

    return GestureDetector(
      // Klik di luar area chart (tapi masih di dalam Container) = hilangkan tooltip
      onTap: () {
        if (_stickySpotIndex != null) {
          setState(() => _stickySpotIndex = null);
        }
      },
      child: RepaintBoundary(
        key: _chartKey,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.alwaysWhite,
            borderRadius: BorderRadius.circular(AppRadius.lg2),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 260,
                child: LineChart(
                  LineChartData(
                    minX: widget.minX,
                    maxX: widget.maxX,
                    minY: widget.minY ?? 0,
                    maxY: finalMaxY,
                    showingTooltipIndicators: stickyTooltip,
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches:
                          false, // Matikan auto-tooltip bawaan
                      touchCallback:
                          (FlTouchEvent event, LineTouchResponse? response) {
                        setState(() {
                          if (response != null &&
                              response.lineBarSpots != null &&
                              response.lineBarSpots!.isNotEmpty) {
                            // Simpan spot index saat disentuh / digeser
                            _stickySpotIndex =
                                response.lineBarSpots!.first.spotIndex;
                          }
                          // Saat jari dilepas (FlTapUpEvent / FlPanEndEvent), JANGAN clear state
                          // Tooltip akan tetap tampil hingga pengguna klik di luar area chart
                        });
                      },
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (LineBarSpot touchedSpot) =>
                            AppColors.alwaysWhite,
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            final isOmset = touchedSpot.barIndex == 0;
                            if (isOmset) {
                              final originalValue = touchedSpot.y;
                              final formatted =
                                  CurrencyFormat.convertToIdrWithSpasi(
                                      originalValue.toInt(), 0);
                              return LineTooltipItem(
                                '● ',
                                const TextStyle(
                                    color: Color(0xFFFACC15), fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: formatted,
                                    style: AppTypography.bodySmMedium
                                        .copyWith(color: AppColors.textDark),
                                  ),
                                ],
                              );
                            } else {
                              final originalOrder =
                                  (touchedSpot.y / orderRatio).round();
                              return LineTooltipItem(
                                '● ',
                                const TextStyle(
                                    color: Color(0xFF3B82F6), fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: '$originalOrder Orderan',
                                    style: AppTypography.bodySmMedium
                                        .copyWith(color: AppColors.textDark),
                                  ),
                                ],
                              );
                            }
                          }).toList();
                        },
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: yInterval,
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 55,
                          interval: yInterval,
                          getTitlesWidget: (value, meta) {
                            // Jangan gambar di luar batas Y
                            if (value > finalMaxY + 0.1)
                              return const SizedBox.shrink();

                            double absVal = value.abs();
                            String formattedVal;

                            if (absVal >= 1.0e9) {
                              formattedVal =
                                  '${(absVal / 1.0e9).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} Mn';
                            } else if (absVal >= 1.0e6) {
                              formattedVal =
                                  '${(absVal / 1.0e6).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} Jt';
                            } else if (absVal >= 1.0e3) {
                              formattedVal =
                                  '${(absVal / 1.0e3).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} Rb';
                            } else {
                              formattedVal = '${absVal.toInt()}';
                            }

                            return Text(
                              formattedVal,
                              style: AppTypography.bodySmRegular
                                  .copyWith(color: AppColors.textDark),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval:
                              1, // Evaluasi setiap hari, tapi hanya render yang ada di set
                          getTitlesWidget: (value, meta) {
                            int day = value.toInt();
                            // Jangan render angka jika bukan merupakan salah satu dari 15 titik X yang dipilih
                            if (!xLabels.contains(day))
                              return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                day.toString().padLeft(2, '0'),
                                style: AppTypography.bodySmRegular.copyWith(
                                  color: AppColors.textDark,
                                  fontSize: 10, // Diperkecil agar tidak numpul
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [omzetBar, ordersBar],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const _ChartLegend(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: Color(0xFFFACC15),
          text: 'Omset',
        ),
        SizedBox(width: 20),
        _LegendItem(
          color: Color(0xFF3B82F6),
          text: 'Jumlah Order',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTypography.bodyMdMedium.copyWith(
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
