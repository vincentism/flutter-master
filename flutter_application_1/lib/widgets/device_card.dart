import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/device.dart';

/// 设备卡片组件
class DeviceCard extends StatelessWidget {
  final BleDevice device;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;
  final bool isConnecting;

  const DeviceCard({
    super.key,
    required this.device,
    this.onTap,
    this.onConnect,
    this.isConnecting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: device.isConnected 
              ? AppColors.success.withOpacity(0.5) 
              : AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 设备图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bluetooth,
                    color: device.isConnected 
                        ? AppColors.success 
                        : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // 设备信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildSignalIndicator(),
                          const SizedBox(width: 8),
                          Text(
                            device.id,
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 连接按钮或状态
                if (device.isConnected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '已连接',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else if (onConnect != null)
                  isConnecting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: onConnect,
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primary,
                          ),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignalIndicator() {
    final strength = device.rssi;
    Color color;
    int bars;

    if (strength >= -50) {
      color = AppColors.success;
      bars = 4;
    } else if (strength >= -60) {
      color = AppColors.success;
      bars = 3;
    } else if (strength >= -70) {
      color = AppColors.warning;
      bars = 2;
    } else {
      color = AppColors.error;
      bars = 1;
    }

    return Row(
      children: List.generate(4, (index) {
        return Container(
          width: 3,
          height: 6 + index * 2.0,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: index < bars ? color : AppColors.textHint.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}
