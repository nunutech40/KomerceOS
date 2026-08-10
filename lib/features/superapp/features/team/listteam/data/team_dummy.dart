import '../model/team_member_model.dart';

/// Hak akses default yang muncul di sebagian besar kartu pada desain.
const List<String> _kDefaultAccess = [
  'DASHBOARD',
  'PRODUK',
  'GUDANG',
  'ORDER',
  'PICKUP',
  'KEUANGAN',
  'PENGATURAN',
  'KENDALA',
];

/// Dummy data sementara untuk tab "Internal" sebelum endpoint tersedia.
/// Ganti dengan data dari bloc/repository saat integrasi.
const List<TeamMemberModel> kDummyInternalTeam = [
  TeamMemberModel(
    name: 'Gita Akses Web',
    email: 'gita@gmail.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=47',
    role: 'Talent Acquisition',
    isVerified: true,
    accessList: _kDefaultAccess,
  ),
  TeamMemberModel(
    name: 'Tata Akses Mobile',
    email: 'tata@gmail.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    isVerified: true,
    accessList: _kDefaultAccess,
  ),
  TeamMemberModel(
    name: 'Khayla',
    email: 'khayla@gmail.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=45',
    role: 'Talent Acquisition',
    accessList: _kDefaultAccess,
  ),
  TeamMemberModel(
    name: 'Josh Sauer',
    email: 'Josh.Sauer@yahoo.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=13',
    role: 'UIUX Designer',
    isVerified: true,
    accessList: _kDefaultAccess,
  ),
  TeamMemberModel(
    name: 'Alberta Smith',
    email: 'Alberta.Smith78@gmail.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    role: 'Product Manager',
    isVerified: true,
    accessList: _kDefaultAccess,
  ),
  TeamMemberModel(
    name: 'Franklin Kris',
    email: 'Franklin96@yahoo.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=33',
    role: 'IT Product Manager',
    isVerified: true,
    accessList: _kDefaultAccess,
  ),
];

/// Dummy data sementara untuk tab "Talent Komtim".
const List<TeamMemberModel> kDummyTalentTeam = [
  TeamMemberModel(
    name: 'Betsy Luellwitz',
    email: 'Betsy_Luellwitz@hotmail.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=32',
    role: 'Customer Service',
    isVerified: true,
    accessList: _kDefaultAccess,
  ),
  TeamMemberModel(
    name: 'Terence Dare',
    email: 'Terence_Dare50@hotmail.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=15',
    isVerified: true,
    accessList: _kDefaultAccess,
  ),
  TeamMemberModel(
    name: 'Alicia Bernier',
    email: 'Alicia81@yahoo.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=16',
    role: 'Admin Marketplace',
    isVerified: true,
    accessList: _kDefaultAccess,
  ),
  TeamMemberModel(
    name: 'Blake Watsica',
    email: 'Blake.Watsica72@yahoo.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=52',
    role: 'Advertiser',
    isVerified: true,
    accessList: _kDefaultAccess,
  ),
  TeamMemberModel(
    name: 'Vicki Hayes',
    email: 'Vicki_Hayes55@hotmail.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=68',
    role: 'Live Streamer',
    isVerified: true,
    accessList: _kDefaultAccess,
  ),
];
