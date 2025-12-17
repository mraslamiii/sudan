import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/socket_viewmodel.dart';
import '../../core/di/injection_container.dart';
import '../../core/constants/socket_constants.dart';
import '../../core/localization/app_localizations.dart';

class SocketConnectionView extends StatelessWidget {
  const SocketConnectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<SocketViewModel>(),
      child: const _SocketConnectionViewContent(),
    );
  }
}

class _SocketConnectionViewContent extends StatefulWidget {
  const _SocketConnectionViewContent();

  @override
  State<_SocketConnectionViewContent> createState() => _SocketConnectionViewContentState();
}

class _SocketConnectionViewContentState extends State<_SocketConnectionViewContent> {
  final TextEditingController _ipController = TextEditingController(
    text: SocketConstants.defaultIp,
  );
  final TextEditingController _portController = TextEditingController(
    text: SocketConstants.defaultPort.toString(),
  );

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SocketViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.socketConnection),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status
            Card(
              color: viewModel.isConnected ? Colors.green : Colors.red,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      viewModel.isConnected ? Icons.check_circle : Icons.error,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.isConnected ? l10n.connected : l10n.disconnected,
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

            // IP and Port Input
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: l10n.ipAddress,
                border: const OutlineInputBorder(),
              ),
              enabled: !viewModel.isConnected,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: l10n.port,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              enabled: !viewModel.isConnected,
            ),
            const SizedBox(height: 16),

            // Connection Buttons
            if (!viewModel.isConnected)
              ElevatedButton.icon(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final ip = _ipController.text.trim();
                        final port = int.tryParse(_portController.text.trim());
                        if (ip.isNotEmpty && port != null) {
                          await viewModel.connect(ip: ip, port: port);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.pleaseEnterValidIpPort)),
                          );
                        }
                      },
                icon: viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link),
                label: Text(l10n.connect),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => viewModel.disconnect(),
                      icon: const Icon(Icons.link_off),
                      label: Text(l10n.disconnect),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => viewModel.reconnect(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.reconnect),
                    ),
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

            // Command Section
            Text(
              l10n.commands,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Request IP Config
            ElevatedButton.icon(
              onPressed: viewModel.isConnected
                  ? () => viewModel.requestIpConfig()
                  : null,
              icon: const Icon(Icons.settings_ethernet),
              label: Text(l10n.requestIpConfig),
            ),
            const SizedBox(height: 8),

            // Request Floors Count
            ElevatedButton.icon(
              onPressed: viewModel.isConnected
                  ? () => viewModel.requestFloorsCount()
                  : null,
              icon: const Icon(Icons.layers),
              label: Text(l10n.requestFloorsCount),
            ),
            const SizedBox(height: 8),

            // Test Light Command
            ElevatedButton.icon(
              onPressed: viewModel.isConnected
                  ? () => viewModel.sendLightCommand('1', true)
                  : null,
              icon: const Icon(Icons.lightbulb),
              label: Text(l10n.turnOnLightDevice),
            ),
            const SizedBox(height: 8),

            // Test Curtain Command
            ElevatedButton.icon(
              onPressed: viewModel.isConnected
                  ? () => viewModel.sendCurtainCommand('1', 'open')
                  : null,
              icon: const Icon(Icons.curtains),
              label: Text(l10n.openCurtainDevice),
            ),
            const SizedBox(height: 8),

            // Test Socket Charge Command
            ElevatedButton.icon(
              onPressed: viewModel.isConnected
                  ? () => viewModel.sendSocketChargeCommand('1')
                  : null,
              icon: const Icon(Icons.battery_charging_full),
              label: Text(l10n.chargeTabletDevice),
            ),
            const SizedBox(height: 8),

            // Test Socket Discharge Command
            ElevatedButton.icon(
              onPressed: viewModel.isConnected
                  ? () => viewModel.sendSocketDischargeCommand('1')
                  : null,
              icon: const Icon(Icons.battery_std),
              label: Text(l10n.dischargeTabletDevice),
            ),
            const SizedBox(height: 8),

            // Test Socket On/Off Command
            ElevatedButton.icon(
              onPressed: viewModel.isConnected
                  ? () => viewModel.sendSocketCommand('1', true)
                  : null,
              icon: const Icon(Icons.power),
              label: Text(l10n.socketOnDevice),
            ),

            // Last Received Data
            if (viewModel.lastReceivedData != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                l10n.lastReceivedData,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    viewModel.lastReceivedData!.join('-'),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


