import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/widgets/custom_text_labeling_error.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';

import '../../../../../../common/global/widgets/custom_text_labeling.dart';
import '../../../../../../common/utils/currency_format.dart';
import '../../../../../../common/utils/custom_date_format.dart';
import '../../../../../../core/domain/entities/invoice_detail_model.dart';
import 'dot_divider.dart';

class CardReportInvoice extends StatefulWidget {
  final InvoiceDetailModel? invoiceDetail;
  const CardReportInvoice({Key? key, required this.invoiceDetail})
      : super(key: key);

  @override
  State<CardReportInvoice> createState() => _CardReportInvoiceState();
}

class _CardReportInvoiceState extends State<CardReportInvoice> {
  // Nilai default sebelum sempat diukur (frame pertama), biar nggak ada
  // "kedipan" notch di posisi yang salah sebelum hasil ukur asli didapat.
  static const double _fallbackSideNotchCenterY = 112.0;

  // Origin Stack ini sama persis dengan origin ClipPath di dalamnya
  // (sama-sama top-left, non-positioned child pertama yang nge-set
  // ukuran Stack), jadi dipakai sebagai acuan koordinat lokal buat clipper.
  final GlobalKey _stackKey = GlobalKey();

  // Nempel di dashed divider yang letaknya PERSIS di atas baris
  // "Sub Total" pertama (atau padanannya di varian hideCosts). Ini yang
  // jadi acuan posisi lubang notch di sisi kiri-kanan card.
  final GlobalKey _dividerKey = GlobalKey();

  double? _sideNotchCenterY;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _measureDividerPosition());
  }

  @override
  void didUpdateWidget(covariant CardReportInvoice oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Data invoice beda -> tinggi header (badge jatuh tempo / metode
    // pembayaran) bisa beda -> posisi divider ikut geser -> ukur ulang.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _measureDividerPosition());
  }

  /// Ukur posisi vertikal (tengah) dashed divider di atas "Sub Total",
  /// relatif terhadap Stack pembungkus card, lalu simpan buat dipakai
  /// clipper. Dipanggil lagi tiap habis build supaya tetap akurat kalau
  /// ukuran layar / text scaling berubah.
  void _measureDividerPosition() {
    if (!mounted) return;

    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final dividerBox =
        _dividerKey.currentContext?.findRenderObject() as RenderBox?;

    if (stackBox == null ||
        dividerBox == null ||
        !stackBox.attached ||
        !dividerBox.attached) {
      return;
    }

    final Offset dividerCenterGlobal = dividerBox.localToGlobal(
      Offset(0, dividerBox.size.height / 2),
    );
    final double localY = stackBox.globalToLocal(dividerCenterGlobal).dy;

    if (_sideNotchCenterY == null ||
        (_sideNotchCenterY! - localY).abs() > 0.5) {
      setState(() => _sideNotchCenterY = localY);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jadwalkan pengukuran ulang tiap frame ini kelar dirender, biar
    // posisi notch selalu ngikutin posisi asli divider walau kontennya
    // dinamis (rotasi layar, data beda, dsb). setState di dalamnya cuma
    // jalan kalau posisinya benar-benar berubah, jadi aman dari infinite loop.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _measureDividerPosition());

    return Stack(
      key: _stackKey,
      children: [
        // Lapisan shadow saja: rounded-rect polos. Blur-nya cukup lembut
        // jadi nggak keliatan beda sama siluet bergerigi di lapisan atas.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  spreadRadius: 0,
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
        // Lapisan card putih yang beneran "dilubangi" di tepinya
        // (bukan ditimpa warna solid) supaya background di belakangnya
        // (foto/gradient oranye di InvoiceReportSummaryPage) tembus asli
        // di tiap lengkungan notch, bukan sekadar warna yang didekati.
        ClipPath(
          clipper: _TicketNotchClipper(
            sideNotchCenterY: _sideNotchCenterY ?? _fallbackSideNotchCenterY,
          ),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: widget.invoiceDetail?.hideCosts == true
                  ? cardInvoiceHidden()
                  : cardInvoice(),
            ),
          ),
        ),
      ],
    );
  }

  /// Garis putus-putus polos (tanpa notch/lubang di sisi kiri-kanan),
  /// dipakai konsisten di semua pemisah dashed di dalam card ini.
  Widget dashedSeparator({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: customDivideDash(),
    );
  }

  Widget customDivider() {
    return const Column(
      children: [
        SizedBox(height: 8.0),
        Divider(color: Color(0xFFE8E8E8), thickness: 1),
        SizedBox(height: 8.0),
      ],
    );
  }

  Widget customDivideDash() {
    return const Column(
      children: [
        SizedBox(height: 8.0),
        DotDivider(),
        SizedBox(height: 8.0),
      ],
    );
  }

  Widget rowItem(String text1, String text2, {TextStyle? textStyle}) {
    textStyle ??= AppTypography.interRegular14.copyWith(color: onlyGray);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(text1, style: textStyle),
        ),
        Text(text2, style: textStyle),
      ],
    );
  }

  Widget rowItemHeader(String text2, String statusTransaction) {
    String? statuspayment;
    switch (statusTransaction) {
      case 'canceled':
        statuspayment = "Dibatalkan";
        break;
      case 'paid':
        statuspayment = "Dibayar";
        break;
      case 'unpaid':
        statuspayment = "Belum Dibayar";
        break;
      case 'expired':
        statuspayment = "Kedaluwarsa";
        break;
      default:
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        statusTransaction == 'paid'
            ? CustomTextLabeling(
                text: statuspayment ?? "",
                backgroundColor: Colors.white,
                textColor: primaryColor,
                borderColor: primaryColor,
                buttonHeight: 32.0,
                borderRadius: 8.0,
              )
            : CustomTextLabelingError(
                text: statuspayment ?? "",
                backgroundColor: Colors.white,
                buttonHeight: 32.0,
                borderRadius: 8.0,
              ),
        Text(text2,
            style: AppTypography.interSemiBold14.copyWith(color: onlyGray)),
      ],
    );
  }

  Widget rowItemTotal(String text1, String text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text1, style: AppTypography.interSemiBold18),
        Text(text2,
            style: AppTypography.interSemiBold18.copyWith(color: primaryColor)),
      ],
    );
  }

  Widget rowItemFixCost(String text1, String text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text1, style: AppTypography.interSemiBold16),
        Text(text2, style: AppTypography.interSemiBold16),
      ],
    );
  }

  Widget rowItemNote(String text1, String text2) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text1, style: AppTypography.interSemiBold16),
          const SizedBox(
            height: 12,
          ),
          Text(text2,
              style: AppTypography.interRegular14.copyWith(color: onlyGray)),
        ],
      ),
    );
  }

  Widget paddedRowItem(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: child,
    );
  }

  Widget cardInvoice() {
    final invoiceDetail = widget.invoiceDetail;
    final bool hasAdditionalCost = (invoiceDetail?.additionalCost ?? 0) > 0;
    final bool hasNotes = (invoiceDetail?.notes ?? '').trim().isNotEmpty;

    return Column(
      children: [
        //task perlu aksi sekarang
        paddedRowItem(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            rowItemHeader(
                CustomDateFormat.convertToDateFormat(
                    invoiceDetail?.createdAt ?? ''),
                invoiceDetail?.transactionStatus ?? ''),
            if (invoiceDetail?.transactionStatus == 'unpaid' &&
                invoiceDetail?.dueDate != null) ...[
              const SizedBox(height: 8.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: lightWarningColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14.0,
                      color: warningColor,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Jatuh Tempo: ${CustomDateFormat.convertToDateFormatOnlyDate(invoiceDetail?.dueDate ?? '', format: 'dd MMMM yyyy')}',
                      style: AppTypography.interRegular12.copyWith(
                        color: warningColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        )),
        if (invoiceDetail?.transactionStatus == 'paid')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Metode Pembayaran: ${invoiceDetail?.paymentBy == 'kompay' ? 'KomPay' : invoiceDetail?.paymentBy == 'transfer_bank' ? 'Transfer Bank' : invoiceDetail?.paymentBy ?? ''}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

        customDivider(),
        const SizedBox(
          height: 8.0,
        ),
        paddedRowItem(rowItem(
          Strings.label_admin_cost,
          CurrencyFormat.convertToIdr(invoiceDetail?.adminFeeAmount ?? 0, 0),
        )),
        paddedRowItem(rowItem(
            Strings.label_tax_pph23,
            CurrencyFormat.convertToIdrNum(invoiceDetail?.taxAmount ?? 0, 0) ==
                    "Rp0"
                ? CurrencyFormat.convertToIdrNum(
                    invoiceDetail?.taxAmount ?? 0, 0)
                : "-${CurrencyFormat.convertToIdrNum(invoiceDetail?.taxAmount ?? 0, 0)}")),
        paddedRowItem(rowItem(Strings.label_tax_ppn11,
            CurrencyFormat.convertToIdrNum(invoiceDetail?.ppnAmount ?? 0, 0))),
        // Divider ini jadi acuan posisi lubang notch samping, karena
        // persis nempel di atas baris "Sub Total" pertama.
        dashedSeparator(key: _dividerKey),
        paddedRowItem(rowItem(Strings.label_sub_total,
            CurrencyFormat.convertToIdrNum(invoiceDetail?.subTotal1 ?? 0, 0),
            textStyle: AppTypography.interSemiBold16)),
        paddedRowItem(rowItem(
            Strings.label_insentive_talent,
            CurrencyFormat.convertToIdr(
                invoiceDetail?.talentSalaryAmount ?? 0, 0))),
        dashedSeparator(),
        paddedRowItem(rowItem(Strings.label_sub_total,
            CurrencyFormat.convertToIdrNum(invoiceDetail?.subTotal2 ?? 0, 0),
            textStyle: AppTypography.interSemiBold16)),
        paddedRowItem(rowItem(
            Strings.label_aplication_service,
            CurrencyFormat.convertToIdr(
                invoiceDetail?.appsServiceAmount ?? 0, 0))),
        if (hasAdditionalCost)
          paddedRowItem(rowItem(
              Strings.label_additioanal_cost,
              CurrencyFormat.convertToIdr(
                  invoiceDetail?.additionalCost ?? 0, 0))),
        dashedSeparator(),
        paddedRowItem(rowItemTotal(Strings.label_total,
            CurrencyFormat.convertToIdr(invoiceDetail?.amountTotal ?? 0, 0))),
        if (hasNotes) ...[
          dashedSeparator(),
          paddedRowItem(rowItemNote(
            Strings.label_explanation,
            invoiceDetail?.notes ?? "",
          )),
        ],
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget cardInvoiceHidden() {
    final invoiceDetail = widget.invoiceDetail;
    int adminFeeAmount = invoiceDetail?.adminFeeAmount?.toInt() ?? 0;
    int insentifTalent = invoiceDetail?.talentSalaryAmount?.toInt() ?? 0;
    int fixCost = adminFeeAmount + insentifTalent;
    final bool hasAdditionalCost = (invoiceDetail?.additionalCost ?? 0) > 0;
    final bool hasNotes = (invoiceDetail?.notes ?? '').trim().isNotEmpty;

    return Column(
      children: [
        //task perlu aksi sekarang
        paddedRowItem(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            rowItemHeader(
                CustomDateFormat.convertToDateFormat(
                    invoiceDetail?.createdAt ?? ''),
                invoiceDetail?.transactionStatus ?? ''),
            if (invoiceDetail?.transactionStatus == 'unpaid' &&
                invoiceDetail?.expiredAt != null) ...[
              const SizedBox(height: 8.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: lightWarningColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14.0,
                      color: warningColor,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Jatuh Tempo: ${CustomDateFormat.convertToDateFormat(invoiceDetail?.expiredAt ?? '', format: 'dd MMMM yyyy')}',
                      style: AppTypography.interRegular12.copyWith(
                        color: warningColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        )),
        customDivider(),
        const SizedBox(
          height: 8.0,
        ),
        paddedRowItem(rowItemFixCost(
            Strings.label_fix_cost, CurrencyFormat.convertToIdr(fixCost, 0))),
        paddedRowItem(rowItem(
            Strings.label_tax_pph23,
            CurrencyFormat.convertToIdrNum(invoiceDetail?.taxAmount ?? 0, 0) ==
                    "Rp0"
                ? CurrencyFormat.convertToIdrNum(
                    invoiceDetail?.taxAmount ?? 0, 0)
                : "-${CurrencyFormat.convertToIdrNum(invoiceDetail?.taxAmount ?? 0, 0)}")),
        // Padanan divider di atas "Sub Total" pada varian hideCosts ini,
        // dipakai juga sebagai acuan notch biar konsisten sama cardInvoice().
        dashedSeparator(key: _dividerKey),
        paddedRowItem(rowItem(
            Strings.label_aplication_service,
            CurrencyFormat.convertToIdr(
                invoiceDetail?.appsServiceAmount ?? 0, 0))),
        if (hasAdditionalCost)
          paddedRowItem(rowItem(
              Strings.label_additioanal_cost,
              CurrencyFormat.convertToIdr(
                  invoiceDetail?.additionalCost ?? 0, 0))),
        dashedSeparator(),
        paddedRowItem(rowItemTotal(Strings.label_total,
            CurrencyFormat.convertToIdr(invoiceDetail?.amountTotal ?? 0, 0))),
        if (hasNotes) ...[
          dashedSeparator(),
          paddedRowItem(rowItemNote(
            Strings.label_explanation,
            invoiceDetail?.notes ?? "",
          )),
        ],
        const SizedBox(height: 24.0),
      ],
    );
  }
}

/// Clipper untuk bentuk kartu bergaya "tiket": sudut atas rounded biasa,
/// tepi bawah bergerigi (deretan lengkungan dangkal berulang), dan di
/// masing-masing sisi kiri-kanan cuma ada SATU lubang bulat kecil di
/// bagian atas (bukan gerigi berulang). Semua notch benar-benar memotong
/// bentuknya — bukan digambar dengan warna solid — jadi apa pun yang ada
/// di belakang card (foto/gradient di halaman) tembus asli di tiap lubang.
///
/// Jumlah gerigi di tepi bawah otomatis menyesuaikan lebar card
/// (dibulatkan ke jumlah terdekat) supaya rata dari ujung kiri ke kanan.
/// Notch samping posisinya diatur lewat [sideNotchCenterY], yang sekarang
/// diisi dari hasil pengukuran runtime posisi divider di atas "Sub Total"
/// (lihat _CardReportInvoiceState._measureDividerPosition), bukan angka
/// hardcode lagi.
class _TicketNotchClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double scallopWidth;
  final double scallopDepth;
  final double sideNotchRadius;
  final double sideNotchCenterY;

  /// Lebar celah datar (flat) di antara tiap gigi/notch di tepi bawah.
  /// Ini yang bikin tiap gigi keliatan terpisah dengan jarak, bukan
  /// nyambung terus-terusan seperti gelombang tanpa jeda.
  final double scallopGap;

  const _TicketNotchClipper({
    this.cornerRadius = 16.0,
    this.scallopWidth = 40.0,
    this.scallopDepth = 13.0,
    this.sideNotchRadius = 12.0,
    this.sideNotchCenterY = 112.0,
    this.scallopGap = 16.0,
  });

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = cornerRadius;

    // --- Tepi bawah (horizontal), gerigi berulang dengan celah ---
    int countH = (w / scallopWidth).round();
    if (countH < 1) countH = 1;
    final double segmentH = w / countH;

    // Tiap segmen dibagi: celah datar (gap) + gigi (bite). Gap-nya
    // dibagi dua, ditaruh di kiri-kanan gigi supaya gigi ada di tengah
    // tiap segmen dan jaraknya rata dari ujung ke ujung.
    final double gap = scallopGap.clamp(0.0, segmentH - 4.0);
    final double biteWidth = segmentH - gap;
    final double halfGap = gap / 2;

    // Formula sagitta: radius lingkaran yang menghasilkan lengkungan
    // sedalam `scallopDepth` untuk chord selebar `biteWidth` (bukan
    // lebar segmen penuh lagi, karena sekarang ada gap di kiri-kanannya).
    final double radiusH =
        (scallopDepth / 2) + ((biteWidth * biteWidth) / (8 * scallopDepth));

    // --- Sisi kiri & kanan: satu lubang bulat kecil ---
    // Jaga posisinya tetap di dalam batas aman: nggak nabrak lengkungan
    // sudut atas, dan nggak nabrak gerigi di tepi bawah.
    double notchTop = sideNotchCenterY - sideNotchRadius;
    double notchBottom = sideNotchCenterY + sideNotchRadius;
    final double safeTop = r;
    final double safeBottom = h - scallopDepth - 4.0;
    if (notchTop < safeTop) {
      final double shift = safeTop - notchTop;
      notchTop += shift;
      notchBottom += shift;
    }
    if (notchBottom > safeBottom) {
      final double shift = notchBottom - safeBottom;
      notchTop -= shift;
      notchBottom -= shift;
    }

    final Path path = Path()
      ..moveTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
      // Sisi kanan: lurus dulu sampai atas lubang
      ..lineTo(w, notchTop)
      // satu lubang bulat, menggigit ke kiri (masuk ke dalam card)
      ..arcToPoint(
        Offset(w, notchBottom),
        radius: Radius.circular(sideNotchRadius),
        clockwise: false,
      )
      // lanjut lurus sampai tepi bawah
      ..lineTo(w, h);

    // Tepi bawah: gerigi dari kanan ke kiri, tiap gigi diapit celah
    // datar di kiri-kanannya (lineTo) sebelum lengkungannya (arcToPoint).
    double x = w;
    for (int i = 0; i < countH; i++) {
      final double biteStartX = x - halfGap;
      path.lineTo(biteStartX, h); // celah datar sebelum gigi

      final double biteEndX = biteStartX - biteWidth;
      path.arcToPoint(
        Offset(biteEndX, h),
        radius: Radius.circular(radiusH),
        clockwise: false, // lengkung ke dalam (menggigit ke atas card)
      );

      final double nextX = biteEndX - halfGap;
      path.lineTo(nextX, h); // celah datar sesudah gigi
      x = nextX;
    }

    // Sisi kiri: lurus naik sampai bawah lubang
    path
      ..lineTo(0, notchBottom)
      // satu lubang bulat, menggigit ke kanan (masuk ke dalam card)
      ..arcToPoint(
        Offset(0, notchTop),
        radius: Radius.circular(sideNotchRadius),
        clockwise: false,
      )
      ..lineTo(0, r);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _TicketNotchClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.scallopWidth != scallopWidth ||
        oldClipper.scallopDepth != scallopDepth ||
        oldClipper.sideNotchRadius != sideNotchRadius ||
        oldClipper.sideNotchCenterY != sideNotchCenterY ||
        oldClipper.scallopGap != scallopGap;
  }
}
