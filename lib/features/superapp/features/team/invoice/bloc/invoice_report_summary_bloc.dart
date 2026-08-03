import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/core/data/models/invoice_detail_response.dart';
import 'package:komtim_partner/core/domain/entities/invoice_detail_model.dart';
import 'package:komtim_partner/core/domain/usecases/check_talent_evaluation_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/download_invoice_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_invoice_detail_use_case.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

part 'invoice_report_summary_event.dart';
part 'invoice_report_summary_state.dart';

class InvoiceDetailBloc extends Bloc<InvoiceDetailEvent, InvoiceDetailState> {
  InvoiceDetailBloc(
      {required this.getInvoiceDetailUseCase,
      required this.downloadInvoiceUseCase,
      required this.checkTalentEvaluationUseCase})
      : super(const InvoiceDetailState()) {
    on<InvoviceDetailPageDidload>(_handleDidLoadPage);
    on<CopyInvoiceDetail>(_handleCopyXenditUrl);
    on<InvoiceDownloadFile>(_handleInvoiceDownload);
    on<CheckEvalutionEvent>(_handleCheckEvaluation);
  }

  final GetInvoiceDetailUseCase getInvoiceDetailUseCase;
  final DownloadInvoiceUseCase downloadInvoiceUseCase;
  final CheckTalentEvaluationUseCase checkTalentEvaluationUseCase;

  Future<void> _handleInvoiceDownload(
    InvoiceDownloadFile event,
    Emitter<InvoiceDetailState> emit,
  ) async {
    emit(state.copyWith(isDownloading: true, operation: 'downloadInvoice'));

    final result = await downloadInvoiceUseCase.execute(event.invoiceId);

    if (result.isRight()) {
      emit(state.copyWith(isDownloading: false));

      try {
        Directory? directory;

        if (Platform.isAndroid) {
          // Request appropriate permissions for Android based on version
          bool permissionGranted = await _getStoragePermission();
          if (!permissionGranted) {
            emit(state.copyWith(
                message: Strings.label_permission_storage_denied,
                status: RequestStatus.failure,
                isDownloading: false));
            return;
          }
          directory = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          throw Exception(Strings.label_unable_get_directory);
        }

        // Create a file path with timestamp
        final filePath =
            '${directory.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';

        // Write the file
        final file = File(filePath);
        await file.writeAsBytes(result.getOrElse(() => Uint8List.fromList([])));

        // Open the file
        await OpenFile.open(filePath);
      } catch (e) {
        emit(state.copyWith(
            message: Strings.label_error_download_file,
            status: RequestStatus.failure,
            isDownloading: false));
      }
    } else {
      emit(state.copyWith(
          message: result.fold((l) => l.message, (r) => ''),
          status: RequestStatus.failure,
          isDownloading: false));
    }
  }

// Updated function to handle storage permission for Android 13 and below
  Future<bool> _getStoragePermission() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo android = await plugin.androidInfo;
    if (android.version.sdkInt < 33) {
      return await Permission.storage.request().isGranted;
    } else {
      // Android 13+ doesn't need permission for app-specific storage
      return true;
    }
  }

  Future<void> _handleDidLoadPage(
    InvoviceDetailPageDidload event,
    Emitter<InvoiceDetailState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'getInvoiceDetail'));

    final invoicesResult =
        await getInvoiceDetailUseCase.execute(event.invoiceId);

    invoicesResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (invoiceDetail) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            invoiceDetail: invoiceDetail));
      },
    );
  }

  Future<void> _handleCopyXenditUrl(
    CopyInvoiceDetail event,
    Emitter<InvoiceDetailState> emit,
  ) async {
    emit(state.copyWith(xenditUrl: event.xenditUrl));
  }

  Future<void> _handleCheckEvaluation(
    CheckEvalutionEvent event,
    Emitter<InvoiceDetailState> emit,
  ) async {
    emit(state.copyWith(
        statusEvaluation: RequestStatus.loading, operation: 'evaluation'));

    final invoicesCheckResult =
        await checkTalentEvaluationUseCase.execute(event.invoiceId);

    invoicesCheckResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message,
              statusEvaluation: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, statusEvaluation: RequestStatus.empty));
        }
      },
      (invoiceCheckEvaluation) {
        emit(state.copyWith(
            message: 'Success',
            operation: 'evaluation',
            statusEvaluation: RequestStatus.success,
            invoiceCheckEvaluation: invoiceCheckEvaluation));
      },
    );
  }
}
