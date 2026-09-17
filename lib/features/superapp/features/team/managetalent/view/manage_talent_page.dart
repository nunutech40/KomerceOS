import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_app_bar.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/features/superapp/features/team/managetalent/view/detail_request.dart';
import 'package:komtim_partner/features/superapp/features/team/managetalent/widget/build_talent_card.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageTalentPage extends StatefulWidget {
  const ManageTalentPage({super.key});

  @override
  State<ManageTalentPage> createState() => _ManageTalentPageState();
}

class _ManageTalentPageState extends State<ManageTalentPage> {
  bool _showNoticeBanner = true;
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedFilterRoles = [];

  final List<Map<String, dynamic>> _dummyTalents = [
    {
      "name": "Lindsey Kilback",
      "role": "Customer Service",
      "id": "123432DSD",
      "initials": "AB",
      "lead": "Budi",
      "duration": "1 tahun 2 bulan",
      "hasRequest": true,
      "requestDetails": {
        "type": "Penghentian Kontrak / Pergantian Talent",
        "date": "20 Juli 2026",
        "status": "Menunggu Konfirmasi BD",
        "reason": "Performa tidak mencapai target KPI kuartal kedua",
        "proposedReplacement": "Customer Service Senior"
      }
    },
    {
      "name": "Anisa Rahmawati",
      "role": "Advertiser",
      "id": "123432DSD",
      "initials": "AR",
      "lead": "Budi",
      "duration": "1 tahun 2 bulan",
      "hasRequest": false,
      "requestDetails": null
    },
    {
      "name": "Sarah Connor",
      "role": "Live Streamer",
      "id": "987654XYZ",
      "initials": "SC",
      "lead": "Joni",
      "duration": "6 bulan",
      "hasRequest": false,
      "requestDetails": null
    },
    {
      "name": "Rian Adi",
      "role": "Admin Marketplace",
      "id": "456789ABC",
      "initials": "RA",
      "lead": "Dewi",
      "duration": "2 tahun",
      "hasRequest": true,
      "requestDetails": {
        "type": "Penyesuaian Jam Kerja (Shift Malam)",
        "date": "18 Juli 2026",
        "status": "Sedang Diproses BD",
        "reason":
            "Kebutuhan operasional toko online 24 jam untuk memaksimalkan penjualan",
        "proposedReplacement": "-"
      }
    },
  ];

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text.toLowerCase();
    final filteredTalents = _dummyTalents.where((talent) {
      final name = talent["name"].toString().toLowerCase();
      final role = talent["role"].toString().toLowerCase();
      final id = talent["id"].toString().toLowerCase();
      final matchesSearch = name.contains(searchQuery) ||
          role.contains(searchQuery) ||
          id.contains(searchQuery);
      final matchesRole = _selectedFilterRoles.isEmpty ||
          _selectedFilterRoles.contains(talent["role"]);
      return matchesSearch && matchesRole;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const DsAppBar(title: 'Kelola Team'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showNoticeBanner) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildNoticeBox(),
              ),
            ],
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Daftar Talent Aktif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Lihat daftar talent yang sedang aktif beserta informasi penugasannya dalam satu tempat.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF737373),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchSection(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredTalents.isEmpty
                  ? const Center(
                      child: Text(
                        "Tidak ada talent yang sesuai",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredTalents.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final talent = filteredTalents[index];
                        return BuildTalentCard(
                          talentName: talent["name"],
                          talentRole: talent["role"],
                          talentId: talent["id"],
                          avatarInitials: talent["initials"],
                          talentLead: talent["lead"],
                          workingDuration: talent["duration"],
                          hasPendingRequest: talent["hasRequest"],
                          onViewRequest: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DetailRequestPage(),
                              ),
                            );
                          },
                          onApplyChange: () {
                            whatsapp('083863613527');
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> whatsapp(String contact) async {
    String processedContact;
    if (contact.startsWith('0')) {
      processedContact = '62${contact.substring(1)}';
    } else if (contact.startsWith('+62')) {
      processedContact = contact.replaceFirst('+', '');
    } else {
      processedContact = contact;
    }

    final androidUrl = "https://wa.me/$processedContact";
    final iosUrl = "https://wa.me/$contact";

    try {
      if (Platform.isIOS) {
        await _launchUrl(Uri.parse(iosUrl));
      } else {
        await _launchUrl(Uri.parse(androidUrl));
      }
    } catch (e) {
      // Handle the exception here. Maybe show a snackbar or logger.
      // print("Failed to open WhatsApp: $e");
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    List<String> tempSelectedRoles = List.from(_selectedFilterRoles);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final roles = [
              "Customer Service",
              "Admin Marketplace",
              "Advertiser",
              "Live Streamer"
            ];

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC2C2C2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Filter",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...roles.map((role) {
                    final isChecked = tempSelectedRoles.contains(role);
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          if (isChecked) {
                            tempSelectedRoles.remove(role);
                          } else {
                            tempSelectedRoles.add(role);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: isChecked,
                                activeColor: primaryColor,
                                checkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFE2E2E2),
                                  width: 1.5,
                                ),
                                onChanged: (bool? value) {
                                  setModalState(() {
                                    if (value == true) {
                                      tempSelectedRoles.add(role);
                                    } else {
                                      tempSelectedRoles.remove(role);
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              role,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(
                                color: primaryColor, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilterRoles = tempSelectedRoles;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Terapkan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return Row(
      children: [
        Expanded(
          child: _buildSearchField(),
        ),
        const SizedBox(width: 10),
        _buildFilterButton(),
      ],
    );
  }

  Widget _buildFilterButton() {
    return InkWell(
      onTap: () {
        _showFilterBottomSheet(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE7E7E7),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
              'assets/images/superapp/team/ic_filter_diamond.svg'),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {});
        },
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          hintText: "Cari talent",
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          hintStyle: const TextStyle(
            fontSize: 16,
            color: Color(0xFF575757),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              'assets/images/superapp/team/ic_search_talent.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Color(0xFF828282),
                BlendMode.srcIn,
              ),
            ),
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF0A0A0A),
        ),
      ),
    );
  }

  Widget _buildNoticeBox() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => whatsapp('083865360055'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4ED),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFF4ED), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/images/info-circle.svg',
                  colorFilter: const ColorFilter.mode(
                    primaryColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Butuh talent tambahan?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hubungi BD untuk penambahan talent baru.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3E4A3C),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _showNoticeBanner = false;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.close_outlined,
                      size: 20, color: Color(0xFF0A0A0A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
