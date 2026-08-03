import 'package:flutter/material.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/features/superapp/features/home/view/main_page.dart';

import '../../../core/data/datasources/preferences/shared_pref.dart';
import '../../../features/handlingerror/view/error_connection_page.dart';

mixin ErrorHandlingMixin {
  final pref = di.locator<SharedPref>();
  void handleFailureState(
      BuildContext context, dynamic state, String errorMessage) async {
    final statusLogin = await pref.isLoggedIn();
    if (!context.mounted) return;

    if (isRequestTimeout(errorMessage)) {
      showErrorBottomSheet(
        context,
        errorMessage,
        onPressed: () {
          if (statusLogin == true) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainPageSuperApp()),
            );
          } else {
            Navigator.pop(context);
          }
        },
      );
      return;
    }
    showFailureSnackBar(context, errorMessage);
  }

  bool isRequestTimeout(String errorMessage) {
    return errorMessage.contains('Request timeout') ||
        errorMessage.contains('Failed to connect to the network') ||
        errorMessage.contains('No internet connection');
  }

  void showFailureSnackBar(BuildContext context, String errorMessage) {
    final snackBar = SnackBar(content: Text(errorMessage));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // Assume showErrorBottomSheet method implementation is somewhere else
}
