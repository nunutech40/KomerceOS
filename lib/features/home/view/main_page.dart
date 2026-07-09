import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/features/home/view/profile_page.dart';
import 'package:komtim_partner/features/kompay/bloc/topup_bloc.dart';
import '../bloc/history_page_bloc.dart';
import '../bloc/home_page_bloc.dart';
import '../bloc/profile_page_bloc.dart';

import 'package:komtim_partner/DI/injection.dart' as di;
import 'history_page.dart';
import 'home_page.dart';

class MainPage extends StatefulWidget {
  final int? withdarwal;
  const MainPage({Key? key, this.withdarwal}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _bottomNavIndex = 0;
  static const String _headlineText = 'Beranda';

  late HomePageBloc _homePageBloc;
  late TopUpBloc _TopUpBloc;
  late HistoryPageBloc _historyPageBloc;
  late ProfilePageBloc _profilePageBloc;

  @override
  void initState() {
    super.initState();

    _homePageBloc = di.locator<HomePageBloc>();
    _TopUpBloc = di.locator<TopUpBloc>();
    _historyPageBloc = di.locator<HistoryPageBloc>();
    _profilePageBloc = di.locator<ProfilePageBloc>();
    _fromWithdawal(widget.withdarwal);
  }

  @override
  void dispose() {
    _homePageBloc.close();
    _TopUpBloc.close();
    _historyPageBloc.close();
    _profilePageBloc.close();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });
  }

  void _fromWithdawal(int? a) {
    if (a == 1) {
      _bottomNavIndex = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_bottomNavIndex != 0) {
          setState(() {
            _bottomNavIndex = 0;
          });
          return false;
        } else {
          SystemNavigator.pop();
          return true;
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _bottomNavIndex,
          children: [
            BlocProvider<HomePageBloc>(
              create: (context) => _homePageBloc,
              child: const HomePage(),
            ),
            BlocProvider<HistoryPageBloc>(
              create: (context) => _historyPageBloc,
              child: const HistoryPage(),
            ),
            BlocProvider<ProfilePageBloc>(
              create: (context) => _profilePageBloc,
              child: const ProfilePage(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: primaryColor,
          currentIndex: _bottomNavIndex,
          items: [
            BottomNavigationBarItem(
              icon: _bottomNavIndex == 0
                  ? SvgPicture.asset('assets/images/ic_home_active.svg')
                  : SvgPicture.asset('assets/images/ic_home-inactive.svg'),
              label: _headlineText,
            ),
            BottomNavigationBarItem(
              icon: _bottomNavIndex == 1
                  ? SvgPicture.asset('assets/images/ic_archive-book-active.svg')
                  : SvgPicture.asset('assets/images/ic_archive-book_inactive.svg'),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: _bottomNavIndex == 2
                  ? SvgPicture.asset('assets/images/ic_profile-circle-active.svg')
                  : SvgPicture.asset('assets/images/ic_profile-circle-inactive.svg'),
              label: 'Profile',
            ),
          ],
          onTap: _onBottomNavTapped,
        ),
      ),
    );
  }
}
