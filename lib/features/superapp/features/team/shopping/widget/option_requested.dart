import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/widgets/custom_button.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/core/domain/entities/detail_shopping_model.dart';
import 'package:komtim_partner/features/superapp/features/team/listteam/widget/dash_line_team.dart';

class OptionRequested extends StatefulWidget {
  final DetailShoppingDataModel? dataShopping;
  final void Function(int) onCancelPressed;
  final void Function(int, bool) onPayPressed;
  final void Function() onTopupPressed;
  final bool isLoadingPay;
  const OptionRequested(
      {super.key,
      required this.dataShopping,
      required this.onCancelPressed,
      required this.onPayPressed,
      required this.onTopupPressed,
      this.isLoadingPay = false});

  @override
  State<OptionRequested> createState() => _OptionRequested();
}

class _OptionRequested extends State<OptionRequested> {
  bool switchValue = false;
  bool isActive = false;
  bool canPayColor = false;

  bool _canPayColor() {
    if (switchValue) {
      if (widget.dataShopping!.kompoints != null &&
          widget.dataShopping!.kmpoin != null &&
          widget.dataShopping!.total != null) {
        if (widget.dataShopping!.kompoints! >= widget.dataShopping!.total!) {
          return true;
        } else if ((widget.dataShopping!.kompoints! +
                widget.dataShopping!.kmpoin!) >=
            widget.dataShopping!.total!) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      if (widget.dataShopping!.kmpoin != null &&
          widget.dataShopping!.total != null) {
        if (widget.dataShopping!.kmpoin! >= widget.dataShopping!.total!) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }
  }

  bool _isActive() {
    if (!switchValue) {
      if (widget.dataShopping!.kmpoin != null &&
          widget.dataShopping!.total != null) {
        if (widget.dataShopping!.kmpoin! >= widget.dataShopping!.total!) {
          return true;
        } else {
          return false;
        }
      }
    } else {
      if (widget.dataShopping!.kompoints != null &&
          widget.dataShopping!.kmpoin != null &&
          widget.dataShopping!.total != null) {
        if (widget.dataShopping!.kmpoin! + widget.dataShopping!.kompoints! >=
            widget.dataShopping!.total!) {
          return true;
        } else if (widget.dataShopping!.kompoints! >=
            widget.dataShopping!.total!) {
          return true;
        } else if (widget.dataShopping!.kmpoin! >=
            widget.dataShopping!.total!) {
          return true;
        } else {
          return false;
        }
      }
    }
    return isActive;
  }

  int _cutKompoint() {
    if (switchValue) {
      if (widget.dataShopping!.kompoints != null &&
          widget.dataShopping!.kmpoin != null &&
          widget.dataShopping!.total != null) {
        if (widget.dataShopping!.kmpoin! == 0 &&
            widget.dataShopping!.kompoints! >= widget.dataShopping!.total!) {
          return widget.dataShopping!.total!;
        } else if (widget.dataShopping!.kmpoin! != 0 &&
            widget.dataShopping!.kompoints! >= widget.dataShopping!.total!) {
          return widget.dataShopping!.total!;
        } else {
          return widget.dataShopping!.kompoints!;
        }
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  int _cutTotal() {
    if (switchValue) {
      if (widget.dataShopping!.kompoints != null &&
          widget.dataShopping!.total != null) {
        if (widget.dataShopping!.kompoints! >= widget.dataShopping!.total!) {
          return 0;
        } else {
          return widget.dataShopping!.total! - widget.dataShopping!.kompoints!;
        }
      } else {
        return 0;
      }
    } else {
      return widget.dataShopping!.total!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          )
        ],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Saldo Kompay : ',
                              style: TextStyle(
                                color: gray737373,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: CurrencyFormat.convertToIdr(
                                  widget.dataShopping?.kmpoin ?? 0, 0),
                              style: const TextStyle(
                                color: AppColors.black0A0A,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: ShapeDecoration(
                  color: AppColors.cardBgFFF7ED,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.cardBgFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    widget.onTopupPressed();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: SvgPicture.asset(
                          'assets/images/superapp/ic_money.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Top Up',
                        style: TextStyle(
                          color: AppColors.black0A0A,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFF3F4F6), thickness: 1),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 11, horizontal: 9),
                decoration: BoxDecoration(
                  color: AppColors.cardBgFFF7ED,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/images/ic_kompoin.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gunakan Kompoint',
                      style: TextStyle(
                        color: gray737373,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Tersedia ',
                            style: TextStyle(
                              color: gray737373,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: CurrencyFormat.convertWithoutSymbol(
                                widget.dataShopping?.kompoints ?? 0, 0),
                            style: const TextStyle(
                              color: Color(0xFFF95E16),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(
                            text: ' poin',
                            style: TextStyle(
                              color: gray737373,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 28,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (widget.dataShopping?.kompoints != 0) {
                        switchValue = !switchValue;
                      }
                    });
                  },
                  child: Container(
                    width: 52.0,
                    height: 28.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.0),
                      color: switchValue
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFD1D5DB),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: switchValue
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 22.0,
                        height: 22.0,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const DashedLine(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          color: AppColors.black0A0A,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormat.convertToIdr(_cutTotal() ?? 0, 0),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _canPayColor()
                          ? const Color(0xFFF95E16)
                          : const Color(0xFFE31A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '-${CurrencyFormat.convertToIdr(_cutKompoint() ?? 0, 0)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: gray737373,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onCancelPressed(widget.dataShopping?.id ?? 0);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF95E16),
                      side: const BorderSide(color: Color(0xFFF95E16)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Batalkan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: CustomButton(
                    isActive: _isActive() && !widget.isLoadingPay,
                    isLoading: widget.isLoadingPay,
                    text: 'Bayar',
                    onPressed: () {
                      widget.onPayPressed(
                          widget.dataShopping?.id ?? 0, switchValue);
                    },
                  ),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
