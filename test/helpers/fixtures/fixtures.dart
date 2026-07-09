import 'package:komtim_partner/core/domain/entities/attendance_model.dart';
import 'package:komtim_partner/core/domain/entities/invoices_model.dart';
import 'package:komtim_partner/core/domain/entities/profile_model.dart';

/// Factory untuk membuat mock data yang reusable
/// Gunakan class ini untuk membuat test data yang konsisten
class MockDataFactory {
  // ==================== INVOICE MOCKS ====================

  /// Buat mock invoice dengan status PAID
  static InvoicesDataModel createPaidInvoice({
    String? invoiceCode,
    int? amountTotal,
    String? transactionType,
  }) {
    return InvoicesDataModel(
      invoiceId: 1,
      invoiceCode: invoiceCode ?? 'INV-PAID-001',
      amountTotal: amountTotal ?? 150000,
      isPaid: true,
      transactionStatus: 'paid',
      transactionType: transactionType ?? 'invoice',
      createdAt: '2026-06-15 10:00:00',
      updatedAt: '2026-06-15 11:00:00',
      expiredAt: '2026-06-20 23:59:59',
    );
  }

  /// Buat mock invoice dengan status UNPAID
  static InvoicesDataModel createUnpaidInvoice({
    String? invoiceCode,
    int? amountTotal,
    String? transactionType,
  }) {
    return InvoicesDataModel(
      invoiceId: 2,
      invoiceCode: invoiceCode ?? 'INV-UNPAID-001',
      amountTotal: amountTotal ?? 250000,
      isPaid: false,
      transactionStatus: 'unpaid',
      transactionType: transactionType ?? 'invoice',
      createdAt: '2026-06-10 08:00:00',
      updatedAt: '2026-06-10 08:00:00',
      expiredAt: '2026-06-25 23:59:59',
    );
  }

  /// Buat mock invoice dengan status PENDING
  static InvoicesDataModel createPendingInvoice({
    String? invoiceCode,
    int? amountTotal,
  }) {
    return InvoicesDataModel(
      invoiceId: 3,
      invoiceCode: invoiceCode ?? 'INV-PENDING-001',
      amountTotal: amountTotal ?? 100000,
      isPaid: false,
      transactionStatus: 'pending',
      transactionType: 'invoice',
      createdAt: '2026-06-18 14:00:00',
      updatedAt: '2026-06-18 14:00:00',
      expiredAt: '2026-06-30 23:59:59',
    );
  }

  /// Buat mock invoice dengan status CANCELED
  static InvoicesDataModel createCanceledInvoice({
    String? invoiceCode,
    int? amountTotal,
  }) {
    return InvoicesDataModel(
      invoiceId: 4,
      invoiceCode: invoiceCode ?? 'INV-CANCELED-001',
      amountTotal: amountTotal ?? 300000,
      isPaid: false,
      transactionStatus: 'canceled',
      transactionType: 'invoice',
      createdAt: '2026-06-12 10:00:00',
      updatedAt: '2026-06-12 15:00:00',
      expiredAt: '2026-06-20 23:59:59',
    );
  }

  /// Buat mock invoice TOPUP
  static InvoicesDataModel createTopupInvoice({
    String? invoiceCode,
    int? amountTotal,
  }) {
    return InvoicesDataModel(
      invoiceId: 5,
      invoiceCode: invoiceCode ?? 'TOPUP-001',
      amountTotal: amountTotal ?? 500000,
      isPaid: true,
      transactionStatus: 'paid',
      transactionType: 'topup',
      createdAt: '2026-06-19 02:00:00',
      updatedAt: '2026-06-19 02:00:00',
    );
  }

  /// Buat mock invoice WITHDRAWAL
  static InvoicesDataModel createWithdrawalInvoice({
    String? invoiceCode,
    int? amountTotal,
    String? status,
  }) {
    return InvoicesDataModel(
      invoiceId: 6,
      invoiceCode: invoiceCode ?? 'WD-001',
      amountTotal: amountTotal ?? 200000,
      isPaid: status == 'completed',
      transactionStatus: status ?? 'completed',
      transactionType: 'withdrawal',
      createdAt: '2026-06-18 15:00:00',
      updatedAt: '2026-06-18 16:00:00',
    );
  }

  /// Buat list invoice dengan berbagai status
  static List<InvoicesDataModel> createInvoiceList({int count = 5}) {
    final invoices = [
      createPaidInvoice(invoiceCode: 'INV-001'),
      createUnpaidInvoice(invoiceCode: 'INV-002'),
      createPendingInvoice(invoiceCode: 'INV-003'),
      createPaidInvoice(invoiceCode: 'INV-004', amountTotal: 500000),
      createCanceledInvoice(invoiceCode: 'INV-005'),
    ];
    return invoices.take(count).toList();
  }

  // ==================== PROFILE MOCKS ====================

  /// Buat mock profile lengkap
  static ProfileModel createProfile({
    int? id,
    String? fullname,
    String? email,
    String? noTelp,
  }) {
    return ProfileModel(
      id: id ?? 1,
      partnerId: 101,
      partnerNo: 'P-001',
      fullname: fullname ?? 'Test User',
      username: 'testuser',
      email: email ?? 'test@example.com',
      noTelp: noTelp ?? '081234567890',
      address: 'Jl. Test No. 123',
      joinDate: '2026-01-01',
      bankName: 'Bank Test',
      bankAccountNumber: '1234567890',
      photoProfileUrl: 'https://via.placeholder.com/150',
      bankOwnerName: 'Test User',
      createdAt: '2026-01-01 00:00:00',
      updatedAt: '2026-06-19 00:00:00',
      kmPoin: 1000,
      accountStatus: 'active',
      kompoin: 500000,
      businessSectoreId: 1,
    );
  }

  /// Buat mock profile dengan status inactive
  static ProfileModel createInactiveProfile() {
    return ProfileModel(
      id: 2,
      partnerId: 102,
      partnerNo: 'P-002',
      fullname: 'Inactive User',
      username: 'inactiveuser',
      email: 'inactive@example.com',
      noTelp: '081234567891',
      accountStatus: 'inactive',
      kmPoin: 0,
      kompoin: 0,
    );
  }

  // ==================== ATTENDANCE MOCKS ====================

  /// Buat mock attendance
  static AttendanceModel createAttendance({
    int? id,
    String? fullName,
    String? checkInDatetime,
    String? checkOutDatetime,
  }) {
    return AttendanceModel(
      id: id ?? 1,
      fullName: fullName ?? 'John Worker',
      roleId: 1,
      officeId: 1,
      officeName: 'Office A',
      checkInDatetime: checkInDatetime ?? '2026-06-19 08:00:00',
      checkOutDatetime: checkOutDatetime ?? '2026-06-19 17:00:00',
      checkInPhotoUrl: 'https://via.placeholder.com/150',
      checkOutPhotoUrl: 'https://via.placeholder.com/150',
      workMode: 'WFO',
      createdAt: '2026-06-19 08:00:00',
      updatedAt: '2026-06-19 17:00:00',
    );
  }

  /// Buat mock attendance tanpa check out (masih bekerja)
  static AttendanceModel createAttendanceWithoutCheckout() {
    return AttendanceModel(
      id: 2,
      fullName: 'Jane Worker',
      roleId: 1,
      officeId: 1,
      officeName: 'Office A',
      checkInDatetime: '2026-06-19 08:30:00',
      checkOutDatetime: null,
      checkInPhotoUrl: 'https://via.placeholder.com/150',
      workMode: 'WFO',
      createdAt: '2026-06-19 08:30:00',
      updatedAt: '2026-06-19 08:30:00',
    );
  }

  /// Buat mock attendance WFH
  static AttendanceModel createAttendanceWFH() {
    return AttendanceModel(
      id: 3,
      fullName: 'Bob Remote',
      roleId: 2,
      officeId: null,
      officeName: null,
      checkInDatetime: '2026-06-19 09:00:00',
      checkOutDatetime: '2026-06-19 18:00:00',
      workMode: 'WFH',
      createdAt: '2026-06-19 09:00:00',
      updatedAt: '2026-06-19 18:00:00',
    );
  }

  /// Buat mock attendance terlambat (Late)
  static AttendanceModel createLateAttendance() {
    return AttendanceModel(
      id: 4,
      fullName: 'Late Worker',
      roleId: 1,
      officeId: 1,
      officeName: 'Office A',
      checkInDatetime: '2026-06-19 10:30:00',
      checkOutDatetime: '2026-06-19 17:00:00',
      checkInPhotoUrl: 'https://via.placeholder.com/150',
      checkOutPhotoUrl: 'https://via.placeholder.com/150',
      workMode: 'WFO',
      createdAt: '2026-06-19 10:30:00',
      updatedAt: '2026-06-19 17:00:00',
    );
  }

  // ==================== GENERIC HELPERS ====================

  /// Buat mock error message
  static String createErrorMessage({String? message}) {
    return message ?? 'Terjadi kesalahan. Silakan coba lagi.';
  }

  /// Buat mock success message
  static String createSuccessMessage({String? message}) {
    return message ?? 'Operasi berhasil dilakukan.';
  }
}
