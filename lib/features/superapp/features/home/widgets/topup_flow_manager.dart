import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_app_result_page.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/check_bill_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/expire_invoice_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/expire_qrcode_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/view/barcode_qris_page.dart';
import 'package:komtim_partner/features/superapp/features/topup/view/topup_page.dart';
import 'package:komtim_partner/features/superapp/features/topup/view/web_view_page.dart';
import 'package:lottie/lottie.dart';

/// Widget invisible yang mengelola alur Top Up:
/// CheckBill → (ada tagihan aktif → halaman konfirmasi) atau (tidak → TopupPage).
///
/// Diletakkan di dalam [Stack] bersama layout utama agar tidak
/// mengganggu Column scroll.
class TopupFlowManager extends StatefulWidget {
  const TopupFlowManager({super.key});

  @override
  State<TopupFlowManager> createState() => _TopupFlowManagerState();
}

class _TopupFlowManagerState extends State<TopupFlowManager> {
  Route? _loadingRoute;

  void _showLoading() {
    if (_loadingRoute != null) return;
    _loadingRoute = DialogRoute(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Lottie.asset(
          'assets/json/loading-superapp.json',
          width: 80,
          height: 80,
        ),
      ),
    );
    Navigator.of(context, rootNavigator: true).push(_loadingRoute!);
  }

  void _hideLoading() {
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
  Widget build(BuildContext context) {
    return BlocListener<CheckBillBloc, CheckBillState>(
      listener: (context, state) {
        if (state is CheckBillLoading) {
          _showLoading();
        } else if (state is CheckBillLoaded) {
          _hideLoading();
          if (state.data.haveActiveBill == true) {
            _navigateToActiveBill(context, state);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TopupPage()),
            );
          }
        } else if (state is CheckBillError) {
          _hideLoading();
          if (!_isServerError(state.message)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        }
      },
      child: const SizedBox.shrink(),
    );
  }

  void _navigateToActiveBill(BuildContext context, CheckBillLoaded state) {
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
                    _showLoading();
                  } else if (expireState is ExpireQrcodeSuccess) {
                    _hideLoading();
                    Navigator.pop(context);
                  } else if (expireState is ExpireQrcodeError) {
                    _hideLoading();
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
                    _showLoading();
                  } else if (expireState is ExpireInvoiceSuccess) {
                    _hideLoading();
                    Navigator.pop(context);
                  } else if (expireState is ExpireInvoiceError) {
                    _hideLoading();
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
                          builder: (_) => WebViewPage(url: invoiceUrl),
                        ),
                      );
                    } else if (qrString != null && qrString.isNotEmpty) {
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
  }
}
