import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/custom_cases_category_view.dart';
import 'package:right_case/utils/routes/routes_names.dart';

import 'package:right_case/view/cases_screen_view/add_case_screen_view.dart';
import 'package:right_case/view_model/cases_view_model/case_view_model.dart';
import 'drawer_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerView(),
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade300,
        title: Text('LexTrack',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 200.h),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Actions',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5.h),
                  Container(
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
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
                          icon: Icons.gavel_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text("Cases Schedule",
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10.h),
                  _buildSummaryCards(context),
                  SizedBox(height: 20.h),
                  SizedBox(height: 10.h),
                  // _buildScheduleList(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickActionButton(
                    label: 'Add Case',
                    icon: Icons.cases_rounded,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AddCaseScreen()));
                    },
                  ),
                  _QuickActionButton(
                    label: 'Add Client',
                    icon: Icons.person_add,
                    onTap: () {
                      Navigator.pushNamed(context, RoutesName.addClientScreen);
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
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(context) {
    return Consumer<CaseViewModel>(
      builder: (context, caseVM, child) {
        return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _DashboardCard(
              title: "Today's Cases",
              icon: Icons.today_rounded,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CustomCasesCategoryView(
                            title: 'Today Cases', cases: caseVM.todayCases)));
              },
            ),
            _DashboardCard(
              title: "Tomorrow's Cases",
              icon: Icons.event_available_rounded,
              onTap: () {},
            ),
            _DashboardCard(
              title: "Running Cases",
              icon: Icons.hourglass_top_rounded,
              onTap: () {},
            ),
            _DashboardCard(
              title: 'Decided Cases',
              icon: Icons.check_circle_outline_rounded,
              onTap: () {},
            ),
            _DashboardCard(
              title: 'Date Awaited Cases',
              icon: Icons.cases_rounded,
              onTap: () {},
            ),
            _DashboardCard(
              title: 'Abandoned Cases',
              icon: Icons.block_rounded,
              onTap: () {},
            ),
          ],
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.grey.shade300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.grey.shade800,
            ),
            SizedBox(height: 5.h),
            Text(
              textAlign: TextAlign.center,
              title,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onTap,
          child: Material(
            elevation: 4,
            shape: const CircleBorder(),
            child: CircleAvatar(
              radius: 25.r,
              backgroundColor: Colors.white,
              child: Icon(icon, size: 24.sp, color: Colors.grey.shade800),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(label, style: TextStyle(fontSize: 12.sp))
      ],
    );
  }
}
