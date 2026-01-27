import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

/// 认证服务 - 处理登录、注册、Token 管理
class AuthService {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  AuthService(this._apiService, this._prefs);

  /// 用户登录
  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiService.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final authResponse = AuthResponse.fromJson(response.data);
    
    // 保存 Token 和用户信息
    await _saveAuthData(authResponse);
    
    return authResponse;
  }

  /// 用户注册
  Future<AuthResponse> register(String username, String email, String password) async {
    final response = await _apiService.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });

    final authResponse = AuthResponse.fromJson(response.data);
    
    // 保存 Token 和用户信息
    await _saveAuthData(authResponse);
    
    return authResponse;
  }

  /// 退出登录
  Future<void> logout() async {
    await _prefs.remove(AppConstants.accessTokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
    await _prefs.remove(AppConstants.userKey);
  }

  /// 获取当前用户
  User? getCurrentUser() {
    final userData = _prefs.getString(AppConstants.userKey);
    if (userData == null) return null;
    return User.fromJson(jsonDecode(userData));
  }

  /// 检查是否已登录
  bool isLoggedIn() {
    return _prefs.getString(AppConstants.accessTokenKey) != null;
  }

  /// 刷新 Token
  Future<void> refreshToken() async {
    final refreshToken = _prefs.getString(AppConstants.refreshTokenKey);
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await _apiService.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });

    await _prefs.setString(
      AppConstants.accessTokenKey, 
      response.data['access_token'],
    );
  }

  /// 保存认证数据
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _prefs.setString(AppConstants.accessTokenKey, authResponse.accessToken);
    await _prefs.setString(AppConstants.refreshTokenKey, authResponse.refreshToken);
    await _prefs.setString(AppConstants.userKey, jsonEncode(authResponse.user.toJson()));
  }
}
