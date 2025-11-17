import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/socket_viewmodel.dart';
import '../../core/di/injection_container.dart';
import '../../core/constants/socket_constants.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket Connection'),
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
                      viewModel.isConnected ? 'Connected' : 'Disconnected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Status: ${viewModel.connectionStatus}',
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
              decoration: const InputDecoration(
                labelText: 'IP Address',
                border: OutlineInputBorder(),
              ),
              enabled: !viewModel.isConnected,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                border: OutlineInputBorder(),
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
                            const SnackBar(content: Text('Please enter valid IP and Port')),
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
                label: const Text('Connect'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => viewModel.disconnect(),
                      icon: const Icon(Icons.link_off),
                      label: const Text('Disconnect'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => viewModel.reconnect(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reconnect'),
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
                          viewModel.errorMessage ?? 'Unknown error',
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
            const Text(
              'Commands',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Request IP Config
            ElevatedButton.icon(
              onPressed: viewModel.isConnected
                  ? () => viewModel.requestIpConfig()
                  : null,
              icon: const Icon(Icons.settings_ethernet),
              label: const Text('Request IP Config'),
            ),
            const SizedBox(height: 8),

            // Request Floors Count
            ElevatedButton.icon(
              onPressed: viewModel.isConnected
                  ? () => viewModel.requestFloorsCount()
                  : null,
              icon: const Icon(Icons.layers),
              label: const Text('Request Floors Count'),
            ),
            const SizedBox(height: 8),

            // Test Light Command
            ElevatedButton.icon(
              onPressed: viewModel.isConnected
                  ? () => viewModel.sendLightCommand('1', true)
                  : null,
              icon: const Icon(Icons.lightbulb),
              label: const Text('Turn On Light (Device 1)'),
            ),
            const SizedBox(height: 8),

            // Test Curtain Command
            ElevatedButton.icon(
              onPressed: viewModel.isConnected
                  ? () => viewModel.sendCurtainCommand('1', 'open')
                  : null,
              icon: const Icon(Icons.curtains),
              label: const Text('Open Curtain (Device 1)'),
            ),

            // Last Received Data
            if (viewModel.lastReceivedData != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Last Received Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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


