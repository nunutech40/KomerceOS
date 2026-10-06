import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';

class CountdownWidget extends StatelessWidget {
  final String? targetDate;
  final Function(bool)? onCountdownFinish;
  final Function(bool)? isTapped;

  const CountdownWidget(
      {Key? key, this.targetDate, this.onCountdownFinish, this.isTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime targetDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(targetDate!);

    return StreamBuilder(
      stream: countdownStream(targetDateTime),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Duration duration = snapshot.data as Duration;
          int remainingSeconds = duration.inSeconds;

          bool isCountdownFinished = remainingSeconds <= 0;

          if (onCountdownFinish != null && isCountdownFinished) {
            onCountdownFinish!(isCountdownFinished);
          }

          return GestureDetector(
            onTap: () {
              if (isCountdownFinished) {
                isTapped!(true);
              }
            },
            child: Text(
              isCountdownFinished
                  ? Strings.label_resend
                  : 'Kirim Ulang ($remainingSeconds detik)',
              style: TextStyle(
                color: isCountdownFinished ? errorColor : Colors.blueGrey,
                fontWeight: isCountdownFinished ? FontWeight.w700 : null,
              ),
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Stream<Duration> countdownStream(DateTime targetDateTime) async* {
    while (true) {
      Duration duration = targetDateTime.difference(DateTime.now());
      yield duration;
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
