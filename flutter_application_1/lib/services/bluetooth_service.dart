import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/device.dart';
import '../core/constants/app_constants.dart';

/// 蓝牙服务 - 处理 BLE 设备扫描和连接
class BluetoothService {
  final List<BleDevice> _discoveredDevices = [];
  BleDevice? _connectedDevice;
  StreamSubscription? _scanSubscription;
  bool _isScanning = false;

  /// 获取已发现的设备列表
  List<BleDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);

  /// 获取当前连接的设备
  BleDevice? get connectedDevice => _connectedDevice;

  /// 是否正在扫描
  bool get isScanning => _isScanning;

  /// 检查蓝牙权限
  Future<bool> checkPermissions() async {
    // Android 12+ 需要 BLUETOOTH_SCAN 和 BLUETOOTH_CONNECT 权限
    final bluetoothScan = await Permission.bluetoothScan.request();
    final bluetoothConnect = await Permission.bluetoothConnect.request();
    final location = await Permission.locationWhenInUse.request();

    return bluetoothScan.isGranted && 
           bluetoothConnect.isGranted && 
           location.isGranted;
  }

  /// 检查蓝牙是否开启
  Future<bool> isBluetoothOn() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  /// 开始扫描设备
  Stream<List<BleDevice>> startScan() async* {
    // 检查权限
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      throw Exception('蓝牙权限未授予');
    }

    // 检查蓝牙状态
    final isOn = await isBluetoothOn();
    if (!isOn) {
      throw Exception('请开启蓝牙');
    }

    _discoveredDevices.clear();
    _isScanning = true;

    // 开始扫描
    await FlutterBluePlus.startScan(
      timeout: Duration(seconds: AppConstants.bleScanTimeout),
    );

    // 监听扫描结果
    await for (final results in FlutterBluePlus.scanResults) {
      for (final result in results) {
        final device = BleDevice.fromScanResult(result);
        
        // 避免重复添加
        final existingIndex = _discoveredDevices.indexWhere((d) => d.id == device.id);
        if (existingIndex >= 0) {
          _discoveredDevices[existingIndex] = device;
        } else {
          _discoveredDevices.add(device);
        }
      }
      yield List.from(_discoveredDevices);
    }

    _isScanning = false;
  }

  /// 停止扫描
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _isScanning = false;
  }

  /// 连接设备
  Future<void> connect(BleDevice device) async {
    if (device.rawDevice == null) {
      throw Exception('无效的设备');
    }

    await device.rawDevice!.connect(
      timeout: Duration(seconds: AppConstants.bleConnectionTimeout),
    );

    _connectedDevice = device.copyWith(isConnected: true);
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (_connectedDevice?.rawDevice != null) {
      await _connectedDevice!.rawDevice!.disconnect();
    }
    _connectedDevice = null;
  }

  /// 获取设备服务
  Future<List<DeviceService>> discoverServices() async {
    if (_connectedDevice?.rawDevice == null) {
      throw Exception('未连接设备');
    }

    final services = await _connectedDevice!.rawDevice!.discoverServices();
    
    return services.map((service) {
      return DeviceService(
        uuid: service.uuid.toString(),
        characteristics: service.characteristics.map((char) {
          return DeviceCharacteristic(
            uuid: char.uuid.toString(),
            canRead: char.properties.read,
            canWrite: char.properties.write,
            canNotify: char.properties.notify,
          );
        }).toList(),
      );
    }).toList();
  }

  /// 释放资源
  void dispose() {
    _scanSubscription?.cancel();
    stopScan();
  }
}
