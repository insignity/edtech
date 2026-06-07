import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:flutter/material.dart';

@RoutePage()
class NavBarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabsRouter = context.tabsRouter;

    return AutoTabsRouter(
      routes: const [CoursesRoute(), MyCoursesRoute(), ProfileRoute()],
      homeIndex: 0,
      builder: (context, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: (i) => onSelectTab(i, tabsRouter, context),
            items: [
              BottomNavigationBarItem(
                label: 'Courses',
                icon: Icon(Icons.laptop_chromebook),
              ),
              BottomNavigationBarItem(
                label: 'My courses',
                icon: Icon(Icons.star_border),
              ),
              BottomNavigationBarItem(
                label: 'Profile',
                icon: Icon(Icons.person),
              ),
            ],
          ),
        );
      },
    );
  }

  void onSelectTab(int index, TabsRouter? tabsRouter, BuildContext context) {
    tabsRouter?.setActiveIndex(index);
  }
}
