import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:usb_serial/usb_serial.dart';
import '../viewmodels/usb_serial_viewmodel.dart';
import '../viewmodels/floor_viewmodel.dart';
import '../viewmodels/room_viewmodel.dart';
import '../../core/di/injection_container.dart';
import '../../core/constants/usb_serial_constants.dart';
import '../../core/localization/app_localizations.dart';

/// صفحه اتصال سریال (USB Serial) به میکروکنترلر
/// قبلاً از Socket TCP استفاده می‌شد؛ اکنون فقط اتصال سریال پشتیبانی می‌شود.
class SocketConnectionView extends StatefulWidget {
  const SocketConnectionView({super.key});

  @override
  State<SocketConnectionView> createState() => _SocketConnectionViewState();
}

class _SocketConnectionViewState extends State<SocketConnectionView> {
  List<UsbDevice> _availableDevices = [];
  UsbSerialViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<UsbSerialViewModel>();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    if (_viewModel == null) return;
    try {
      final devices = await _viewModel!.getAvailableDevices();
      if (mounted) setState(() => _availableDevices = devices);
    } catch (_) {}
  }

  Future<void> _handleConnect() async {
    if (_viewModel == null) return;
    await _loadDevices();

    if (_availableDevices.isEmpty) {
      if (kDebugMode) {
        try {
          await _viewModel!.connect(
            device: null,
            baudRate: UsbSerialConstants.defaultBaudRate,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('اتصال شبیه‌سازی شد (بدون دستگاه USB فیزیکی)'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red),
            );
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('هیچ دستگاه USB یافت نشد')),
        );
      }
      return;
    }

    try {
      await _viewModel!.connect(
        device: _availableDevices.first,
        baudRate: UsbSerialConstants.defaultBaudRate,
        context: context,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('متصل شد: ${_availableDevices.first.deviceName}'),
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
    await _viewModel?.disconnect();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.serialConnection)),
        body: Consumer<UsbSerialViewModel>(
          builder: (context, viewModel, _) {
            final isConnected = viewModel.isUsbConnected;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // وضعیت اتصال
                  Card(
                    color: isConnected ? Colors.green : Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            isConnected ? Icons.check_circle : Icons.error,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isConnected ? l10n.connected : l10n.disconnected,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${l10n.status} ${viewModel.connectionStatus}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // انتخاب دستگاه USB (اگر موجود باشد)
                  if (_availableDevices.isNotEmpty && !isConnected) ...[
                    Text(
                      'دستگاه USB',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _availableDevices.first.deviceName.isEmpty
                              ? 'دستگاه ۱'
                              : _availableDevices.first.deviceName,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // دکمه‌های اتصال / قطع
                  if (!isConnected) ...[
                    ElevatedButton.icon(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              await _handleConnect();
                              setState(() {});
                            },
                      icon: viewModel.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.usb),
                      label: Text(l10n.connect),
                    ),
                    const SizedBox(height: 12),
                    // اتصال دیباگ: تبلت با یک کابل به لپ‌تاپ، شبیه‌ساز با --tcp 9999 و adb reverse
                    OutlinedButton.icon(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              await viewModel.connectTcpDebug(
                                host: '127.0.0.1',
                                port: 9999,
                              );
                              if (mounted) setState(() {});
                            },
                      icon: const Icon(Icons.developer_mode),
                      label: const Text('اتصال دیباگ (دستگاه + adb reverse)'),
                    ),
                    const SizedBox(height: 8),
                    // امولاتور: 127.0.0.1 روی امولاتور به خودش اشاره می‌کند؛ برای رسیدن به لپ‌تاپ از 10.0.2.2 استفاده کنید
                    OutlinedButton.icon(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              await viewModel.connectTcpDebug(
                                host: '10.0.2.2',
                                port: 9999,
                              );
                              if (mounted) setState(() {});
                            },
                      icon: const Icon(Icons.smartphone),
                      label: const Text('اتصال دیباگ (امولاتور → لپ‌تاپ)'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'دستگاه فیزیکی: adb reverse tcp:9999 tcp:9999 و سپس دکمه اول. امولاتور: شبیه‌ساز با --tcp 9999 روی لپ‌تاپ و دکمه دوم.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ] else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await _handleDisconnect();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.link_off),
                                label: Text(l10n.disconnect),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // بعد از اتصال، با این دکمه لیست طبقات و اتاق‌ها از میکرو گرفته و در اپ به‌روز می‌شود
                        ElevatedButton.icon(
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                                  try {
                                    final floorVM = context
                                        .read<FloorViewModel>();
                                    final roomVM = context
                                        .read<RoomViewModel>();
                                    await floorVM.loadFloors();
                                    await roomVM.loadRooms();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'لیست طبقات و اتاق‌ها از میکرو بروزرسانی شد (${floorVM.floors.length} طبقه)',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    setState(() {});
                                    // برگشت به صفحهٔ اصلی تا لیست طبقات به‌روز دیده شود
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('خطا در بروزرسانی: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.sync),
                          label: const Text(
                            'بروزرسانی لیست طبقات و اتاق‌ها از میکرو',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'بعد از اتصال این دکمه را بزنید تا لیست طبقات در صفحهٔ اصلی به‌روز شود.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),

                  if (viewModel.hasError) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage ?? l10n.unknownError,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // دستورات تست
                  Text(
                    l10n.commands,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _CmdButton(
                    enabled: isConnected,
                    icon: Icons.settings_ethernet,
                    label: l10n.requestIpConfig,
                    onPressed: () => viewModel.requestIpConfig(),
                  ),
                  const SizedBox(height: 8),
                  _CmdButton(
                    enabled: isConnected,
                    icon: Icons.layers,
                    label: l10n.requestFloorsCount,
                    onPressed: () => viewModel.requestFloorsCount(),
                  ),
                  const SizedBox(height: 8),
                  _CmdButton(
                    enabled: isConnected,
                    icon: Icons.list_alt,
                    label: l10n.requestFloorsList,
                    onPressed: () async {
                      final list = await viewModel.requestFloors();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            list != null
                                ? '${l10n.requestFloorsList}: ${list.length}'
                                : '${l10n.requestFloorsList}: timeout / error',
                          ),
                          backgroundColor: list != null
                              ? Colors.green
                              : Colors.orange,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _CmdButton(
                    enabled: isConnected,
                    icon: Icons.door_front_door,
                    label: l10n.requestRoomsList,
                    onPressed: () async {
                      final list = await viewModel.requestAllRooms();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            list != null
                                ? '${l10n.requestRoomsList}: ${list.length}'
                                : '${l10n.requestRoomsList}: timeout / error',
                          ),
                          backgroundColor: list != null
                              ? Colors.green
                              : Colors.orange,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _CmdButton(
                    enabled: isConnected,
                    icon: Icons.lightbulb,
                    label: l10n.turnOnLightDevice,
                    onPressed: () => viewModel.sendLightCommand('1', true),
                  ),
                  const SizedBox(height: 8),
                  _CmdButton(
                    enabled: isConnected,
                    icon: Icons.curtains,
                    label: l10n.openCurtainDevice,
                    onPressed: () => viewModel.sendCurtainCommand('1', 'open'),
                  ),
                  const SizedBox(height: 8),
                  _CmdButton(
                    enabled: isConnected,
                    icon: Icons.battery_charging_full,
                    label: l10n.chargeTabletDevice,
                    onPressed: () => viewModel.sendSocketChargeCommand('1'),
                  ),
                  const SizedBox(height: 8),
                  _CmdButton(
                    enabled: isConnected,
                    icon: Icons.battery_std,
                    label: l10n.dischargeTabletDevice,
                    onPressed: () => viewModel.sendSocketDischargeCommand('1'),
                  ),
                  const SizedBox(height: 8),
                  _CmdButton(
                    enabled: isConnected,
                    icon: Icons.power,
                    label: l10n.socketOnDevice,
                    onPressed: () => viewModel.sendSocketCommand('1', true),
                  ),

                  // آخرین داده دریافت‌شده (سریال)
                  if (viewModel.lastReceivedMessage != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      l10n.lastReceivedData,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SelectableText(
                          viewModel.lastReceivedMessage!.data.isNotEmpty
                              ? viewModel.lastReceivedMessage!.data
                              : 'type: ${viewModel.lastReceivedMessage!.type}',
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CmdButton extends StatelessWidget {
  const _CmdButton({
    required this.enabled,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
