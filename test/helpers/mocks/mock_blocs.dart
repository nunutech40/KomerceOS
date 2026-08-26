import 'package:bloc_test/bloc_test.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/invoice_list_bloc.dart';

/// Mock BLoC Classes
///
/// Usage:
/// ```dart
/// final mockBloc = MockInvoiceListBloc();
/// whenListen(
///   mockBloc,
///   Stream.fromIterable([LoadingState(), SuccessState()]),
///   initialState: InitialState(),
/// );
/// ```

class MockInvoiceListBloc extends MockBloc<InvoiceListEvent, InvoiceListState>
    implements InvoiceListBloc {}

// Tambahkan mock blocs lainnya sesuai kebutuhan
// Contoh:
// class MockLoginBloc extends MockBloc<LoginEvent, LoginState> implements LoginBloc {}
// class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}
