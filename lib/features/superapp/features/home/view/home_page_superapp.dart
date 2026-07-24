import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gal/gal.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_app_result_page.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_chart.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_info_balance.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_menu_icon.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_menu_item.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_transaction_tile.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';

import 'package:komtim_partner/features/superapp/features/home/bloc/balance_summary_bloc.dart';
import 'package:komtim_partner/features/superapp/features/home/bloc/revenue_performance_bloc.dart';
import 'package:komtim_partner/features/superapp/features/home/widgets/ds_home_header.dart';
import 'package:komtim_partner/features/superapp/features/home/widgets/home_notification_badge.dart';
import 'package:komtim_partner/features/superapp/features/home/widgets/home_skeleton.dart';
import 'package:komtim_partner/features/superapp/features/home/widgets/home_verification_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/notification/bloc/notification_info_bloc.dart';
import 'package:komtim_partner/features/superapp/features/notification/view/notification_page.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/check_bill_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/expire_invoice_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/expire_qrcode_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/view/barcode_qris_page.dart';
import 'package:komtim_partner/features/superapp/features/topup/view/topup_page.dart';
import 'package:komtim_partner/features/superapp/features/topup/view/web_view_page.dart';
import 'package:lottie/lottie.dart';

class HomePageSuperapp extends StatefulWidget {
  const HomePageSuperapp({super.key});

  @override
  State<HomePageSuperapp> createState() => _HomePageSuperappState();
}

class _HomePageSuperappState extends State<HomePageSuperapp> {
  final PageController _pageController = PageController();
  int _currentSwipePage = 0;
  Route? _loadingRoute;
  bool _hasShownVerificationBottomSheet = false;
  final GlobalKey<DsChartState> _dsChartKey = GlobalKey<DsChartState>();
  final GlobalKey _captureKey = GlobalKey();
  bool _isSavingChart = false;

  /// Capture komponen chart (beserta header-nya) sebagai gambar PNG dan simpan ke Gallery
  Future<void> _saveChartToGallery() async {
    if (_isSavingChart) return;
    setState(() => _isSavingChart = true);

    // Tunggu 1 frame agar tombol Share menghilang dari UI sebelum di-capture
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

  void _showLoading(BuildContext context) {
    if (_loadingRoute != null) return;
    _loadingRoute = DialogRoute(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Lottie.asset(
          'assets/json/loading-superapp.json',
          width: 80,
          height: 80,
        ),
      ),
    );
    Navigator.of(context, rootNavigator: true).push(_loadingRoute!);
  }

  void _hideLoading(BuildContext context) {
    if (_loadingRoute != null) {
      Navigator.of(context, rootNavigator: true).removeRoute(_loadingRoute!);
      _loadingRoute = null;
    }
  }

  bool _isServerError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('server') ||
        lower.contains('sistem') ||
        lower.contains('500');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definisi data transaksi terakhir
    const List<DsTransactionItem> transactions = [
      DsTransactionItem(
        title: 'Tiktok ads payment',
        cardName: 'Tiktok Card',
        amount: 'Rp 50.000',
        date: '20 april 2025',
      ),
      DsTransactionItem(
        title: 'Tiktok ads payment',
        cardName: 'Tiktok Card',
        amount: 'Rp 50.000',
        date: '20 april 2025',
      ),
      DsTransactionItem(
        title: 'Facebook ads',
        cardName: 'Tiktok Card',
        amount: 'Rp 50.000',
        date: '20 april 2025',
      ),
      DsTransactionItem(
        title: 'Shopee payment product des...',
        cardName: 'Tiktok Card',
        amount: 'Rp 99.999.999',
        date: '20 april 2025',
      ),
      DsTransactionItem(
        title: 'Tiktok ads payment',
        cardName: 'Tiktok Card',
        amount: 'Rp 50.000',
        date: '20 april 2025',
      ),
    ];

    // Definisi list pages untuk PageView secara dinamis (bisa 2, 3, dst.)
    final List<Widget> swipePages = [
      // PAGE 1: KOMSHIP COMPONENT
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: RepaintBoundary(
          key: _captureKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.alwaysWhite,
              border: Border.all(color: const Color(0xFFE5E5E5)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const DsAppImage(
                      source: 'assets/images/superapp/home/ic_logo_komship.svg',
                      height: 24,
                      width: 112,
                    ),
                    if (!_isSavingChart)
                      GestureDetector(
                        onTap: _saveChartToGallery,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.alwaysWhite,
                            border: Border.all(color: const Color(0xFFE5E5E5)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/superapp/home/ic_share.png',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Share',
                                style: AppTypography.bodyMdMedium.copyWith(
                                  color: const Color(0xFF0A0A0A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Performa Omset & Orderan',
                  style: AppTypography.bodyLgBold.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pantau semua pendapatan kamu disini',
                  style: AppTypography.bodyMdRegular.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.alwaysWhite,
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: DefaultTabController(
                    length: 3,
                    child: BlocBuilder<RevenuePerformanceBloc,
                        RevenuePerformanceState>(
                      builder: (context, state) {
                        // Semua transformasi data sudah di BLoC state.
                        // UI hanya consume hasil yang sudah siap pakai.
                        final totalOmset = state is RevenuePerformanceLoaded
                            ? state.totalOmset
                            : 0;
                        final omzetSpots = state is RevenuePerformanceLoaded
                            ? state.omzetSpots
                            : const <FlSpot>[];
                        final orderSpots = state is RevenuePerformanceLoaded
                            ? state.orderSpots
                            : const <FlSpot>[];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Omset'),
                            Text(
                              CurrencyFormat.convertToIdrNum(totalOmset, 0),
                              style: AppTypography.headingMd.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppTabLayout(
                              onTap: (index) {
                                String? method;
                                if (index == 1) method = 'cod';
                                if (index == 2) method = 'bank transfer';

                                final now = DateTime.now();
                                final startDate =
                                    DateTime(now.year, now.month, 1);
                                final endDate =
                                    DateTime(now.year, now.month + 1, 0);
                                String format(DateTime d) =>
                                    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

                                context.read<RevenuePerformanceBloc>().add(
                                      FetchRevenuePerformanceEvent(
                                        startDate: format(startDate),
                                        endDate: format(endDate),
                                        paymentMethod: method,
                                      ),
                                    );
                              },
                              tabs: const [
                                Tab(text: 'Semua'),
                                Tab(text: 'COD'),
                                Tab(text: 'Non COD'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (state is RevenuePerformanceLoading)
                              const HomeChartSkeleton()
                            else if (state is RevenuePerformanceError)
                              SizedBox(
                                height: 200,
                                child: Center(child: Text(state.message)),
                              )
                            else
                              DsChart(
                                key: _dsChartKey,
                                omzet: omzetSpots,
                                orders: orderSpots,
                              )
                          ],
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      // PAGE 2: SWIPE 2 PLACEHOLDER (READY FOR DATA SWIPE 2)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.alwaysWhite,
            border: Border.all(color: const Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              'Swipe 2 Data Placeholder',
              style: AppTypography.bodyLgMedium.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final now = DateTime.now();
            final startDate = DateTime(now.year, now.month, 1);
            final endDate = DateTime(now.year, now.month + 1, 0);
            String format(DateTime d) =>
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

            return locator<RevenuePerformanceBloc>()
              ..add(FetchRevenuePerformanceEvent(
                startDate: format(startDate),
                endDate: format(endDate),
              ));
          },
        ),
        BlocProvider(create: (context) => locator<CheckBillBloc>()),
        BlocProvider(
          create: (context) {
            final bloc = locator<BalanceSummaryBloc>();
            final profileState = context.read<SuperappProfileBloc>().state;
            if (profileState.isKomshipVerified &&
                profileState.displayProfile?.id != null) {
              bloc.add(FetchBalanceSummaryEvent(
                  profileState.displayProfile!.id.toString()));
            }
            return bloc;
          },
        ),
        BlocProvider(
          create: (context) => locator<NotificationInfoBloc>()
            ..add(const FetchNotificationInfoEvent()),
        ),
      ],
      child: BlocListener<CheckBillBloc, CheckBillState>(
        listener: (context, state) {
          if (state is CheckBillLoading) {
            _showLoading(context);
          } else if (state is CheckBillLoaded) {
            _hideLoading(context);
            if (state.data.haveActiveBill == true) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (_) => locator<ExpireQrcodeBloc>()),
                      BlocProvider(create: (_) => locator<ExpireInvoiceBloc>()),
                    ],
                    child: MultiBlocListener(
                      listeners: [
                        BlocListener<ExpireQrcodeBloc, ExpireQrcodeState>(
                          listener: (context, expireState) {
                            if (expireState is ExpireQrcodeLoading) {
                              _showLoading(context);
                            } else if (expireState is ExpireQrcodeSuccess) {
                              _hideLoading(context);
                              Navigator.pop(
                                  context); // close result page and go back to dashboard
                            } else if (expireState is ExpireQrcodeError) {
                              _hideLoading(context);
                              if (!_isServerError(expireState.message)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(expireState.message)),
                                );
                              }
                            }
                          },
                        ),
                        BlocListener<ExpireInvoiceBloc, ExpireInvoiceState>(
                          listener: (context, expireState) {
                            if (expireState is ExpireInvoiceLoading) {
                              _showLoading(context);
                            } else if (expireState is ExpireInvoiceSuccess) {
                              _hideLoading(context);
                              Navigator.pop(
                                  context); // close result page and go back to dashboard
                            } else if (expireState is ExpireInvoiceError) {
                              _hideLoading(context);
                              if (!_isServerError(expireState.message)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(expireState.message)),
                                );
                              }
                            }
                          },
                        ),
                      ],
                      child: Builder(
                        builder: (innerContext) => DsAppResultPage(
                          illustration: SvgPicture.asset(
                            'assets/images/superapp/topup/ilustration_confimation.svg',
                          ),
                          title: 'Selesaikan Pembayaran',
                          description:
                              'Kamu masih memiliki pembayaran Top Up yang belum diselesaikan!',
                          action: TextButton(
                            onPressed: () {
                              final qrId = state.data.qrXenditId;
                              final invoiceId = state.data.invoiceXenditId;
                              if (invoiceId != null && invoiceId.isNotEmpty) {
                                innerContext
                                    .read<ExpireInvoiceBloc>()
                                    .add(SubmitExpireInvoiceEvent(invoiceId));
                              } else if (qrId != null && qrId.isNotEmpty) {
                                innerContext
                                    .read<ExpireQrcodeBloc>()
                                    .add(FetchExpireQrcodeEvent(qrId));
                              }
                            },
                            child: Text(
                              'Batalkan Pembayaran',
                              style: AppTypography.bodyMdSemiBold.copyWith(
                                color: AppColors.primaryBase,
                              ),
                            ),
                          ),
                          secondaryAction: DsButton(
                            text: 'Bayar Sekarang',
                            onPressed: () {
                              final invoiceUrl = state.data.invoiceXenditUrl;
                              final qrString = state.data.qrXenditQrstring;

                              if (invoiceUrl != null && invoiceUrl.isNotEmpty) {
                                Navigator.pushReplacement(
                                  innerContext,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WebViewPage(url: invoiceUrl),
                                  ),
                                );
                              } else if (qrString != null &&
                                  qrString.isNotEmpty) {
                                Navigator.pushReplacement(
                                  innerContext,
                                  MaterialPageRoute(
                                    builder: (_) => BarcodeQrisPage(
                                      amount: state.data.qrAmount ?? 0,
                                      qrString: qrString,
                                      expiresAt: state.data.qrExpireDate ?? '',
                                      qrId: state.data.qrXenditId ?? '',
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.pop(innerContext);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TopupPage(),
                ),
              );
            }
          } else if (state is CheckBillError) {
            _hideLoading(context);
            if (!_isServerError(state.message)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: AppColors.alwaysWhite,
              body: SafeArea(
                child: RefreshIndicator(
                  color: AppColors.primaryBase,
                  onRefresh: () async {
                    // Refresh profile
                    context.read<SuperappProfileBloc>().add(
                          const FetchSuperappProfileEvent(),
                        );
                    // Refresh balance jika komship & verified
                    final profileState =
                        context.read<SuperappProfileBloc>().state;
                    if (profileState.isKomshipVerified &&
                        profileState.displayProfile?.id != null) {
                      context.read<BalanceSummaryBloc>().add(
                            FetchBalanceSummaryEvent(
                                profileState.displayProfile!.id.toString()),
                          );
                    }
                    // Refresh notification count
                    context.read<NotificationInfoBloc>().add(
                          const FetchNotificationInfoEvent(),
                        );
                    // Tunggu minimal 500ms agar indicator tidak langsung hilang
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Header — nama & foto dari profile cache (muncul instan)
                        BlocConsumer<SuperappProfileBloc, SuperappProfileState>(
                          listener: (context, profileState) {
                            final profile = profileState.displayProfile;

                            // Tampilkan BottomSheet Verifikasi Email
                            // unverifiedProducts sudah di-compute di State — UI tinggal consume
                            if (!_hasShownVerificationBottomSheet &&
                                profileState.unverifiedProducts.isNotEmpty) {
                              _hasShownVerificationBottomSheet = true;
                              Future.microtask(() {
                                HomeVerificationBottomSheet.show(
                                    context: context);
                              });
                            }

                            // Fetch balance summary jika komship verified
                            if (profileState.isKomshipVerified &&
                                profileState.displayProfile?.id != null) {
                              context.read<BalanceSummaryBloc>().add(
                                  FetchBalanceSummaryEvent(profileState
                                      .displayProfile!.id
                                      .toString()));
                            }
                          },
                          buildWhen: (prev, curr) =>
                              prev.displayProfile?.photoProfileUrl !=
                                  curr.displayProfile?.photoProfileUrl ||
                              prev.displayProfile?.fullName !=
                                  curr.displayProfile?.fullName ||
                              prev.displayProfile?.isKomship !=
                                  curr.displayProfile?.isKomship,
                          builder: (context, profileState) {
                            final isKomship = profileState.isKomshipVerified;

                            // BlocSelector: rebuild DsHomeHeader HANYA jika
                            // string savings benar-benar berubah nilainya.
                            return BlocSelector<BalanceSummaryBloc,
                                BalanceSummaryState, String>(
                              selector: (state) {
                                String formatNominal(num value) {
                                  if (value == 0) return 'Rp 0';
                                  if (value % 1 == 0)
                                    return CurrencyFormat.convertToIdrNum(
                                        value, 0);
                                  return CurrencyFormat.convertToIdrNum(
                                      value, 2);
                                }

                                if (state is BalanceSummaryLoaded) {
                                  return formatNominal(
                                      state.data.totalEarnCashback ?? 0);
                                } else if (state is BalanceSummaryError) {
                                  return '--';
                                }
                                return 'Rp 0';
                              },
                              builder: (context, savings) {
                                return DsHomeHeader(
                                  profileUrl: profileState
                                          .displayProfile?.photoProfileUrl ??
                                      '',
                                  partnerName:
                                      profileState.displayProfile?.fullName ??
                                          '',
                                  type: isKomship
                                      ? PartnerType.komship
                                      : PartnerType.regular,
                                  savingsAmount: isKomship ? savings : null,
                                  notificationWidget:
                                      const HomeNotificationBadge(),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.alwaysWhite,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.only(
                              bottom: 12, left: 12, right: 12),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left part: Balance info (reactive)
                                  Expanded(
                                    child: BlocBuilder<SuperappProfileBloc,
                                        SuperappProfileState>(
                                      buildWhen: (prev, curr) =>
                                          prev.displaySaldo !=
                                              curr.displaySaldo ||
                                          prev.displayKompoints !=
                                              curr.displayKompoints ||
                                          prev.isBalanceLoading !=
                                              curr.isBalanceLoading ||
                                          prev.isBalanceError !=
                                              curr.isBalanceError,
                                      builder: (context, profileState) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, top: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Kompay",
                                                style: AppTypography
                                                    .bodyMdRegular
                                                    .copyWith(
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: AppSpacing.xxs),
                                              // Saldo: shimmer saat loading, error saat gagal, nilai saat berhasil
                                              if (profileState.isBalanceLoading)
                                                Container(
                                                  width: 140,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.grey200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                )
                                              else if (profileState
                                                  .isBalanceError)
                                                GestureDetector(
                                                  onTap: () => context
                                                      .read<
                                                          SuperappProfileBloc>()
                                                      .add(
                                                          const FetchSuperappProfileEvent()),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "-- ",
                                                        style: AppTypography
                                                            .numericXl
                                                            .copyWith(
                                                          color:
                                                              AppColors.grey350,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.refresh_rounded,
                                                        size: 18,
                                                        color: AppColors
                                                            .primaryBase,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              else
                                                Text(
                                                  CurrencyFormat.convertToIdr(
                                                      profileState
                                                              .displaySaldo ??
                                                          0,
                                                      0),
                                                  style: AppTypography.numericXl
                                                      .copyWith(
                                                    color: AppColors.black,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              const SizedBox(
                                                  height: AppSpacing.xs2),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Kompoint",
                                                    style: AppTypography
                                                        .bodyMdRegular
                                                        .copyWith(
                                                      color: AppColors.textDark,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width: AppSpacing.xs),
                                                  SvgPicture.asset(
                                                    'assets/images/ic_kompoint.svg',
                                                    width: 16.0,
                                                    height: 16.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  const SizedBox(
                                                      width: AppSpacing.xs),
                                                  Text(
                                                    '${profileState.displayKompoints ?? 0}',
                                                    style: AppTypography
                                                        .bodySmSemiBold
                                                        .copyWith(
                                                      color: AppColors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // Right part: Action buttons (Top Up, Penarikan)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DsMenuItem(
                                        title: "Top Up",
                                        icon: SvgPicture.asset(
                                          'assets/images/superapp/home/ic_plus.svg',
                                        ),
                                        onTap: () {
                                          context
                                              .read<CheckBillBloc>()
                                              .add(FetchCheckBillEvent());
                                        },
                                        backgroundColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.xs2,
                                          vertical: AppSpacing.xs,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      DsMenuItem(
                                        title: "Penarikan",
                                        icon: SvgPicture.asset(
                                          'assets/images/superapp/home/ic_withdraw.svg',
                                        ),
                                        onTap: () {},
                                        backgroundColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.xs2,
                                          vertical: AppSpacing.xs,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // BlocSelector: rebuild card HANYA jika
                              // status isKomship benar-benar berubah (true↔false).
                              BlocSelector<SuperappProfileBloc,
                                  SuperappProfileState, bool>(
                                selector: (state) => state.isKomshipVerified,
                                builder: (context, isKomship) {
                                  if (!isKomship)
                                    return const SizedBox.shrink();

                                  return BlocBuilder<BalanceSummaryBloc,
                                      BalanceSummaryState>(
                                    builder: (context, balanceState) {
                                      String formatNominal(num value) {
                                        if (value == 0) return 'Rp 0';
                                        if (value % 1 == 0)
                                          return CurrencyFormat.convertToIdrNum(
                                              value, 0);
                                        return CurrencyFormat.convertToIdrNum(
                                            value, 2);
                                      }

                                      String pendingBalance = "Rp 0";
                                      String pendingProblem = "Rp 0";
                                      if (balanceState
                                          is BalanceSummaryLoaded) {
                                        pendingBalance = formatNominal(
                                            balanceState.data.pendingBalance ??
                                                0);
                                        pendingProblem = formatNominal(
                                            balanceState.data
                                                    .pendingBalanceOnProblem ??
                                                0);
                                      } else if (balanceState
                                          is BalanceSummaryError) {
                                        // Tampilkan error card + tombol retry
                                        return Column(
                                          children: [
                                            const SizedBox(
                                                height: AppSpacing.lg),
                                            AppInfoCard(
                                              backgroundColor:
                                                  AppColors.bgLight,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Gagal memuat saldo pending',
                                                      style: AppTypography
                                                          .bodyMdRegular
                                                          .copyWith(
                                                        color:
                                                            AppColors.textDark,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        final profile = context
                                                            .read<
                                                                SuperappProfileBloc>()
                                                            .state
                                                            .displayProfile;
                                                        if (profile?.id !=
                                                            null) {
                                                          context
                                                              .read<
                                                                  BalanceSummaryBloc>()
                                                              .add(
                                                                FetchBalanceSummaryEvent(
                                                                    profile!.id
                                                                        .toString()),
                                                              );
                                                        }
                                                      },
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .refresh_rounded,
                                                            size: 16,
                                                            color: AppColors
                                                                .primaryBase,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            'Coba lagi',
                                                            style: AppTypography
                                                                .bodySmSemiBold
                                                                .copyWith(
                                                              color: AppColors
                                                                  .primaryBase,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }

                                      return Column(
                                        children: [
                                          const SizedBox(height: AppSpacing.lg),
                                          AppInfoCard(
                                            backgroundColor: AppColors.bgLight,
                                            children: [
                                              HighlightText(
                                                prefix: "Saldo Pending : ",
                                                highlight: pendingBalance,
                                                style: AppTypography
                                                    .bodyMdRegular
                                                    .copyWith(
                                                  color: AppColors.textDark,
                                                ),
                                                highlightStyle: AppTypography
                                                    .bodyMdBold
                                                    .copyWith(
                                                  color: AppColors.black,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: AppSpacing.xs),
                                              HighlightText(
                                                prefix: "Dari nilai tersebut, ",
                                                highlight: pendingProblem,
                                                suffix:
                                                    ",- nya perlu dimonitor",
                                                style: AppTypography
                                                    .bodyMdRegular
                                                    .copyWith(
                                                  color: AppColors.textDark,
                                                ),
                                                highlightStyle: AppTypography
                                                    .bodyMdSemiBold
                                                    .copyWith(
                                                  color: AppColors.primaryBase,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        BlocBuilder<SuperappProfileBloc, SuperappProfileState>(
                          buildWhen: (prev, curr) =>
                              prev.displayProfile?.isKomship !=
                                  curr.displayProfile?.isKomship ||
                              prev.displayProfile?.isKomcards !=
                                  curr.displayProfile?.isKomcards ||
                              prev.displayProfile?.productMailVerifications !=
                                  curr.displayProfile?.productMailVerifications,
                          builder: (context, profileState) {
                            // Gunakan getter dari state — tidak ada logic bisnis di UI
                            final hasKomship = profileState.isKomshipVerified;
                            final hasKomcards = profileState.isKomcardsVerified;

                            // Skeleton menu saat pertama kali loading (belum ada cache)
                            final isFirstLoad = profileState.status ==
                                    SuperappProfileStatus.loading ||
                                profileState.status ==
                                    SuperappProfileStatus.initial;

                            if (isFirstLoad) {
                              return const HomeMenuSkeleton();
                            }

                            List<Widget> menuItems = [
                              // Menu Team selalu tersedia
                              DsMenuIcon(
                                icon: Image.asset(
                                    'assets/images/superapp/home/ic_team.png'),
                                title: "Team",
                                onTap: () {},
                              ),
                            ];

                            if (hasKomship) {
                              menuItems.addAll([
                                DsMenuIcon(
                                  icon: Image.asset(
                                      'assets/images/superapp/home/ic_order.png'),
                                  title: "Order",
                                  onTap: () {},
                                ),
                                DsMenuIcon(
                                  icon: Image.asset(
                                      'assets/images/superapp/home/ic_problem.png'),
                                  title: "Kendala",
                                  onTap: () {},
                                ),
                              ]);
                            }

                            final activeSwipePages = <Widget>[];
                            if (hasKomship && swipePages.isNotEmpty) {
                              activeSwipePages.add(swipePages[0]);
                            }
                            if (hasKomcards && swipePages.length > 1) {
                              activeSwipePages.add(swipePages[1]);
                            }

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 0.85,
                                    children: menuItems,
                                  ),
                                ),
                                if (activeSwipePages.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.xl),
                                  // PAGEVIEW CAROUSEL
                                  SizedBox(
                                    height: 680,
                                    child: PageView(
                                      controller: _pageController,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _currentSwipePage = index;
                                        });
                                      },
                                      children: activeSwipePages,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // SWIPE INDICATOR DOTS
                                  if (activeSwipePages.length > 1)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                          activeSwipePages.length, (index) {
                                        final isActive =
                                            _currentSwipePage == index;
                                        return AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          height: 12,
                                          width: isActive ? 32 : 12,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? AppColors.primaryBase
                                                : AppColors.grey350,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        );
                                      }),
                                    ),
                                ],
                                if (hasKomcards) ...[
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.alwaysWhite,
                                        border: Border.all(
                                            color: const Color(0xFFE5E5E5)),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16),
                                            child: Text(
                                              'Transaksi Terakhir Kartu',
                                              style: AppTypography.headingSm
                                                  .copyWith(
                                                color: AppColors.textDark,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFFE5E5E5)),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Column(
                                              children: List.generate(
                                                  transactions.length, (index) {
                                                final item =
                                                    transactions[index];
                                                final isLast = index ==
                                                    transactions.length - 1;
                                                return Column(
                                                  children: [
                                                    DsTransactionTile(
                                                        item: item),
                                                    if (!isLast)
                                                      const Divider(
                                                        height: 1,
                                                        thickness: 1,
                                                        color:
                                                            Color(0xFFE5E5E5),
                                                      ),
                                                  ],
                                                );
                                              }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
