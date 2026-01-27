import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/bluetooth/scan_screen.dart';
import '../../screens/bluetooth/device_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/main_screen.dart';

/// 应用路由配置
class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';

      // 未登录时只能访问登录和注册页
      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      // 已登录时访问登录页则跳转到首页
      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return '/';
      }

      return null;
    },
    routes: [
      // 登录页
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // 注册页
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // 主页面（带底部导航）
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/bluetooth',
            builder: (context, state) => const ScanScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // 设备详情页
      GoRoute(
        path: '/device/:deviceId',
        builder: (context, state) {
          final deviceId = state.pathParameters['deviceId']!;
          return DeviceDetailScreen(deviceId: deviceId);
        },
      ),
    ],
  );
}
