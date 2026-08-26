import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/widgets/custom_button.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/core/domain/entities/detail_shopping_model.dart';

class OptionRequested extends StatefulWidget {
  final DetailShoppingDataModel? dataShopping;
  final void Function(int) onCancelPressed;
  final void Function(int, bool) onPayPressed;
  final void Function() onTopupPressed;
  const OptionRequested(
      {super.key,
      required this.dataShopping,
      required this.onCancelPressed,
      required this.onPayPressed,
      required this.onTopupPressed});

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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(),
        shadows: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 0),
            spreadRadius: 0,
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
                                color: Color(0xFF818181),
                                fontSize: 12,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                            TextSpan(
                              text: CurrencyFormat.convertToIdr(
                                  widget.dataShopping?.kmpoin ?? 0, 0),
                              style: const TextStyle(
                                color: Color(0xFF818181),
                                fontSize: 12,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                                height: 0,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFF95E16)),
                    borderRadius: BorderRadius.circular(4),
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
                          'assets/images/ic-card-send.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Text(
                        'Top Up',
                        style: TextStyle(
                          color: Color(0xFFF95E16),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          height: 0,
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/ic_kompoin.svg',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Gunakan Kompoin : ',
                          style: TextStyle(
                            color: Color(0xFF818181),
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                        TextSpan(
                          text: CurrencyFormat.convertWithoutSymbol(
                              widget.dataShopping?.kompoints ?? 0, 0),
                          style: const TextStyle(
                            color: Color(0xFF818181),
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                  height: 24,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (widget.dataShopping?.kompoints != 0) {
                          switchValue = !switchValue;
                        } else {}
                      });
                    },
                    child: Container(
                      width: 48.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: switchValue ? Colors.green : Colors.grey,
                      ),
                      child: Stack(
                        alignment: switchValue
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        children: [
                          Positioned(
                            left: switchValue ? 28.0 : 4,
                            child: Container(
                              width: 14.0,
                              height: 14.0,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ),
        const Divider(
          height: 1,
        ),
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
                        'Total Bayar : ',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                          height: 0,
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
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ),
                  Text(
                    '-${CurrencyFormat.convertToIdr(_cutKompoint() ?? 0, 0)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF818181),
                      fontSize: 10,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  widget.onCancelPressed(widget.dataShopping?.id ?? 0);
                },
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: SvgPicture.asset(
                            'assets/images/ic_close_square.svg'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: CustomButton(
                    isActive: _isActive(),
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
