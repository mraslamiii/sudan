import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:usb_serial/usb_serial.dart';
import '../../../core/di/injection_container.dart';
import '../../../presentation/viewmodels/usb_serial_viewmodel.dart';
import 'card_styles.dart';

/// USB Serial Status Panel Widget - Apple-style Design
/// Displays USB Serial connection status and allows connection/disconnection
class UsbSerialStatusPanel extends StatefulWidget {
  const UsbSerialStatusPanel({super.key});

  @override
  State<UsbSerialStatusPanel> createState() => _UsbSerialStatusPanelState();
}

class _UsbSerialStatusPanelState extends State<UsbSerialStatusPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  UsbSerialViewModel? _viewModel;
  List<UsbDevice> _availableDevices = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize ViewModel
    _viewModel = getIt<UsbSerialViewModel>();
    _loadAvailableDevices();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableDevices() async {
    if (_viewModel == null) return;

    try {
      final devices = await _viewModel!.getAvailableDevices();
      setState(() {
        _availableDevices = devices;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در دریافت دستگاه‌ها: $e')),
        );
      }
    }
  }

  Future<void> _handleConnect() async {
    if (_viewModel == null || _availableDevices.isEmpty) {
      await _loadAvailableDevices();
      if (_availableDevices.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('هیچ دستگاه USB یافت نشد')),
          );
        }
        return;
      }
    }

    HapticFeedback.mediumImpact();
    try {
      await _viewModel!.connect(
        device: _availableDevices.first,
        baudRate: 9600,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('متصل شد به: ${_availableDevices.first.deviceName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در اتصال: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDisconnect() async {
    if (_viewModel == null) return;

    HapticFeedback.mediumImpact();
    try {
      await _viewModel!.disconnect();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اتصال قطع شد'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در قطع اتصال: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color get _accentColor {
    if (_viewModel == null) return CardStyles.accentOrange;
    return _viewModel!.isUsbConnected
        ? CardStyles.accentGreen
        : CardStyles.accentOrange;
  }

  String _getStatusText() {
    if (_viewModel == null) return 'نامشخص';
    if (_viewModel!.isUsbConnected) return 'متصل';
    return 'قطع شده';
  }

  IconData get _statusIcon {
    if (_viewModel == null) return Icons.usb_outlined;
    return _viewModel!.isUsbConnected
        ? Icons.usb_rounded
        : Icons.usb_off_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<UsbSerialViewModel>(
        builder: (context, viewModel, child) {
          // Update pulse animation based on connection status
          if (viewModel.isUsbConnected && !_pulseController.isAnimating) {
            _pulseController.repeat(reverse: true);
          } else if (!viewModel.isUsbConnected && _pulseController.isAnimating) {
            _pulseController.stop();
            _pulseController.reset();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 260;
              final isVeryCompact = constraints.maxHeight < 200;

              return Padding(
                padding: EdgeInsets.all(
                  isCompact ? CardStyles.space12 : CardStyles.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, isDark, isCompact, viewModel),

                    SizedBox(
                      height: isCompact ? CardStyles.space8 : CardStyles.space12,
                    ),

                    // Main content
                    Expanded(
                      child: Column(
                        children: [
                          // USB visualization with status ring
                          Expanded(
                            flex: 3,
                            child: _buildUsbVisualization(
                              isDark,
                              isCompact,
                              isVeryCompact,
                              viewModel,
                            ),
                          ),

                          SizedBox(
                            height: isCompact
                                ? CardStyles.space8
                                : CardStyles.space12,
                          ),

                          // Action buttons
                          _buildActionButtons(isDark, isCompact, viewModel),

                          // Device info (if available and space permits)
                          if (!isVeryCompact &&
                              viewModel.isUsbConnected &&
                              _availableDevices.isNotEmpty) ...[
                            SizedBox(
                              height: isCompact
                                  ? CardStyles.space8
                                  : CardStyles.space12,
                            ),
                            _buildDeviceInfo(isDark, isCompact),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    bool isCompact,
    UsbSerialViewModel viewModel,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'USB Serial',
                style: CardStyles.cardTitle(isDark, isCompact: isCompact),
              ),
              SizedBox(height: isCompact ? 4 : 6),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accentColor,
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getStatusText(),
                    style: CardStyles
                        .cardSubtitle(isDark, isCompact: isCompact)
                        .copyWith(
                          color: _accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Status icon badge
        Padding(
          padding: EdgeInsets.only(top: isCompact ? 0 : 2),
          child: Container(
            width: isCompact ? 36 : 42,
            height: isCompact ? 36 : 42,
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(isDark ? 0.2 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon,
              color: _accentColor,
              size: isCompact ? 18 : 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsbVisualization(
    bool isDark,
    bool isCompact,
    bool isVeryCompact,
    UsbSerialViewModel viewModel,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxHeight.clamp(80.0, 140.0);

        return Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = viewModel.isUsbConnected
                  ? _pulseAnimation.value
                  : 1.0;

              return Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _accentColor.withOpacity(
                                viewModel.isUsbConnected ? 0.25 : 0.08,
                              ),
                              _accentColor.withOpacity(
                                viewModel.isUsbConnected ? 0.1 : 0.02,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Progress ring
                      SizedBox(
                        width: size * 0.85,
                        height: size * 0.85,
                        child: CircularProgressIndicator(
                          value: viewModel.isUsbConnected ? 1.0 : 0.0,
                          strokeWidth: 4,
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.05),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_accentColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      // Inner USB container
                      Container(
                        width: size * 0.7,
                        height: size * 0.7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: viewModel.isUsbConnected
                              ? _accentColor.withOpacity(
                                  isDark ? 0.2 : 0.12,
                                )
                              : (isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.black.withOpacity(0.04)),
                          border: Border.all(
                            color: _accentColor.withOpacity(
                              viewModel.isUsbConnected ? 0.4 : 0.15,
                            ),
                            width: 2,
                          ),
                          boxShadow: viewModel.isUsbConnected
                              ? [
                                  BoxShadow(
                                    color: _accentColor.withOpacity(0.3),
                                    blurRadius: 16,
                                    spreadRadius: -4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _statusIcon,
                              size: size * 0.28,
                              color: _accentColor,
                            ),
                            SizedBox(height: isCompact ? 2 : 4),
                            Text(
                              viewModel.isUsbConnected ? 'ON' : 'OFF',
                              style: TextStyle(
                                fontSize: isCompact ? 10 : 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: _accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
    bool isDark,
    bool isCompact,
    UsbSerialViewModel viewModel,
  ) {
    return Row(
      children: [
        // Connect button
        Expanded(
          child: _buildModeButton(
            isDark: isDark,
            isCompact: isCompact,
            label: 'اتصال',
            icon: Icons.link_rounded,
            isSelected: viewModel.isUsbConnected,
            onTap: !viewModel.isUsbConnected
                ? () async => await _handleConnect()
                : null,
            isLoading: viewModel.isLoading && !viewModel.isUsbConnected,
          ),
        ),
        SizedBox(width: isCompact ? CardStyles.space8 : CardStyles.space12),
        // Disconnect button
        Expanded(
          child: _buildModeButton(
            isDark: isDark,
            isCompact: isCompact,
            label: 'قطع',
            icon: Icons.link_off_rounded,
            isSelected: !viewModel.isUsbConnected,
            onTap: viewModel.isUsbConnected
                ? () async => await _handleDisconnect()
                : null,
            isLoading: viewModel.isLoading && viewModel.isUsbConnected,
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required bool isDark,
    required bool isCompact,
    required String label,
    required IconData icon,
    required bool isSelected,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final enabled = onTap != null && !isLoading;
    final color = isSelected ? _accentColor : CardStyles.iconColor(isDark);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: CardStyles.normal,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentColor.withOpacity(isDark ? 0.2 : 0.12)
              : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _accentColor.withOpacity(0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: isCompact ? 16 : 18,
                height: isCompact ? 16 : 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    enabled ? color : color.withOpacity(0.4),
                  ),
                ),
              )
            else
              Icon(
                icon,
                color: enabled ? color : color.withOpacity(0.4),
                size: isCompact ? 18 : 20,
              ),
            SizedBox(width: isCompact ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isCompact ? 13 : 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: enabled ? color : color.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfo(bool isDark, bool isCompact) {
    if (_availableDevices.isEmpty) return const SizedBox.shrink();

    final device = _availableDevices.first;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 14,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.usb_rounded,
            size: isCompact ? 14 : 16,
            color: _accentColor,
          ),
          SizedBox(width: isCompact ? 6 : 8),
          Flexible(
            child: Text(
              device.deviceName.isNotEmpty ? device.deviceName : 'Unknown Device',
              style: TextStyle(
                fontSize: isCompact ? 11 : 12,
                fontWeight: FontWeight.w500,
                color: _accentColor,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

