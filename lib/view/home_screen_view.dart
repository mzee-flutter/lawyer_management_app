import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/view/critical_agenda_section.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/today_and_upcoming_hearing_view_model.dart';

import '../utils/routes/routes_names.dart';
import '../view_model/services/notification_history_view_model.dart';
import 'cases_screen_view/case_create_screen.dart';
import 'drawer_view.dart';
import 'notification_history_screen_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final int num10 = 10;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerView(),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: Text(
          'RightCase',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<NotificationHistoryViewModel>(
            builder: (context, notificationHistoryVM, child) {
              final count = notificationHistoryVM.unreadCount;
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Badge(
                  badgeContent: Text(
                    count > 9 ? "9+" : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  showBadge: count > 0,
                  position: count > 9
                      ? BadgePosition.custom(end: 1, top: 6)
                      : BadgePosition.custom(end: 5, top: 7),
                  child: IconButton(
                    icon: Icon(
                      count > 0
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_none_outlined,
                      color: Colors.grey.shade800,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationHistoryScreenView(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          top: 12.h,
          right: 24.w,
          bottom: MediaQuery.of(context).padding.bottom +
              8.h, // Handles notch devices seamlessly
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickActionButton(
              label: 'Add Client',
              icon: Icons.person_add,
              onTap: () {
                Navigator.pushNamed(context, RoutesName.addClientScreen);
              },
            ),
            _QuickActionButton(
              label: 'Add Case',
              icon: Icons.cases_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CaseCreateScreen()),
                );
              },
            ),
            _QuickActionButton(
              label: 'Add Task',
              icon: Icons.playlist_add_check,
              onTap: () {},
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AgendaViewModel>().refresh(),
        child: CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works even when the list is small
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 95.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _QuickActionButton(
                            label: 'Clients',
                            icon: Icons.group,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RoutesName.clientsScreen);
                            },
                          ),
                          _QuickActionButton(
                            label: 'Cases',
                            icon: Icons.cases_rounded,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RoutesName.casesListScreen);
                            },
                          ),
                          _QuickActionButton(
                            label: 'Calender',
                            icon: Icons.calendar_month_rounded,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RoutesName.calendarScreen);
                            },
                          ),
                          _QuickActionButton(
                            label: 'Court',
                            icon: Icons.balance_rounded,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Critical Agenda",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              sliver: SliverToBoxAdapter(
                child: Consumer<AgendaViewModel>(
                  builder: (context, agendaVM, child) {
                    return CriticalAgendaSection(
                      viewModel: agendaVM,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      mainAxisSize:
          MainAxisSize.min, // Prevents vertical cell stretching inside rows
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(25.r), // Bounds visual feedback ring splash
          child: Material(
            elevation: 4,
            shape: const CircleBorder(),
            child: CircleAvatar(
              radius: 24.r,
              backgroundColor: Colors.white,
              child: Icon(icon, size: 22.sp, color: Colors.grey.shade800),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
