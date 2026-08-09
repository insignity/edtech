import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:flutter/material.dart';

@RoutePage()
class NavBarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [CoursesRoute(), SpeakingHistoryRoute(), ProfileRoute()],
      homeIndex: 0,
      builder: (context, child) {
        final tabsRouter = context.tabsRouter;
        return Scaffold(
          body: child,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: BottomNavigationBar(
              currentIndex: tabsRouter.activeIndex,
              onTap: (i) => tabsRouter.setActiveIndex(i),
              items: const [
                BottomNavigationBarItem(
                  label: 'Courses',
                  icon: Icon(Icons.laptop_chromebook_outlined),
                  activeIcon: Icon(Icons.laptop_chromebook),
                ),
                BottomNavigationBarItem(
                  label: 'History',
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history_rounded),
                ),
                BottomNavigationBarItem(
                  label: 'Profile',
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
