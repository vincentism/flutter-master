import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/bluetooth_service.dart';
import 'providers/auth_provider.dart';
import 'providers/bluetooth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // 初始化服务
  final apiService = ApiService(prefs);
  final authService = AuthService(apiService, prefs);
  final bluetoothService = BluetoothService();
  
  runApp(DeviceHubApp(
    authService: authService,
    bluetoothService: bluetoothService,
  ));
}

class DeviceHubApp extends StatelessWidget {
  final AuthService authService;
  final BluetoothService bluetoothService;

  const DeviceHubApp({
    super.key,
    required this.authService,
    required this.bluetoothService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider(
          create: (_) => BluetoothProvider(bluetoothService),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AuthProvider>();
          final router = AppRouter(authProvider);
          
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: router.router,
          );
        },
      ),
    );
  }
}
