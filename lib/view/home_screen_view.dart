import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/view/critical_agenda_section.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/today_and_upcoming_hearing_view_model.dart';

import '../utils/routes/routes_names.dart';
import '../utils/snakebars_and_popUps/snake_bars.dart';
import '../view_model/services/notification_history_view_model.dart';
import 'cases_screen_view/case_create_screen.dart';
import 'drawer_view.dart';
import 'notification_history_screen_view.dart';

// ─────────────────────────────────────────────
// RightCase Design Tokens
// ─────────────────────────────────────────────
class _RC {
  // Primary palette
  static const navy = Color(0xFF1A2744);
  static const navyLight = Color(0xFF243356);
  static const gold = Color(0xFFC8952A);
  static const goldLight = Color(0xFFFAEDD4);

  // Surface & background
  static const background = Color(0xFFF7F5F1);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF0EEE9);

  // Text
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textOnDark = Color(0xFFFFFFFF);
  static const textOnDarkMuted = Color(0xFFB8C4D8);

  // Semantic
  static const danger = Color(0xFFB91C1C);
  static const dangerSurface = Color(0xFFFEF2F2);
  static const dangerBorder = Color(0xFFFECACA);

  static const warning = Color(0xFF92400E);
  static const warningSurface = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);

  static const success = Color(0xFF166534);
  static const successSurface = Color(0xFFF0FDF4);

  // Divider
  static const divider = Color(0xFFE5E1D8);

  // Shadow
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 3),
      );

  static BoxShadow get subtleShadow => BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 6,
        offset: const Offset(0, 2),
      );
}

// ─────────────────────────────────────────────
// Home Screen
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        context.read<NotificationHistoryViewModel>().fetchInboxNotification();
        context.read<AgendaViewModel>().loadAgenda();
      }
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _todayLabel() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final day = days[now.weekday - 1];
    return '$day, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RC.background,
      drawer: DrawerView(),
      // ── AppBar ─────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _RC.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: _RC.textOnDark),
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              'RightCase',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: _RC.textOnDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _RC.gold,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'LAW',
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w700,
                  color: _RC.textOnDark,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Consumer<NotificationHistoryViewModel>(
            builder: (context, vm, _) {
              final count = vm.unreadCount;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Badge(
                  badgeContent: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 9),
                  ),
                  showBadge: count > 0,
                  badgeStyle: BadgeStyle(
                    badgeColor: _RC.gold,
                  ),
                  position: BadgePosition.custom(end: 4, top: 6),
                  child: IconButton(
                    icon: Icon(
                      count > 0
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_none_outlined,
                      color: count > 0 ? _RC.gold : _RC.textOnDarkMuted,
                      size: 22,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const NotificationHistoryScreenView()),
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.account_circle_outlined,
                  color: _RC.textOnDarkMuted, size: 24),
              onPressed: () {},
            ),
          ),
        ],
      ),

      // ── Bottom nav ─────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _RC.navy,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, -3),
            )
          ],
        ),
        padding: EdgeInsets.only(
          top: 12.h,
          left: 8.w,
          right: 8.w,
          bottom: MediaQuery.of(context).padding.bottom + 10.h,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BottomNavButton(
              label: 'Add Client',
              icon: Icons.person_add_outlined,
              onTap: () =>
                  Navigator.pushNamed(context, RoutesName.addClientScreen),
            ),
            _BottomNavButton(
              label: 'Add Case',
              icon: Icons.cases_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CaseCreateScreen()),
              ),
            ),
            _BottomNavButton(
              label: 'Add Task',
              icon: Icons.playlist_add_check_outlined,
              onTap: () {
                SnakeBars.scaffoldMessenger(
                  "This hearing record has been deleted or removed",
                  context,
                );
              },
              isPrimary: true, // Gold accent for the primary CTA
            ),
          ],
        ),
      ),

      // ── Body ───────────────────────────────────────────────────
      body: RefreshIndicator(
        color: _RC.navy,
        onRefresh: () => context.read<AgendaViewModel>().refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Greeting header ──────────────────────────────────
            SliverToBoxAdapter(
              child: _GreetingHeader(
                greeting: _greeting(),
                dateLabel: _todayLabel(),
              ),
            ),

            // ── Quick Actions ────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              sliver: SliverToBoxAdapter(
                child: _QuickActionsRow(),
              ),
            ),

            // ── Critical Agenda ──────────────────────────────────
            SliverPadding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 4.h),
              sliver: SliverToBoxAdapter(
                child: Consumer<AgendaViewModel>(
                  builder: (context, agendaVM, _) {
                    return _AgendaBody(viewModel: agendaVM);
                  },
                ),
              ),
            ),

            // Bottom breathing room
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Greeting header — navy band with date + name
// ─────────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  final String greeting;
  final String dateLabel;

  const _GreetingHeader({
    required this.greeting,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _RC.navy,
      padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: _RC.textOnDark,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 12, color: _RC.textOnDarkMuted),
              const SizedBox(width: 5),
              Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _RC.textOnDarkMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quick Actions row
// ─────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _RC.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QuickActionTile(
              label: 'Clients',
              icon: Icons.group_outlined,
              onTap: () =>
                  Navigator.pushNamed(context, RoutesName.clientsScreen),
            ),
            _QuickActionTile(
              label: 'Cases',
              icon: Icons.cases_outlined,
              onTap: () =>
                  Navigator.pushNamed(context, RoutesName.casesListScreen),
            ),
            _QuickActionTile(
              label: 'Calendar',
              icon: Icons.calendar_month_outlined,
              onTap: () =>
                  Navigator.pushNamed(context, RoutesName.calendarScreen),
            ),
            _QuickActionTile(
              label: 'Court',
              icon: Icons.balance_outlined,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: (MediaQuery.of(context).size.width - 32.w - 36.w) / 4,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: _RC.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [_RC.subtleShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _RC.navy.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 20.sp, color: _RC.navy),
            ),
            SizedBox(height: 7.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: _RC.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Agenda body — handles loading / empty / content
// ─────────────────────────────────────────────
class _AgendaBody extends StatelessWidget {
  final AgendaViewModel viewModel;
  const _AgendaBody({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label row
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: _RC.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'DEADLINES',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _RC.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        CriticalAgendaSection(viewModel: viewModel),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Bottom nav button
// ─────────────────────────────────────────────
class _BottomNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _BottomNavButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: isPrimary
            ? BoxDecoration(
                color: _RC.gold,
                borderRadius: BorderRadius.circular(10.r),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22.sp,
              color: isPrimary ? _RC.textOnDark : _RC.textOnDarkMuted,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: isPrimary ? _RC.textOnDark : _RC.textOnDarkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quick Action Button (kept for backward compat)
// ─────────────────────────────────────────────
class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25.r),
          child: Material(
            elevation: 3,
            shape: const CircleBorder(),
            child: CircleAvatar(
              radius: 24.r,
              backgroundColor: _RC.surface,
              child: Icon(icon, size: 20.sp, color: _RC.navy),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: _RC.textOnDarkMuted,
          ),
        ),
      ],
    );
  }
}

/// we are going to work on the TODAY'S DOCKET and Deadlines because the deadlines must have the case that are
/// upcoming within 7 days or whatever
