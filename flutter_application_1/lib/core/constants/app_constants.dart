/// 应用常量配置
class AppConstants {
  // API 配置
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';
  
  // Token 存储键
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  
  // 蓝牙扫描配置
  static const int bleScanTimeout = 10; // 秒
  static const int bleConnectionTimeout = 15; // 秒
  
  // 应用信息
  static const String appName = 'DeviceHub';
  static const String appVersion = '1.0.0';
}
