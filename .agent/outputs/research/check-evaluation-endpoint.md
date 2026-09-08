---
topic: Check Evaluation Endpoint Refactor
date: 2026-09-07
version: 1
status: completed
related_files:
  - lib/core/data/apiservice/constat_endpoint.dart
  - lib/core/data/models/invoice_detail_response.dart
  - lib/core/data/datasources/remote/invoice_remote_datasource.dart
  - lib/core/data/repositories/invoice_repository_impl.dart
  - lib/core/domain/usecases/check_talent_evaluation_use_case.dart
  - lib/features/superapp/features/team/invoice/bloc/invoice_report_summary_bloc.dart
  - lib/features/superapp/features/team/invoice/bloc/invoice_report_summary_state.dart
  - lib/features/superapp/features/team/invoice/view/invoice_report_summary_page.dart
---

# Research: Check Evaluation Endpoint Refactor

## Summary
Endpoint `check_evaluations` diganti dari `/api/v1/mobile/evaluations/check_evaluations` ke `/api/v1/evaluations/check_evaluations` (hapus prefix `/mobile`).
Response baru hanya mengembalikan `{ "data": { "is_evaluated": true/false } }` — tidak ada lagi `invoice_id`, `invoice_code`, dan `xendit_payment_link`.
Semua layer (Model → BLoC → UI) sudah disesuaikan.

## File yang Relevan

- `lib/core/data/apiservice/constat_endpoint.dart` — definisi endpoint `checkEvaluation`
- `lib/core/data/models/invoice_detail_response.dart` — model `CheckEvaluationResponse` (kelas terpisah di file yang sama dengan `InvoiceDetailResponse`)
- `lib/core/data/datasources/remote/invoice_remote_datasource.dart` — pemanggil API, method `checkTalentEvaluation(String id)`
- `lib/features/superapp/features/team/invoice/bloc/invoice_report_summary_bloc.dart` — handler `_handleCheckEvaluation`
- `lib/features/superapp/features/team/invoice/bloc/invoice_report_summary_state.dart` — state `InvoiceDetailState` field `invoiceCheckEvaluation`
- `lib/features/superapp/features/team/invoice/view/invoice_report_summary_page.dart` — BlocConsumer listener yang handle navigasi

## Architecture / Data Flow

```
UI (tombol bayar/rating)
  → BLoC: CheckEvalutionEvent(invoiceId)
  → UseCase: checkTalentEvaluationUseCase.execute(invoiceId)
  → Repository: checkTalentsEvaluation(invoiceId)
  → DataSource: GET /api/v1/evaluations/check_evaluations?invoice_id=xxx
  → Response: { "meta": {...}, "data": { "is_evaluated": bool } }
  → CheckEvaluationResponse.fromJson() → isEvaluated: bool
  → BLoC emit:
      isEvaluated = false → statusEvaluation: success → UI navigasi ke rateTalentNotifPage
      isEvaluated = true  → statusEvaluation: empty  → tidak navigasi (sudah pernah rating)
```

## Existing Patterns yang Diikuti

- Response di-parse via `responseParser.parseResponse<T>()` — standard DioResponseParser project ini
- `CheckEvaluationResponse` extend `Equatable` dengan `props`
- BLoC emit `copyWith` untuk update state parsial
- Navigasi via `AppRouter.router.pushNamed()` dengan `queryParameters`

## Penting: Pemisahan Data

| Field | Sumber |
|---|---|
| `is_evaluated` | `CheckEvaluationResponse` ← dari `/api/v1/evaluations/check_evaluations` |
| `xenditPaymentUrl` (untuk payment) | `InvoiceDetailResponse` / `InvoiceDetailModel` ← dari `/api/v1/mobile/invoices/detail` |
| `invoiceCode` (untuk payment) | `InvoiceDetailModel` ← dari invoice detail |

`CheckEvaluationResponse` **bukan** sumber data payment — hanya gate cek sudah rating atau belum.
Data payment (`xenditPaymentUrl`, `invoiceCode`) tetap dari `state.invoiceDetail`.

## Risks & Edge Cases

- `json['is_evaluated'] ?? false` — default `false` jika field null (aman, user diarahkan ke rating)
- `statusEvaluation` default di state adalah `RequestStatus.dataExhausted` — bukan `empty`, jadi listener tidak trigger saat init
- Warning lint `prefer_typing_uninitialized_variables` di line 36 `invoice_report_summary_page.dart` adalah **pre-existing**, bukan dari perubahan ini

## Notes

- `setRating` (store evaluation) endpoint TIDAK diubah → masih di `/api/v1/mobile/evaluations/store`
- `CheckEvaluationResponse` ada di file `invoice_detail_response.dart` bukan file terpisah

---

## 📋 Changelog
| Versi | Tanggal    | Perubahan |
|-------|------------|-----------|
| v1    | 2026-09-07 | Initial: refactor endpoint + model + BLoC + UI check_evaluations |
