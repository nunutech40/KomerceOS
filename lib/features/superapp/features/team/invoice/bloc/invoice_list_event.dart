part of 'invoice_list_bloc.dart';

@immutable
abstract class InvoiceListEvent extends Equatable {
  const InvoiceListEvent();

  @override
  List<Object?> get props => [];
}

class RefreshDataEvent extends InvoiceListEvent {
  const RefreshDataEvent();
}

class InvoviceListPageDidload extends InvoiceListEvent {
  final String? type;
  final int offset;
  final int limit;

  const InvoviceListPageDidload({
    this.type,
    required this.offset,
    required this.limit,
  });

  @override
  List<Object?> get props => [
        type,
        offset,
        limit,
      ];
}
