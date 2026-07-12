import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_radius.dart';
import 'package:komtim_partner/common/global/design_system/app_spacing.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';

class DsChart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
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
                // Menggunakan parameter opsional atau fallback otomatis agar grafik tidak crash/terpotong
                minX: minX,
                maxX: maxX,
                minY: minY ?? 0,
                maxY: maxY,
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()} $yAxisUnit',
                          style: AppTypography.bodySmRegular.copyWith(
                            color: AppColors.textDark,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            value.toInt().toString(),
                            style: AppTypography.bodySmRegular.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: omzet,
                    isCurved: true,
                    color: const Color(0xFFFACC15), // Warna warning/secondary omzet
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: orders,
                    isCurved: true,
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
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _ChartLegend(),
        ],
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