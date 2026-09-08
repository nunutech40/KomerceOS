import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/global/widgets/custom_button.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/loading/loading_overlay.dart';
import 'package:komtim_partner/common/utils/loading/shimmer_loaders.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';

// import 'package:komtim_partner/features/ratetalent/view/web_view_page.dart';

import '../bloc/rate_talent_bloc.dart';
import '../widget/item_row_set_setting.dart';
import '../widget/rating_info_widget.dart';

class RateTalentCheckPage extends StatefulWidget {
  final String xenditUrl;
  final int invoiceId;
  final String invoiceCode;

  const RateTalentCheckPage(
      {Key? key,
      required this.xenditUrl,
      required this.invoiceId,
      required this.invoiceCode})
      : super(key: key);

  @override
  _RateTalentCheckPageState createState() => _RateTalentCheckPageState();
}

class _RateTalentCheckPageState extends State<RateTalentCheckPage>
    with ErrorHandlingMixin {
  bool isCheckAll = false;
  int ratingAll = 0;
  List<TalentsDataModel>? talents;
  List<TalentLeaderModel>? leaders;
  bool isSubmitting = false;

  // Variable untuk menghitung total amount dari evaluasi valid
  int totalAmount = 0;

  @override
  void initState() {
    super.initState();
    context
        .read<RateTalentBloc>()
        .add(RateTalentEvaluationPageDidload(invoiceId: widget.invoiceId));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: _buildAppBar(),
          body: BlocConsumer<RateTalentBloc, RateTalentState>(
            listener: (context, state) {},
            builder: (context, state) => _buildBody(state),
          ),
          bottomNavigationBar: Container(
              padding: EdgeInsets.only(
                  bottom: math.max(
                      0, MediaQuery.of(context).viewInsets.bottom - 10)),
              child: _buildBottomNavigationBar()),
        ),
        BlocBuilder<RateTalentBloc, RateTalentState>(
          builder: (context, state) {
            if (state.status == RequestStatus.loading &&
                state.operation == 'submittingRatings') {
              return const LoadingOverlay();
            }
            return const SizedBox
                .shrink(); // return an empty widget when not loading
          },
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(Strings.label_evaluation_talent,
          style: AppTypography.interSemiBold16),
      leading: IconButton(
        icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
        onPressed: () => AppRouter.router.pop(),
      ),
    );
  }

  // void _handleStateChanges(RateTalentState state) {
  //   if (state.status == RequestStatus.success &&
  //       state.operation == 'submittingRatings') {
  //     AppRouter.router
  //         .pushNamed(PAGES.paymentmethod.screenName, queryParameters: {
  //       'id': [widget.invoiceCode],
  //       'xenditUrl': [widget.xenditUrl]
  //     });
  //     setState(() => isSubmitting = false);
  //   }
  // }

  Widget _errorContent(RateTalentState state) {
    // Schedule the error handler for the next frame to avoid 'setState() or markNeedsBuild() called during build' error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleFailureState(context, state, state.message);
    });

    // Return a widget to represent the error state to the user.
    return Center(child: Text('An error occurred: ${state.message}'));
    // If you want to continue the UI flow and show nothing in case of an error, you can replace the above line with:
    // return Container();
  }

  Widget _buildRatingHeader() {
    return ItemRowSetRating(
      index: 0,
      isHeader: true,
      isChecked: isCheckAll,
      onCheckboxChanged: (value) => _setAllCheckboxes(value),
      onRatingChecked: (rating) => _updateHeaderRating(rating),
      setRating: ratingAll,
    );
  }

  Widget _buildBody(RateTalentState state) {
    switch (state.status) {
      case RequestStatus.loading:
        if (state.operation == 'loadingTalents') {
          return const ShimmerPlaceholderListView();
        }
        break;
      case RequestStatus.failure:
        return _errorContent(state);
      default:
        talents = state.talentsData?.talents;
        leaders = state.talentsData?.talentLeaders;
        if ((talents == null || talents!.isEmpty) &&
            (leaders == null || leaders!.isEmpty)) {
          return const Center(child: Text(Strings.label_no_talent_display));
        }

        return SingleChildScrollView(
          // Use SingleChildScrollView
          child: Column(
            // Use Column instead of ListView in _buildTalentList
            children: [
              const SizedBox(child: RatingInfoWidget()),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF3FF),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Wrap(
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/info-circle-reverse.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                                Color(0xFF0F679A), BlendMode.srcIn),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Dapatkan 500 poin KomPoint dengan mengisi evaluasi minimal 20 karakter!',
                              style: AppTypography.regular10
                                  .copyWith(color: const Color(0xFF0F679A)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(left: 24.0, right: 24.0),
                  child: _buildRatingHeader()),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Divider(),
              ),
              _buildLeaderList(),
              _buildTalentList(), // Updated line
              // Display total amount
            ],
          ),
        );
    }

    return Container();
  }

  Widget _buildTalentList() {
    return Column(
      children: List<Widget>.generate(
        talents?.length ?? 0,
        (index) => GestureDetector(
          onTap: () {},
          child: ItemRowSetRating(
            talents: talents?[index],
            isChecked: talents?[index].isChecked ?? false,
            onEvaluationChanged: (evaluation, isValid) =>
                _updateEvaluation(evaluation, isValid, index, isLeader: false),
            onCheckboxChanged: (value) => _updateCheckAllState(value, index),
            onRatingChecked: (rating) => _updateSelectedRating(rating, index),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderList() {
    return Column(
      children: List<Widget>.generate(
        leaders?.length ?? 0,
        (index) => GestureDetector(
          onTap: () {},
          child: ItemRowSetRating(
            leaders: leaders?[index],
            isLeader: true,
            isChecked: leaders?[index].isChecked ?? false,
            onEvaluationChanged: (evaluation, isValid) =>
                _updateEvaluation(evaluation, isValid, index, isLeader: false),
            onCheckboxChanged: (value) => _updateCheckLeaderState(value, index),
            onRatingChecked: (rating) =>
                _updateSelectedLeaderRating(rating, index),
          ),
        ),
      ),
    );
  }

  void _updateEvaluation(String evaluation, bool isValid, int index,
      {required bool isLeader}) {
    setState(() {
      if (isLeader) {
        leaders?[index].evaluation = evaluation;
        leaders?[index].isValidEvaluation = isValid; // Simpan status validasi
      } else {
        talents?[index].evaluation = evaluation;
        talents?[index].isValidEvaluation = isValid; // Simpan status validasi
      }

      // Hitung ulang total amount
      _calculateTotalAmount();
    });
  }

  // Fungsi untuk menghitung total amount berdasarkan evaluasi valid
  void _calculateTotalAmount() {
    int total = 0;

    // Hitung dari talents
    if (talents != null) {
      for (var talent in talents!) {
        if (talent.isValidEvaluation == true) {
          total += 500; // 500 poin per evaluasi valid
        }
      }
    }

    // Hitung dari leaders
    if (leaders != null) {
      for (var leader in leaders!) {
        if (leader.isValidEvaluation == true) {
          total += 500; // 500 poin per evaluasi valid
        }
      }
    }

    totalAmount = total;
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CustomButton(
          text: Strings.label_give_rating,
          isActive: _isButtonActive(),
          onPressed: _submitRating,
        ),
      ),
    );
  }

  void _setAllCheckboxes(bool? value) {
    setState(() {
      isCheckAll = value ?? false;
      ratingAll = isCheckAll ? ratingAll : 0;

      talents?.forEach((element) {
        element.isChecked = isCheckAll;
        if (!isCheckAll) {
          element.rating = 0;
        }
      });

      leaders?.forEach((element) {
        element.isChecked = isCheckAll;
        if (!isCheckAll) {
          element.rating = 0;
        }
      });
    });
  }

  void _updateCheckAllState(bool? value, int index) {
    setState(() {
      talents?[index].isChecked = value ?? false;
      if (!(value ?? false)) {
        talents?[index].rating = 0;
      }
      isCheckAll =
          talents?.every((element) => element.isChecked == true) ?? false;
    });
  }

  void _updateCheckLeaderState(bool? value, int index) {
    setState(() {
      leaders?[index].isChecked = value ?? false;
      if (!(value ?? false)) {
        leaders?[index].rating = 0;
      }

      isCheckAll =
          leaders?.every((element) => element.isChecked == true) ?? false;
    });
  }

  void _updateSelectedRating(int rating, int index) {
    setState(() {
      // Update only the selected talent's rating and isChecked status.
      talents?[index].rating = rating;
      talents?[index].isChecked = true;

      // After updating the selected talent's rating, check if all talents have the same rating.
      // If they do, update the header rating (ratingAll) to reflect this.
      if (talents != null &&
          talents!.every((element) => element.rating == rating) &&
          leaders != null &&
          leaders!.every((element) => element.rating == rating)) {
        ratingAll = rating;
        isCheckAll = true;
      } else {
        isCheckAll =
            false; // Reset isCheckAll if not all talents have the same rating.
        ratingAll = 0; // Reset the header rating to 0.
      }
    });
  }

  void _updateSelectedLeaderRating(int rating, int index) {
    setState(() {
      // Update only the selected talent's rating and isChecked status.
      leaders?[index].rating = rating;
      leaders?[index].isChecked = true;

      // After updating the selected talent's rating, check if all talents have the same rating.
      // If they do, update the header rating (ratingAll) to reflect this.
      if (leaders != null &&
          leaders!.every((element) => element.rating == rating) &&
          talents != null &&
          talents!.every((element) => element.rating == rating)) {
        ratingAll = rating;
        isCheckAll = true;
      } else {
        isCheckAll =
            false; // Reset isCheckAll if not all talents have the same rating.
        ratingAll = 0; // Reset the header rating to 0.
      }
    });
  }

  void _updateHeaderRating(int rating) {
    setState(() {
      ratingAll = rating;
      isCheckAll = true;
      // for all talent
      talents?.forEach((element) {
        element.rating = rating;
        element.isChecked = true;
      });

      // for all leader
      leaders?.forEach((element) {
        element.rating = rating;
        element.isChecked = true;
      });
    });
  }

  bool _isButtonActive() {
    // Check if at least one talent is checked and has a rating greater than 1
    bool isAnyTalentCheckedAndRated = talents?.every(
            (element) => element.isChecked == true && element.rating >= 1) ??
        false;

    // Check if at least one leader is checked and has a rating greater than 1
    bool isAnyLeaderCheckedAndRated = leaders?.every(
            (element) => element.isChecked == true && element.rating >= 1) ??
        false;

    // Return true if at least one talent or one leader is checked and has a rating greater than 1
    return isAnyTalentCheckedAndRated && isAnyLeaderCheckedAndRated;
  }

  void _submitRating() {
    if ((talents ?? []).isEmpty && (leaders ?? []).isEmpty) {
      // Handle the case where both talents and leaders are null or empty here.
      return;
    }

    List<TalentsDataModel> submitTalents = talents ?? [];
    List<TalentLeaderModel> submitLeaders = leaders ?? [];
    // print(
    //     'Submitting ratings: talents: ${submitTalents.length}, leaders: ${submitLeaders.length} dan total amount: $totalAmount');
    setState(() {
      // isSubmitting = true;
      AppRouter.router.push(PAGES.evaluationKompointPage.screenPath, extra: {
        "xenditUrl": widget.xenditUrl,
        "invoiceCode": widget.invoiceCode,
        "invoiceId": widget.invoiceId,
        "komPoint": totalAmount,
        "submitTalents": submitTalents,
        "submitLeaders": submitLeaders,
      });
      // context.read<RateTalentBloc>().add(SetTalentRateReq(
      //     submitTalents, submitLeaders, widget.invoiceId, totalAmount));
    });
  }
}
