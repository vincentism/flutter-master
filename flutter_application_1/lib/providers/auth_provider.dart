import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// 认证状态管理
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService) {
    // 初始化时加载已保存的用户信息
    _user = _authService.getCurrentUser();
  }

  /// 当前用户
  User? get user => _user;

  /// 是否已登录
  bool get isAuthenticated => _user != null;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 错误信息
  String? get error => _error;

  /// 登录
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      _user = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 注册
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(username, email, password);
      _user = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 解析错误信息
  String _parseError(dynamic e) {
    if (e.toString().contains('401')) {
      return '邮箱或密码错误';
    }
    if (e.toString().contains('409')) {
      return '该邮箱已被注册';
    }
    if (e.toString().contains('Connection')) {
      return '网络连接失败，请检查网络';
    }
    return '操作失败，请重试';
  }
}
