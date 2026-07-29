import 'package:flutter_bloc/flutter_bloc.dart';
import 'global_alert_event.dart';
import 'global_alert_state.dart';

class GlobalAlertBloc extends Bloc<GlobalAlertEvent, GlobalAlertState> {
  GlobalAlertBloc() : super(GlobalAlertInitial()) {
    on<ShowServerErrorEvent>((event, emit) {
      emit(GlobalAlertShowServerError(
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    });
  }
}
