import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/custom_filtering_text_input.dart';
import 'package:komtim_partner/common/extension.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/widgets/checkbox_default.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';
import 'package:komtim_partner/features/superapp/features/team/ratetalent/widget/small_rating_white.dart';

class ItemRowSetRating extends StatefulWidget {
  final TalentsDataModel? talents;
  final TalentLeaderModel? leaders;
  final bool isChecked;
  final bool isHeader;
  final bool isLeader;
  final void Function(bool?)? onCheckboxChanged;
  final void Function(int)? onRatingChecked;
  final Function(String, bool)?
      onEvaluationChanged; // Updated to include validation result
  int setRating;
  final int? index;

  ItemRowSetRating({
    Key? key,
    this.talents,
    this.leaders,
    this.isHeader = false,
    this.isChecked = false,
    this.isLeader = false,
    this.onRatingChecked,
    this.setRating = 0,
    this.onEvaluationChanged,
    this.onCheckboxChanged,
    this.index,
  }) : super(key: key);

  @override
  State<ItemRowSetRating> createState() => _ItemRowSetRatingState();
}

class _ItemRowSetRatingState extends State<ItemRowSetRating> {
  bool isExpanded = false;
  late TextEditingController _evaluationController;
  bool isValidEvaluation = false;
  String validationMessage = '';

  @override
  void initState() {
    super.initState();
    _evaluationController = TextEditingController();
    _evaluationController.addListener(_onEvaluationChanged);
  }

  void _onEvaluationChanged() {
    String text = _evaluationController.text;
    bool isValid = _validateEvaluation(text);

    setState(() {
      isValidEvaluation = isValid;
      _updateValidationMessage(text, isValid);
    });

    if (widget.onEvaluationChanged != null) {
      widget.onEvaluationChanged!(text, isValid);
    }
  }

  bool _validateEvaluation(String text) {
    // Syarat 1: Evaluasi tidak kosong
    if (text.trim().isEmpty) {
      return false;
    }

    // Syarat 2: Evaluasi lebih dari 20 karakter
    if (text.trim().length < 20) {
      return false;
    }

    // Syarat 3: Evaluasi tidak hanya simbol atau angka
    RegExp alphaRegex = RegExp(r'[a-zA-Z]');
    if (!alphaRegex.hasMatch(text)) {
      return false;
    }

    // Syarat 4: Tidak ada spam karakter yang sama
    if (_isSpamText(text)) {
      return false;
    }

    // Jika semua syarat terpenuhi, baru valid untuk mendapat 500 poin
    return true;
  }

  bool _isSpamText(String text) {
    // Remove spaces and convert to lowercase for spam detection
    String cleanText = text.toLowerCase().replaceAll(' ', '');

    // Check for repeated characters (like "aaaa", "bbbb", "1111")
    RegExp repeatedChar = RegExp(r'(.)\1{3,}');
    if (repeatedChar.hasMatch(cleanText)) {
      return true;
    }

    // Check for repeated words (like "bagus bagus bagus")
    List<String> words = text.toLowerCase().split(' ');
    if (words.length >= 3) {
      String firstWord = words[0];
      if (firstWord.isNotEmpty &&
          words.take(3).every((word) => word == firstWord)) {
        return true;
      }
    }

    // Check for very simple patterns and spam words
    List<String> spamPatterns = [
      'asdf',
      'qwer',
      '1234',
      'abcd',
      'test',
      'tes',
      'coba',
      'good',
      'nice',
      'ok',
      'oke',
      'ya',
      'tidak',
      'bagus',
      '....',
      ',,,,',
      ';;;;',
      '::::',
      '!!!!'
    ];

    for (String pattern in spamPatterns) {
      if (cleanText.length <= pattern.length * 2 &&
          cleanText.contains(pattern * 2)) {
        return true;
      }
    }

    // Check if text is mostly repeated single characters
    Map<String, int> charCount = {};
    for (int i = 0; i < cleanText.length; i++) {
      String char = cleanText[i];
      charCount[char] = (charCount[char] ?? 0) + 1;
    }

    // If any single character appears more than 70% of the text, it's spam
    int maxCount =
        charCount.values.fold(0, (max, count) => count > max ? count : max);
    if (maxCount / cleanText.length > 0.7) {
      return true;
    }

    return false;
  }

  void _updateValidationMessage(String text, bool isValid) {
    String trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      validationMessage = '';
    } else if (trimmedText.length < 20) {
      validationMessage =
          'Minimal 20 karakter untuk mendapatkan 500 Kompoint (${trimmedText.length}/20)';
    } else if (!RegExp(r'[a-zA-Z]').hasMatch(text)) {
      validationMessage =
          'Evaluasi harus mengandung huruf, tidak boleh hanya angka/simbol';
    } else if (_isSpamText(text)) {
      validationMessage =
          'Evaluasi tidak valid. Berikan penilaian yang bermakna untuk mendapat 500 Kompoint';
    } else if (isValid) {
      validationMessage = '✓ Evaluasi valid! Anda akan mendapat 500 Kompoint';
    } else {
      validationMessage =
          'Evaluasi belum memenuhi syarat untuk mendapat 500 Kompoint';
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.setRating = widget.isHeader
        ? widget.setRating
        : (widget.isLeader
            ? (widget.leaders?.rating ?? 0)
            : (widget.talents?.rating ?? 0));

    return Container(
      color: widget.index == 0 ? const Color(0xFFF5F5F5) : Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: widget.index == 0 ? 2.0 : 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxDeft(
                      isChecked: widget.isChecked,
                      onChanged: widget.onCheckboxChanged,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truncateText(
                              widget.isLeader
                                  ? (widget.leaders?.staffName ?? 'Semua')
                                  : (widget.talents?.talentName ?? 'Semua'),
                              18),
                          style: widget.isHeader
                              ? AppTypography.semiBold14
                              : AppTypography.regular14,
                        ),
                        // if (widget.isLeader)
                        //   Text(Strings.label_talent_lead,
                        //       style: AppTypography.regular12
                        //           .copyWith(color: primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: Row(
                  children: [
                    SmallRatingWhite(
                      rating: '1',
                      isSelected: widget.setRating >= 1,
                      onTap: () => widget.onRatingChecked?.call(1),
                    ),
                    const SizedBox(width: 8.0),
                    SmallRatingWhite(
                      rating: '2',
                      isSelected: widget.setRating >= 2,
                      onTap: () => widget.onRatingChecked?.call(2),
                    ),
                    const SizedBox(width: 8.0),
                    SmallRatingWhite(
                      rating: '3',
                      isSelected: widget.setRating >= 3,
                      onTap: () => widget.onRatingChecked?.call(3),
                    ),
                    const SizedBox(width: 8.0),
                    SmallRatingWhite(
                      rating: '4',
                      isSelected: widget.setRating >= 4,
                      onTap: () => widget.onRatingChecked?.call(4),
                    ),
                    const SizedBox(width: 8.0),
                    SmallRatingWhite(
                      rating: '5',
                      isSelected: widget.setRating >= 5,
                      onTap: () => widget.onRatingChecked?.call(5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!widget.isHeader &&
              (widget.talents?.talentName ?? '') != Strings.label_all_talent)
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      TextField(
                        onTap: () {
                          if (!isExpanded) {
                            setState(() {
                              isExpanded = true;
                            });
                          }
                        },
                        controller: _evaluationController,
                        maxLines: isExpanded ? 4 : 1,
                        maxLength: isExpanded ? 300 : null,
                        style: AppTypography.regular12,
                        inputFormatters: [
                          CustomTextInputFormatter.denyTextInput(),
                          CustomTextInputFormatter.allowTextInput()
                        ],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                              left: 10, right: 24, top: 8, bottom: 8),
                          hintText: widget.isLeader
                              ? Strings.dialog_evaluation_talent_lead
                              : Strings.dialog_evaluation_talent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              width: 1,
                              style: BorderStyle.solid,
                              color: Colors.grey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              width: 1,
                              style: BorderStyle.solid,
                              color: borderGray,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                width: 1,
                                style: BorderStyle.solid,
                                color: isValidEvaluation
                                    ? Colors.green
                                    : primaryColor),
                          ),
                          isCollapsed: true,
                          counterText: '',
                        ),
                      ),
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Colors.grey,
                              BlendMode.srcIn,
                            ),
                            child: isExpanded
                                ? SvgPicture.asset(
                                    'assets/images/ic-arrow-up.svg')
                                : SvgPicture.asset(
                                    'assets/images/ic-arrow-down.svg'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_evaluationController.text.length} karakter',
                          style: AppTypography.regular12.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Hint text
                  // Text(
                  //   'Syarat mendapat 500 Kompoint:\n• Minimal 20 karakter\n• Mengandung huruf (bukan hanya angka/simbol)\n• Tidak spam/karakter berulang',
                  //   style: AppTypography.regular10.copyWith(
                  //     color: Colors.grey[600],
                  //   ),
                  // ),
                  // // Validation message
                  // if (validationMessage.isNotEmpty) ...[
                  //   const SizedBox(height: 4),
                  //   Text(
                  //     validationMessage,
                  //     style: AppTypography.regular10.copyWith(
                  //       color: isValidEvaluation ? Colors.green : Colors.orange,
                  //       fontWeight: isValidEvaluation
                  //           ? FontWeight.w600
                  //           : FontWeight.normal,
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _evaluationController.removeListener(_onEvaluationChanged);
    _evaluationController.dispose();
    super.dispose();
  }
}
