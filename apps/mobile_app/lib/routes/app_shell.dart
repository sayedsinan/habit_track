import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/features/chat/chat_page.dart';
import 'package:habit_builder/features/home/home_page.dart';
import 'package:habit_builder/features/newHabit/new_habit.dart';
import 'package:habit_builder/features/stats/stat_screen.dart';
import 'package:habit_builder/features/profile/profile_page.dart';

// ─────────────────────────────────────────────
// DATA MODEL: NavItem
// ─────────────────────────────────────────────

class NavItem {
  final IconData icon;
  final String label;
  final Widget page;

  const NavItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: MainNavBar
// ─────────────────────────────────────────────

class MainNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  const MainNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();

    return Container(
      decoration: BoxDecoration(
        color: color.navBarColor,
        border: Border(
          top: BorderSide(color: color.accentColor, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.accentColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              return _NavBarItem(
                item: items[i],
                isSelected: i == selectedIndex,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(i);
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRIVATE COMPONENT: _NavBarItem
// ─────────────────────────────────────────────

class _NavBarItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Icon(
                item.icon,
                size: 24,
                color: isSelected
                    ? color.primaryTextColor
                    : color.subtitleColor,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? color.primaryTextColor
                    : color.subtitleColor,
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0.3,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN SHELL: AppShell
// ─────────────────────────────────────────────

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  late final List<NavItem> _navItems;

  // Maps nav index → IndexedStack index
  // Add tab (2) is a modal — never stored in stack
  // Stack layout: 0=Today, 1=Stats, 2=AI, 3=Profile
  int get _stackIndex {
    if (_currentIndex == 0) return 0;
    if (_currentIndex == 1) return 1;
    if (_currentIndex == 3) return 2;
    if (_currentIndex == 4) return 3;
    return 0; // fallback
  }

  @override
  void initState() {
    super.initState();
    _navItems = const [
      NavItem(
        icon: Icons.calendar_today_outlined,
        label: 'Today',
        page: HomePage(),
      ),
      NavItem(
        icon: Icons.bar_chart_outlined,
        label: 'Stats',
        page: StatScreen(),
      ),
      NavItem(
        icon: Icons.add_circle_outlined,
        label: 'Add',
        page: NewHabitPage(),
      ),
      NavItem(
        icon: Icons.smart_toy_outlined,
        label: 'AI',
        page: AiCoachPage(),
      ),
      const NavItem(
        icon: Icons.person_outline,
        label: 'Profile',
        page: ProfilePage(),
      ),
    ];
  }

  void _onNavTap(int index) {
    if (index == 2) {
      _showAddHabitSheet();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _showAddHabitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
          child: const NewHabitPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();

    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: IndexedStack(
        index: _stackIndex,
        children: [
          _navItems[0].page, // Today  → stack index 0
          _navItems[1].page, // Stats  → stack index 1
          _navItems[3].page, // AI     → stack index 2
          _navItems[4].page, // Profile→ stack index 3
        ],
      ),
      bottomNavigationBar: MainNavBar(
        selectedIndex: _currentIndex,
        onTap: _onNavTap,
        items: _navItems,
      ),
    );
  }
}