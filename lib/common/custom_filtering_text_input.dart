import 'package:flutter/services.dart';

class CustomTextInputFormatter {

  /// allow character and spacial character
  static TextInputFormatter allowTextInput() {
    return FilteringTextInputFormatter.allow(RegExp(r'''[a-zA-Z0-9@#$_&-+()/<>=*:;!?.,'" -]'''));
  }

  /// deny imoji
  static TextInputFormatter denyTextInput() {
    return FilteringTextInputFormatter.deny(RegExp('(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'
  ));
  }
}
