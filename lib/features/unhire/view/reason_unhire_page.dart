
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/global/widgets/confirmation_dialog_unhire.dart';
import 'package:komtim_partner/common/global/widgets/custom_button.dart';
import 'package:komtim_partner/common/global/widgets/custom_button_cancel.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/features/unhire/bloc/talent_list_selected_bloc.dart';
import '../../../common/custom_filtering_text_input.dart';
import '../../../common/enum_status.dart';
import '../../../common/global/mixin/handling_error_page.dart';
import '../../../common/global/router/app_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/styles.dart';
import '../../../core/domain/entities/talents_model.dart';
import '../widget/talents_detail.dart';

List<TalentsSelectedDataModel>? selectedTalents;
List<TalentsSelectedDataModel> submitTalents = [];
List<TalentsUnhireDataModel> unhire = [];
TalentsSelectedDataModel? talentUpdate;
int idx = 0;

class UnhireReasonPage extends StatefulWidget {
  final double count;
  final int index;
  final int allCount;
  const UnhireReasonPage(
      {Key? key,
      required this.count,
      required this.index,
      required this.allCount})
      : super(key: key);

  @override
  State<UnhireReasonPage> createState() => _UnhireReasonPageState();

  static Future<void> showConfirmation(
      BuildContext context,
      TalentListSelectedBloc talentListSelectedBloc,
      String textConfir,
      String reason) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialogUnhire(
          onYesPressed: () {
            submitTalents = selectedTalents!;
            submitTalents[idx].reason = reason;
            talentListSelectedBloc
                .add(SubmitUnhireTalents(unhire, submitTalents));
            AppRouter.router.go(PAGES.dialogUnhireFinish.screenPath);
          },
          onNoPressed: () {
            AppRouter.router.pop();
          },
          textConfirmation: textConfir,
        );
      },
    );
  }
}

class _UnhireReasonPageState extends State<UnhireReasonPage>
    with ErrorHandlingMixin {
  final TextEditingController _controller = TextEditingController();
  bool isButtonActive = false;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        isButtonActive = _controller.text.length >= 20;
      });
    });
    context.read<TalentListSelectedBloc>().add(const TalentListSelectedPageDidload());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getTextValue() {
    return _controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(Strings.label_reason_stop, style: AppTypography.interSemiBold16),
        leading: IconButton(
          icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
          onPressed: () {
            AppRouter.router.pop();
          },
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<TalentListSelectedBloc, TalentListSelectedState>(
              builder: (context, state) {
            if (state.status == RequestStatus.failure) {
              handleFailureState(context, state, state.message);
            }
            if (state.status == RequestStatus.loading) {
              return const CircularProgressIndicator();
            }
            if (state.status != RequestStatus.success) {
              return Container();
            }

            selectedTalents = state.talentData;
            return TalentDetails(
              talents: selectedTalents,
              count: widget.count,
              index: widget.index,
            );
          }),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                Strings.label_write_reason_stop,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Container(
              height: 118,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: TextField(
                maxLines: 5,
                controller: _controller,
                inputFormatters: [
                  //allow
                 CustomTextInputFormatter.denyTextInput(),
                 CustomTextInputFormatter.allowTextInput()
                ],
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    isActive: isButtonActive,
                    text: widget.count - 1 == widget.index
                        ? Strings.label_submit
                        : Strings.label_continue,
                    onPressed: () {
                      if (widget.count - 1 == widget.index) {
                        idx = widget.index;
                        UnhireReasonPage.showConfirmation(
                          context,
                          context.read<TalentListSelectedBloc>(),
                          widget.count.toInt() == widget.allCount
                              ? Strings.dialog_stop_all_talent
                              : Strings.dialog_stop_selected_talent,
                          _controller.text,
                        );
                      } else {
                        AppRouter.router.push(
                            '${PAGES.reasonUnhirePage.screenPath}?count=${widget.count}&index=${widget.index + 1}&allCount=${widget.allCount}');
                        selectedTalents?[widget.index].reason =
                            _controller.text;
                        context.read<TalentListSelectedBloc>().add(
                            UpdateSelectedTalentPageDidload(
                                selectedTalents![widget.index]));
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButtonCancel(
                    text: Strings.label_cancel,
                    onPressed: () {
                      AppRouter.router.pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
