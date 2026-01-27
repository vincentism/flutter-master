import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE 设备数据模型
class BleDevice {
  final String id;
  final String name;
  final int rssi;
  final bool isConnected;
  final BluetoothDevice? rawDevice;

  BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
    this.isConnected = false,
    this.rawDevice,
  });

  /// 从扫描结果创建
  factory BleDevice.fromScanResult(ScanResult result) {
    return BleDevice(
      id: result.device.remoteId.str,
      name: result.device.platformName.isNotEmpty 
          ? result.device.platformName 
          : 'Unknown Device',
      rssi: result.rssi,
      isConnected: false,
      rawDevice: result.device,
    );
  }

  /// 复制并修改连接状态
  BleDevice copyWith({
    String? id,
    String? name,
    int? rssi,
    bool? isConnected,
    BluetoothDevice? rawDevice,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      isConnected: isConnected ?? this.isConnected,
      rawDevice: rawDevice ?? this.rawDevice,
    );
  }

  /// 信号强度描述
  String get signalStrength {
    if (rssi >= -50) return '极强';
    if (rssi >= -60) return '强';
    if (rssi >= -70) return '中等';
    if (rssi >= -80) return '弱';
    return '极弱';
  }
}

/// 设备服务信息
class DeviceService {
  final String uuid;
  final List<DeviceCharacteristic> characteristics;

  DeviceService({
    required this.uuid,
    required this.characteristics,
  });
}

/// 设备特征值
class DeviceCharacteristic {
  final String uuid;
  final bool canRead;
  final bool canWrite;
  final bool canNotify;

  DeviceCharacteristic({
    required this.uuid,
    required this.canRead,
    required this.canWrite,
    required this.canNotify,
  });
}
