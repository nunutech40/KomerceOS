import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/common/global/widgets/custom_button_next_unhire.dart';
import 'package:komtim_partner/common/global/widgets/custom_button_unhire.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/core/data/models/talents_response.dart';
import 'package:komtim_partner/features/unhire/bloc/talent_list_bloc.dart';
import 'package:komtim_partner/features/unhire/widget/talents_unhire_item.dart';

import '../../../common/enum_status.dart';
import '../../../common/global/mixin/handling_error_page.dart';
import '../../../common/global/router/app_router.dart';
import '../../../common/global/router/router_utils.dart';
import '../../../common/styles.dart';
import '../../../core/data/datasources/preferences/shared_pref.dart';
import '../../../core/domain/entities/talents_model.dart';

final pref = di.locator<SharedPref>();
String _searchQuery = '';
final _controller = TextEditingController();
List<TalentsSelectedData> _talentSelected = [];
List<TalentsDataModel> talents = [];
List<TalentsDataModel> beforeSearch = [];
bool isLoading = false;

class UnhirePage extends StatefulWidget {
  const UnhirePage({Key? key}) : super(key: key);

  @override
  State<UnhirePage> createState() => _UnhireListPageState();
}

class _UnhireListPageState extends State<UnhirePage> with ErrorHandlingMixin {
  List<TalentsDataModel> _filteredTalents = [];

  void _filterTalents() {
    if (_searchQuery.isNotEmpty) {
      // If there's a search query, filter talents based on the search criteria
      _filteredTalents = talents
          .where((talent) => talent.talentName!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();

      // Move selected talents to the top
      _filteredTalents = moveSelectedToTop(_filteredTalents);
    } else {
      // If there's no search query, simply set _filteredTalents to talents
      _filteredTalents = moveSelectedToTop(talents);
    }
  }

  Future<void> _handleLanjutkanPressed() async {
    final selectedTalents =
        talents.where((talent) => talent.isSelected == true).toList();

    if (talents.isNotEmpty) {
      _talentSelected = selectedTalents.map((selectedTalent) {
        return TalentsSelectedData(
          jobAssigneeId: selectedTalent.jobAssigneeId!,
          talentId: selectedTalent.talentId!,
          talentName: selectedTalent.talentName!,
          hiredDate: selectedTalent.hiredDate!,
          duration: selectedTalent.duration!,
          isSelected: selectedTalent.isSelected!,
          reason: '',
        );
      }).toList();
      final count = _talentSelected.length;
      context.read<TalentListBloc>().add(SaveTalentsSelected(_talentSelected));
      AppRouter.router.push(
          '${PAGES.reasonUnhirePage.screenPath}?count=$count&index=${0}&allCount=${talents.length}');
    }
  }

  @override
  void initState() {
    super.initState();
    talents.clear();
    context.read<TalentListBloc>().add(const TalentListPageDidload());
  }

  Future<void> clearTalents() async {
    await pref.clearTalents();
  }

  void _updateCheckAllState(bool? value, int index) {
    setState(() {
      // Toggle the isSelected status of the talent
      _filteredTalents[index].isSelected =
          !(_filteredTalents[index].isSelected ?? false);

      // Find the corresponding talent in the original 'talents' list and update its isSelected status
      final talentId = _filteredTalents[index].talentId;
      final originalTalent = talents.firstWhere((t) => t.talentId == talentId);
      originalTalent.isSelected = _filteredTalents[index].isSelected;
    });
  }

  void setAllTalentsChecked() {
    setState(() {
      for (var talent in talents) {
        talent.isSelected = true;
      }
    });
  }

  bool _isButtonActive() {
    bool isAnyTalentChecked =
        talents.any((element) => element.isSelected == true);
    return isAnyTalentChecked;
  }

  List<TalentsDataModel> moveSelectedToTop(List<TalentsDataModel> talents) {
    List<TalentsDataModel> selectedItems = [];
    List<TalentsDataModel> unselectedItems = [];

    for (var talent in talents) {
      if (talent.isSelected == true) {
        selectedItems.add(talent);
      } else {
        unselectedItems.add(talent);
      }
    }

    return talents = selectedItems + unselectedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.label_unhire_talent,
            style: AppTypography.interSemiBold16),
        leading: IconButton(
          icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
          onPressed: () {
            AppRouter.router.pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 27.0, 24.0, 0),
            child: TextField(
              controller: _controller,
              maxLines: 1,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: Strings.label_search_talent_name,
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: SvgPicture.asset(
                            'assets/images/ic-close-circle.svg'),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _controller.clear();
                          });
                        },
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Color(0xFFB3B3B3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Color(0xFFB3B3B3)),
                ),
              ),
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 37, 24, 12),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                Strings.label_talent_list,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          BlocBuilder<TalentListBloc, TalentListState>(
            builder: (context, state) {
              talents = state.talentData?.talents ?? [];

              if (state.status == RequestStatus.failure) {
                handleFailureState(context, state, state.message);
              }
              if (state.status == RequestStatus.loading) {
                if (state.operation == "getTalents") {
                  isLoading = state.status == RequestStatus.loading;
                }
              }
              if (state.status != RequestStatus.success) {
                return Container();
              }

              // Call _filterTalents() whenever the state changes
              _filterTalents();

              return Expanded(
                child: ListView.separated(
                  itemCount: _filteredTalents.length,
                  itemBuilder: (context, index) => InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: TalentsUnhireItem(
                        isLoading: false,
                        talents: _filteredTalents[
                            index], // Use _filteredTalents here
                        isChecked: _filteredTalents[index].isSelected ?? false,
                        onCheckboxChanged: (value) =>
                            _updateCheckAllState(value, index),
                      ),
                    ),
                  ),
                  separatorBuilder: (context, index) => const Divider(
                    indent: 24.0,
                    endIndent: 24.0,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: SizedBox(
              width: double.infinity,
              child: CustomButtonUnhire(
                text: Strings.label_stop_all,
                onPressed: () {
                  setState(() {
                    setAllTalentsChecked();
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: CustomButtonNextUnhire(
                text: Strings.label_continue,
                isActive: _isButtonActive(),
                onPressed: _handleLanjutkanPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
