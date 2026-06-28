import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_strings.dart';
import 'core/routing/app_router.dart';
import 'core/services/navigation_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';

/// Design canvas — iPhone 11 portrait. Change once here if your design
/// is on a different frame.
const Size kDesignSize = Size(375, 812);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: kDesignSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // Lock to light mode — there's no proper dark variant yet, and
        // dark-mode TextField defaults bleed into our cream surfaces.
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          theme: AppTheme.light,
          darkTheme: AppTheme.light, // mirror, not dark
          themeMode: ThemeMode.light,
          onGenerateRoute: AppRouter.onGenerateRoute,
          // Dark status-bar icons on every route (our backgrounds are light).
          // Screens that need light icons (e.g. splash) wrap themselves in
          // their own AnnotatedRegion, which sits deeper and wins.
          builder: (context, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark, // Android
                statusBarBrightness: Brightness.light, // iOS
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
