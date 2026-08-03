import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/home/bloc/balance_summary_bloc.dart';
import 'package:komtim_partner/features/superapp/features/home/bloc/revenue_performance_bloc.dart';
import 'package:komtim_partner/features/superapp/features/home/view/sections/balance_section.dart';
import 'package:komtim_partner/features/superapp/features/home/view/sections/menu_content_section.dart';
import 'package:komtim_partner/features/superapp/features/home/widgets/home_header_section.dart';
import 'package:komtim_partner/features/superapp/features/home/widgets/topup_flow_manager.dart';
import 'package:komtim_partner/features/superapp/features/notification/bloc/notification_info_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/check_bill_bloc.dart';

class HomePageSuperapp extends StatefulWidget {
  const HomePageSuperapp({super.key});

  @override
  State<HomePageSuperapp> createState() => _HomePageSuperappState();
}

class _HomePageSuperappState extends State<HomePageSuperapp> {
  final GlobalKey _captureKey = GlobalKey();
  bool _isSavingChart = false;

  // ===========================================================================
  // Save chart to gallery
  // ===========================================================================

  Future<void> _saveChartToGallery() async {
    if (_isSavingChart) return;
    setState(() => _isSavingChart = true);

    // Tunggu 1 frame agar tombol Share menghilang dari UI sebelum di-capture.
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
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
      if (mounted) setState(() => _isSavingChart = false);
    }
  }

  // ===========================================================================
  // Init — dispatch event setelah frame pertama (parent MultiBlocProvider siap)
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    // Dispatch di addPostFrameCallback agar parent MultiBlocProvider sudah
    // selesai render. Ini pengganti pola dispatch-di-create yang salah.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final profileState = context.read<SuperappProfileBloc>().state;

      // Revenue performance — fetch jika komship verified
      if (profileState.isKomshipVerified) {
        context
            .read<RevenuePerformanceBloc>()
            .add(const FetchRevenuePerformanceEvent());

        if (profileState.displayProfile?.id != null) {
          context.read<BalanceSummaryBloc>().add(
                FetchBalanceSummaryEvent(
                    profileState.displayProfile!.id.toString()),
              );
        }
      }

      // Notif info — fetch selalu
      context
          .read<NotificationInfoBloc>()
          .add(const FetchNotificationInfoEvent());
    });
  }

  // ===========================================================================
  // Refresh handler
  // ===========================================================================

  Future<void> _onRefresh() async {
    context.read<SuperappProfileBloc>().add(const FetchSuperappProfileEvent());

    final profileState = context.read<SuperappProfileBloc>().state;
    if (profileState.isKomshipVerified) {
      if (profileState.displayProfile?.id != null) {
        context.read<BalanceSummaryBloc>().add(
              FetchBalanceSummaryEvent(
                  profileState.displayProfile!.id.toString()),
            );
      }
      context
          .read<RevenuePerformanceBloc>()
          .add(const FetchRevenuePerformanceEvent());
    }

    context
        .read<NotificationInfoBloc>()
        .add(const FetchNotificationInfoEvent());

    // Indicator jangan langsung ilang
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // --- LAYOUT UTAMA ---
        Scaffold(
          backgroundColor: AppColors.alwaysWhite,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primaryBase,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // =========================================================
                    // SECTION 1: Header (foto, nama, savings, notif badge)
                    // =========================================================
                    const HomeHeaderSection(),

                    const SizedBox(height: AppSpacing.sm),

                    // =========================================================
                    // SECTION 2: Balance + Pending (Kompay, Kompoint, Topup/Penarikan)
                    // =========================================================
                    BalanceSection(
                      onTopupTap: () {
                        context
                            .read<CheckBillBloc>()
                            .add(FetchCheckBillEvent());
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // =========================================================
                    // SECTION 3: Menu + Chart PageView + Transaksi
                    // =========================================================
                    MenuContentSection(
                      captureKey: _captureKey,
                      isSavingChart: _isSavingChart,
                      onSaveChart: _saveChartToGallery,
                    ),

                    // Space buat floating navbar dari MainPageSuperApp
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ),

        // --- TOPUP FLOW MANAGER (invisible, cuma BlocListener) ---
        // Ditaruh di Stack supaya gak mengganggu layout Column di atas.
        const TopupFlowManager(),
      ],
    );
  }
}
