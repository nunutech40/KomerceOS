import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/features/superapp/features/setting/view/setting_page.dart';
import 'package:provider/provider.dart';

import 'home_page_superapp.dart';

class NavItem {
  final Widget activeIcon;
  final Widget inactiveIcon;
  final String title;
  final Widget page;

  const NavItem(this.activeIcon, this.inactiveIcon, this.title, this.page);
}

class NavigationData extends ChangeNotifier {
  int _currentIndex = 0;
  final List<NavItem> _items = [
    NavItem(
      Image.asset('assets/images/superapp/home/navbar/ic_home_active.png'),
      Image.asset('assets/images/superapp/home/navbar/ic_home_inactive.png'),
      "Home",
      const HomePageSuperapp(),
    ),
    NavItem(
      Image.asset('assets/images/superapp/home/navbar/ic_finance_inactive.png'),
      Image.asset('assets/images/superapp/home/navbar/ic_finance_inactive.png'),
      "Mutasi",
      const MutasiPage(),
    ),
    NavItem(
      Image.asset('assets/images/superapp/home/navbar/ic_setting_active.png'),
      Image.asset('assets/images/superapp/home/navbar/ic_setting_inactive.png'),
      "Pengaturan",
      const SettingPage(),
    ),
    // const NavItem(
    //   Icon(Icons.grid_view_rounded),
    //   Icon(Icons.grid_view_outlined),
    //   "Shortcut",
    //   ShortcutPage(),
    // ),
  ];

  int get currentIndex => _currentIndex;
  List<NavItem> get items => _items;

  void updateIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}

class MainPageSuperApp extends StatefulWidget {
  const MainPageSuperApp({super.key});

  @override
  State<MainPageSuperApp> createState() => _MainPageStateSuperApp();
}

class _MainPageStateSuperApp extends State<MainPageSuperApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NavigationData>(
      create: (_) => NavigationData(),
      child: Consumer<NavigationData>(
        builder: (context, nav, child) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: Stack(
              children: [
                // Body content
                IndexedStack(
                  index: nav.currentIndex,
                  children: nav.items.map((item) => item.page).toList(),
                ),
                // Floating navbar overlay (transparent background)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: SizedBox(
                        height: 72,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: .08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children:
                                      List.generate(nav.items.length, (index) {
                                    final item = nav.items[index];
                                    final isSelected =
                                        nav.currentIndex == index;
                                    return Expanded(
                                      child: NavButton(
                                        icon: isSelected
                                            ? item.activeIcon
                                            : item.inactiveIcon,
                                        title: item.title,
                                        selected: isSelected,
                                        onTap: () => nav.updateIndex(index),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: FloatingActionButton(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                onPressed: () {},
                                shape: const CircleBorder(),
                                child: Image.asset(
                                    'assets/images/superapp/home/ic_live_chat.png'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PageTransitionSwitcher extends StatelessWidget {
  final int currentIndex;
  final Widget child;

  const PageTransitionSwitcher({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.fastOutSlowIn,
      switchOutCurve: Curves.fastOutSlowIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(currentIndex),
        child: child,
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Halaman Utama"));
}

class MutasiPage extends StatelessWidget {
  const MutasiPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Icons.currency_exchange, color: Colors.orange),
          title: Text("Transaksi #$index"),
          subtitle: const Text("Rp 100.000"),
        ),
      ),
    );
  }
}

class ShortcutPage extends StatelessWidget {
  const ShortcutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      children: List.generate(
          4, (index) => const Card(child: Icon(Icons.shortcut, size: 40))),
    );
  }
}

class NavButton extends StatelessWidget {
  final Widget icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const NavButton({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryBase : AppColors.textDark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(
                milliseconds: 300), // Dibuat sedikit lebih natural
            curve: Curves
                .fastOutSlowIn, // Curve yang lebih mengalir dari easeOutCubic
            margin: const EdgeInsets.symmetric(horizontal: 8),
            height: 56.0,
            decoration: BoxDecoration(
              // FIX: Gunakan warna target dengan opacity 0 alih-alih Colors.transparent (hitam)
              color: selected
                  ? const Color(0xFFFFF0E6)
                  : const Color(0xFFFFF0E6).withValues(alpha: 0.0),
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: icon,
              ),
              const SizedBox(height: 2),
              // FIX: Menggunakan AnimatedDefaultTextStyle agar transisi normal -> bold tidak "melompat"
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(title),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
