import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/bluetooth_provider.dart';
import '../../widgets/device_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/status_indicator.dart';

/// 蓝牙扫描页面
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = context.watch<BluetoothProvider>();

    // 控制扫描动画
    if (bluetoothProvider.isScanning) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题栏
            _buildAppBar(context, bluetoothProvider),
            // 扫描按钮区域
            _buildScanButton(bluetoothProvider),
            // 错误提示
            if (bluetoothProvider.error != null)
              _buildErrorBanner(bluetoothProvider),
            // 设备列表
            Expanded(
              child: bluetoothProvider.devices.isEmpty
                  ? _buildEmptyState(bluetoothProvider)
                  : _buildDeviceList(context, bluetoothProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, BluetoothProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text(
            '蓝牙设备',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // 扫描状态指示器
          if (provider.isScanning)
            Row(
              children: [
                RotationTransition(
                  turns: _animationController,
                  child: const Icon(
                    Icons.radar,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '扫描中',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BluetoothProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 大扫描按钮
          GestureDetector(
            onTap: () {
              if (provider.isScanning) {
                provider.stopScan();
              } else {
                provider.startScan();
              }
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: provider.isScanning
                    ? const LinearGradient(
                        colors: [Color(0xFF444444), Color(0xFF555555)],
                      )
                    : AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: provider.isScanning
                        ? Colors.transparent
                        : AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                provider.isScanning ? Icons.stop : Icons.bluetooth_searching,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            provider.isScanning ? '点击停止扫描' : '点击开始扫描',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BluetoothProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.error!,
              style: const TextStyle(color: AppColors.error, fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: provider.clearError,
            icon: const Icon(Icons.close, color: AppColors.error, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BluetoothProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.bluetooth_disabled,
              size: 40,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            provider.isScanning ? '正在搜索设备...' : '未发现设备',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '请确保蓝牙已开启且设备在附近',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, BluetoothProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: provider.devices.length,
      itemBuilder: (context, index) {
        final device = provider.devices[index];
        return DeviceCard(
          device: device,
          isConnecting: provider.isConnecting && 
              provider.connectedDevice?.id == device.id,
          onTap: () {
            if (device.isConnected) {
              context.push('/device/${device.id}');
            }
          },
          onConnect: () async {
            final success = await provider.connect(device);
            if (success && context.mounted) {
              context.push('/device/${device.id}');
            }
          },
        );
      },
    );
  }
}
