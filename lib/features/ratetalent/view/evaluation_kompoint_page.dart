import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/global/widgets/custom_button_icon_text.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';
import 'package:komtim_partner/features/ratetalent/bloc/rate_talent_bloc.dart';
import '../../../common/styles.dart';

class EvaluationKompointPage extends StatefulWidget {
  final int komPoint;
  final String xenditUrl;
  final int invoiceId;
  final String invoiceCode;
  final List<TalentsDataModel> submitTalents;
  final List<TalentLeaderModel> submitLeaders;
  const EvaluationKompointPage({
    super.key,
    required this.komPoint,
    required this.xenditUrl,
    required this.invoiceCode,
    required this.invoiceId,
    required this.submitTalents,
    required this.submitLeaders,
  });

  @override
  State<EvaluationKompointPage> createState() => _EvaluationKompointPageState();
}

class _EvaluationKompointPageState extends State<EvaluationKompointPage> {
  late RateTalentBloc _bloc;
  @override
  void initState() {
    _bloc = context.read<RateTalentBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RateTalentBloc, RateTalentState>(
        listener: (context, state) {
      if (state.status == RequestStatus.success &&
          state.operation == 'submittingRatings') {
        AppRouter.router
            .pushNamed(PAGES.paymentmethod.screenName, queryParameters: {
          'id': [widget.invoiceCode],
          'xenditUrl': [widget.xenditUrl]
        });
      }
    }, builder: (context, state) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: ClipRRect(
                  child: SvgPicture.asset(
                    'assets/images/ilustrate-star.svg', // Replace with your image url
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              const Center(
                child: Text(
                  "Evaluasi Berhasil Disimpan.",
                  style: AppTypography.semiBold20,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 12.0,
              ),
              Center(
                child: Text(
                  widget.komPoint == 0
                      ? "😐 Sayang sekali, kamu belum mendapatkan KomPoint kali ini."
                      : "Kamu mendapatkan ${widget.komPoint.toString()} poin KomPoint!",
                  style: AppTypography.regular14,
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Container(
            padding: EdgeInsets.only(
                bottom:
                    math.max(0, MediaQuery.of(context).viewInsets.bottom - 10)),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButtonIconText(
                    text: "Lanjutkan",
                    onPressed: state.status == RequestStatus.loading
                        ? null
                        : () {
                            _bloc.add(SetTalentRateReq(
                                widget.submitTalents,
                                widget.submitLeaders,
                                widget.invoiceId,
                                widget.komPoint));
                          },
                    color: Colors.white,
                    backGroundColor: state.status == RequestStatus.loading
                        ? onlyGray
                        : primaryColor,
                    colorText: Colors.white,
                    isLoading:
                        state.status == RequestStatus.loading ? true : false,
                  ),
                ),
              ),
            )),
      );
    });
  }
}
