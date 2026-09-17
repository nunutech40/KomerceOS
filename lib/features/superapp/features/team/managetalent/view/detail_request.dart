import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_app_bar.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/features/superapp/features/team/managetalent/widget/build_role_badge.dart';

enum InvoiceState { notSubmitted, unpaid, done }

class DetailRequestPage extends StatelessWidget {
  final String talentName;
  final String talentRole;
  final String talentId;
  final String avatarInitials;
  final String talentLead;
  final String workingDuration;
  final String requestType;
  final String requestReason;
  final String requestNote;
  final String submittedDate;
  final String effectiveDate;
  final InvoiceState invoiceState;

  const DetailRequestPage({
    super.key,
    this.talentName = 'Lindsey Kilback',
    this.talentRole = 'Customer Service',
    this.talentId = '123432DSD',
    this.avatarInitials = 'AB',
    this.talentLead = 'Budi',
    this.workingDuration = '1 tahun 2 bulan',
    this.requestType = 'Berhentikan Talent',
    this.requestReason = 'Performa tidak sesuai ekspektasi',
    this.requestNote =
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaa',
    this.submittedDate = '12 Jun 2026',
    this.effectiveDate = '12 Jul 2026',
    this.invoiceState = InvoiceState.unpaid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const DsAppBar(title: 'Detail Request'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTalentInfoCard(),
            const SizedBox(height: 16),
            _buildRequestSummaryCard(),
            const SizedBox(height: 16),
            if (invoiceState != InvoiceState.done) ...[
              _buildInvoiceSection(context),
              const SizedBox(height: 16),
            ],
            _buildActivityCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTalentInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                      child: Text(avatarInitials,
                          style: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontWeight: FontWeight.bold,
                              fontSize: 14))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(talentName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF0A0A0A))),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          BuildRoleBadge(role: talentRole),
                          const SizedBox(width: 6),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF9E9E9E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(talentId,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF737373))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Talent Lead',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF737373))),
                        const SizedBox(height: 2),
                        Text(talentLead,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                  Container(
                      width: 1, height: 30, color: const Color(0xFFE2E2E2)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Durasi Kerja',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF737373))),
                        const SizedBox(height: 2),
                        Text(workingDuration,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Request',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tipe Request',
                  style: TextStyle(fontSize: 14, color: Color(0xFF737373))),
              Text(requestType,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE5E5E5), height: 1),
          const SizedBox(height: 14),
          const Text('Alasan',
              style: TextStyle(fontSize: 14, color: Color(0xFF737373))),
          const SizedBox(height: 4),
          Text(requestReason,
              style: const TextStyle(fontSize: 14, color: Color(0xFF0A0A0A))),
          const SizedBox(height: 14),
          const Text('Keterangan tambahan',
              style: TextStyle(fontSize: 14, color: Color(0xFF737373))),
          const SizedBox(height: 4),
          Text(requestNote,
              style: const TextStyle(fontSize: 14, color: Color(0xFF0A0A0A))),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE5E5E5), height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tanggal Pengajuan',
                  style: TextStyle(fontSize: 14, color: Color(0xFF737373))),
              Text(submittedDate,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5E5E5), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tanggal Efektif',
                  style: TextStyle(fontSize: 14, color: Color(0xFF737373))),
              Text(effectiveDate,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSection(BuildContext context) {
    if (invoiceState == InvoiceState.notSubmitted)
      return _buildInvoiceNotSubmitted();
    if (invoiceState == InvoiceState.unpaid)
      return _buildInvoiceUnpaid(context);
    return const SizedBox.shrink();
  }

  Widget _buildInvoiceNotSubmitted() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDBDBE), width: 1),
        ),
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: const Color(0xFFFFCDCE),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: const Color(0xFFF4A9AA), width: 1)),
                child: const Center(
                    child: Icon(Icons.receipt_long_outlined,
                        color: Color(0xFFE5484D), size: 18)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice Prorate belum diajukan',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
              'Menunggu tagihan dari admin. Anda tidak perlu melakukan aksi apapun.',
              style: TextStyle(fontSize: 12, color: Color(0xFF737373))),
        ]));
  }

  Widget _buildInvoiceUnpaid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDBDBE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCDCE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF4A9AA), width: 1),
                ),
                child: Center(
                    child: SvgPicture.asset(
                        'assets/images/superapp/team/ic_invoice_detail.svg')),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Terdapat invoice belum dibayar",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Due Date
          Row(
            children: [
              const Text(
                "Due date",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF737373),
                ),
              ),
              const Spacer(),
              SvgPicture.asset('assets/images/superapp/team/ic_time.svg'),
              const SizedBox(width: 6),
              const Text(
                "30 Hari",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// Invoice Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCDCE),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFF4A9AA), width: 1),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                        'assets/images/superapp/team/ic_invoice_detail.svg'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Invoice #INV-2025-0042",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0A0A0A),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEEBEC),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              "Belum Lunas",
                              style: TextStyle(
                                color: Color(0xFFE5484D),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF737373),
                          ),
                          children: [
                            TextSpan(text: "Periode Invoice: "),
                            TextSpan(
                              text: "Mei 2026",
                              style: TextStyle(
                                color: Color(0xFF0A0A0A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Rp2.000.000",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// Button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Bayar Sekarang",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    final List<_ActivityItem> activities = invoiceState == InvoiceState.done
        ? [
            const _ActivityItem(
                title: 'Request Diajukan',
                subtitle: 'Talent Lead: Budi',
                date: '12 Okt 2026',
                time: '09:00 WIB',
                isDone: true),
            const _ActivityItem(
                title: 'On Progress',
                subtitle: 'Admin: Mulai proses invoice',
                date: '12 Okt 2026',
                time: '11:00 WIB',
                isDone: true),
            const _ActivityItem(
                title: 'Menunggu Pembayaran Invoice',
                subtitle: 'Talent Lead: Budi',
                date: '12 Okt 2026',
                time: '11:30 WIB',
                isDone: true),
            const _ActivityItem(
                title: 'Pembayaran Invoice',
                subtitle: 'Talent Lead: Budi',
                date: '12 Okt 2026',
                time: '11:30 WIB',
                isDone: true),
            const _ActivityItem(
                title: 'On Progress',
                subtitle: 'Admin: Menunggu penyelesaian dokumen',
                date: '12 Okt 2026',
                time: '11:00 WIB',
                isDone: true),
            const _ActivityItem(
                title: 'Selesai',
                subtitle:
                    'Semua kewajiban selesai dan talent sudah di set status off',
                date: '12 Okt 2026',
                time: '11:00 WIB',
                isDone: true,
                isLast: true),
          ]
        : [
            const _ActivityItem(
                title: 'Request Diajukan',
                subtitle: 'Talent Lead: Budi',
                date: '12 Okt 2026',
                time: '09:00 WIB',
                isDone: false),
            const _ActivityItem(
                title: 'On Progress',
                subtitle: 'Admin: Mulai proses invoice',
                date: '12 Okt 2026',
                time: '11:00 WIB',
                isDone: true),
            const _ActivityItem(
                title: 'Menunggu Pembayaran Invoice',
                subtitle: 'Talent Lead: Budi',
                date: '12 Okt 2026',
                time: '11:30 WIB',
                isDone: true),
            const _ActivityItem(
                title: 'Pembayaran Invoice',
                subtitle: 'Talent Lead: Budi',
                date: '12 Okt 2026',
                time: '11:30 WIB',
                isDone: true),
            const _ActivityItem(
                title: 'On Progress',
                subtitle: 'Admin: Menunggu penyelesaian dokumen',
                date: '12 Okt 2026',
                time: '11:00 WIB',
                isDone: true),
            const _ActivityItem(
                title: 'Selesai',
                subtitle:
                    'Semua kewajiban selesai dan talent sudah di set status off',
                date: '12 Okt 2026',
                time: '11:00 WIB',
                isDone: true,
                isLast: true),
          ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aktivitas & Status',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 16),
          ...activities.map((item) => _buildActivityItem(item)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(_ActivityItem item) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isDone ? primaryColor : const Color(0xFF737373),
                  border: Border.all(
                      color: item.isDone
                          ? const Color(0xFFC9E6D4)
                          : Colors.transparent,
                      width: 2),
                ),
              ),
              if (!item.isLast)
                Expanded(
                    child: Container(
                        width: 1.5,
                        color: const Color(0xFFE2E2E2),
                        margin: const EdgeInsets.symmetric(vertical: 4))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: item.isLast ? 0 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                        const SizedBox(height: 2),
                        Text(item.subtitle,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF737373))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(item.date,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF0A0A0A))),
                      Text(item.time,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF737373))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final bool isDone;
  final bool isLast;
  const _ActivityItem(
      {required this.title,
      required this.subtitle,
      required this.date,
      required this.time,
      this.isDone = false,
      this.isLast = false});
}
