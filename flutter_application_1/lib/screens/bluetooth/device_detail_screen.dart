import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/device.dart';
import '../../providers/bluetooth_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/status_indicator.dart';

/// 设备详情页面
class DeviceDetailScreen extends StatelessWidget {
  final String deviceId;

  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = context.watch<BluetoothProvider>();
    final device = bluetoothProvider.getDeviceById(deviceId);

    if (device == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, null),
              const Expanded(
                child: Center(
                  child: Text(
                    '设备未找到',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildAppBar(context, device),
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 设备信息卡片
                    _buildDeviceInfoCard(device),
                    const SizedBox(height: 20),
                    // 服务列表
                    _buildServicesSection(bluetoothProvider),
                    const SizedBox(height: 20),
                    // 操作按钮
                    _buildActionButtons(context, bluetoothProvider, device),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, BleDevice? device) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device?.name ?? '设备详情',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (device != null)
                  Row(
                    children: [
                      StatusIndicator(
                        isActive: device.isConnected,
                        size: 8,
                        showPulse: false,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        device.isConnected ? '已连接' : '未连接',
                        style: TextStyle(
                          color: device.isConnected 
                              ? AppColors.success 
                              : AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard(BleDevice device) {
    return GlassCard(
      child: Column(
        children: [
          // 设备图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: device.isConnected
                  ? const LinearGradient(
                      colors: [AppColors.success, Color(0xFF2ECC71)],
                    )
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (device.isConnected 
                      ? AppColors.success 
                      : AppColors.primary).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.bluetooth,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          // 设备名称
          Text(
            device.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // 信息列表
          _buildInfoRow('MAC 地址', device.id),
          const Divider(color: AppColors.divider, height: 24),
          _buildInfoRow('信号强度', '${device.rssi} dBm (${device.signalStrength})'),
          const Divider(color: AppColors.divider, height: 24),
          _buildInfoRow('连接状态', device.isConnected ? '已连接' : '未连接'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(BluetoothProvider provider) {
    final services = provider.services;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '服务列表',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (services.isEmpty)
          GlassCard(
            child: Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.folder_off_outlined,
                    color: AppColors.textHint,
                    size: 40,
                  ),
                  SizedBox(height: 12),
                  Text(
                    '暂无服务信息',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...services.map((service) => _buildServiceCard(service)),
      ],
    );
  }

  Widget _buildServiceCard(DeviceService service) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: ThemeData.dark().copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 12),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.layers,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  service.uuid,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          children: service.characteristics.map((char) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.tag,
                      color: AppColors.textHint,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      char.uuid,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 特征值属性标签
                  if (char.canRead)
                    _buildPropertyTag('R', AppColors.success),
                  if (char.canWrite)
                    _buildPropertyTag('W', AppColors.warning),
                  if (char.canNotify)
                    _buildPropertyTag('N', AppColors.info),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPropertyTag(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    BluetoothProvider provider,
    BleDevice device,
  ) {
    return Column(
      children: [
        if (device.isConnected)
          GradientButton(
            text: '断开连接',
            gradientColors: const [AppColors.error, Color(0xFFE74C3C)],
            onPressed: () async {
              await provider.disconnect();
              if (context.mounted) {
                context.pop();
              }
            },
          )
        else
          GradientButton(
            text: '连接设备',
            isLoading: provider.isConnecting,
            onPressed: () => provider.connect(device),
          ),
      ],
    );
  }
}

extension GradientButtonExt on GradientButton {
  // ignore: unused_element
  GradientButton copyWith({List<Color>? gradientColors}) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }
}
