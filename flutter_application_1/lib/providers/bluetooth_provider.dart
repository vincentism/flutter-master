import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/device.dart';
import '../services/bluetooth_service.dart';

/// 蓝牙状态管理
class BluetoothProvider extends ChangeNotifier {
  final BluetoothService _bluetoothService;

  List<BleDevice> _devices = [];
  BleDevice? _connectedDevice;
  List<DeviceService> _services = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _error;
  StreamSubscription? _scanSubscription;

  BluetoothProvider(this._bluetoothService);

  /// 已发现的设备列表
  List<BleDevice> get devices => _devices;

  /// 当前连接的设备
  BleDevice? get connectedDevice => _connectedDevice;

  /// 设备服务列表
  List<DeviceService> get services => _services;

  /// 是否正在扫描
  bool get isScanning => _isScanning;

  /// 是否正在连接
  bool get isConnecting => _isConnecting;

  /// 错误信息
  String? get error => _error;

  /// 开始扫描
  Future<void> startScan() async {
    _error = null;
    _isScanning = true;
    _devices = [];
    notifyListeners();

    try {
      _scanSubscription = _bluetoothService.startScan().listen(
        (devices) {
          _devices = devices;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isScanning = false;
          notifyListeners();
        },
        onDone: () {
          _isScanning = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isScanning = false;
      notifyListeners();
    }
  }

  /// 停止扫描
  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    await _bluetoothService.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  /// 连接设备
  Future<bool> connect(BleDevice device) async {
    _error = null;
    _isConnecting = true;
    notifyListeners();

    try {
      await _bluetoothService.connect(device);
      _connectedDevice = device.copyWith(isConnected: true);
      
      // 发现服务
      _services = await _bluetoothService.discoverServices();
      
      _isConnecting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '连接失败: ${e.toString()}';
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    await _bluetoothService.disconnect();
    _connectedDevice = null;
    _services = [];
    notifyListeners();
  }

  /// 根据 ID 获取设备
  BleDevice? getDeviceById(String id) {
    try {
      return _devices.firstWhere((d) => d.id == id);
    } catch (_) {
      return _connectedDevice?.id == id ? _connectedDevice : null;
    }
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _bluetoothService.dispose();
    super.dispose();
  }
}
