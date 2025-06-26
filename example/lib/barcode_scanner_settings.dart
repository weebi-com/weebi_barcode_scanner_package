import 'package:flutter/material.dart';
import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';

class BarcodeScannerSettings extends StatefulWidget {
  final BarcodeScannerConfig initialConfig;
  final Function(BarcodeScannerConfig) onConfigChanged;

  const BarcodeScannerSettings({
    super.key,
    required this.initialConfig,
    required this.onConfigChanged,
  });

  @override
  State<BarcodeScannerSettings> createState() => _BarcodeScannerSettingsState();
}

class _BarcodeScannerSettingsState extends State<BarcodeScannerSettings> {
  late BarcodeScannerConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
  }

  void _updateConfig(BarcodeScannerConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
    widget.onConfigChanged(newConfig);
  }

  String _getSensitivityLabel(double value) {
    if (value <= 0.3) return 'Low';
    if (value <= 0.6) return 'Medium';
    return 'High';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Scanning Behavior'),
          _buildScanningModeCard(),
          const SizedBox(height: 16),
          
          _buildSectionHeader('Camera Settings'),
          _buildCameraSettingsCard(),
          const SizedBox(height: 16),
          
          _buildSectionHeader('Feedback'),
          _buildFeedbackSettingsCard(),
          const SizedBox(height: 16),
          
          _buildSectionHeader('Performance'),
          _buildPerformanceSettingsCard(),
          const SizedBox(height: 16),
          
          _buildSectionHeader('About'),
          _buildAboutCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildScanningModeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Scanning Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            RadioListTile<ScannerConfig>(
              title: const Text('Continuous Scanning'),
              subtitle: const Text('Scan multiple barcodes continuously'),
              value: ScannerConfig.continuousMode,
              groupValue: _config.scannerMode,
              onChanged: (ScannerConfig? value) {
                if (value != null) {
                  _updateConfig(_config.copyWith(scannerMode: value));
                }
              },
            ),
            
            RadioListTile<ScannerConfig>(
              title: const Text('Point of Sale Mode'),
              subtitle: const Text('Optimized for quick single scans'),
              value: ScannerConfig.pointOfSaleMode,
              groupValue: _config.scannerMode,
              onChanged: (ScannerConfig? value) {
                if (value != null) {
                  _updateConfig(_config.copyWith(scannerMode: value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Camera Options',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Auto Focus'),
              subtitle: const Text('Enable automatic focus for better scanning'),
              value: _config.autoFocus,
              onChanged: (bool value) {
                _updateConfig(_config.copyWith(autoFocus: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Auto Focus ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            
            SwitchListTile(
              title: const Text('Torch/Flash'),
              subtitle: const Text('Use flash for better scanning in low light'),
              value: _config.flashEnabled,
              onChanged: (bool value) {
                _updateConfig(_config.copyWith(flashEnabled: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Torch ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.feedback, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Feedback Options',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Sound Effects'),
              subtitle: const Text('Play sound when barcode is detected'),
              value: _config.soundEnabled,
              onChanged: (bool value) {
                _updateConfig(_config.copyWith(soundEnabled: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sound effects ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            
            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text('Vibrate when barcode is detected'),
              value: _config.vibrationEnabled,
              onChanged: (bool value) {
                _updateConfig(_config.copyWith(vibrationEnabled: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vibration ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            
            SwitchListTile(
              title: const Text('Visual Feedback'),
              subtitle: const Text('Show animation when barcode is detected'),
              value: _config.visualFeedbackEnabled,
              onChanged: (bool value) {
                _updateConfig(_config.copyWith(visualFeedbackEnabled: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Visual feedback ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.speed, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ListTile(
              title: const Text('Scan Sensitivity'),
              subtitle: Slider(
                value: _config.sensitivity,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                label: _getSensitivityLabel(_config.sensitivity),
                onChanged: (double value) {
                  _updateConfig(_config.copyWith(sensitivity: value));
                },
              ),
              trailing: Text(_getSensitivityLabel(_config.sensitivity)),
            ),
            
            SwitchListTile(
              title: const Text('High Performance Mode'),
              subtitle: const Text('Use more resources for faster scanning'),
              value: _config.highPerformanceMode,
              onChanged: (bool value) {
                _updateConfig(_config.copyWith(highPerformanceMode: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('High performance mode ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ListTile(
              title: const Text('Scanner Version'),
              subtitle: const Text('1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Scanner Information'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weebi Barcode Scanner v1.0.0'),
                        SizedBox(height: 8),
                        Text('Powered by advanced ML detection'),
                        SizedBox(height: 8),
                        Text('Supports multiple barcode formats'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            ListTile(
              title: const Text('Reset to Defaults'),
              subtitle: const Text('Restore all settings to default values'),
              trailing: const Icon(Icons.refresh),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Settings'),
                    content: const Text('Are you sure you want to reset all settings to their default values?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateConfig(const BarcodeScannerConfig(
                            scannerMode: ScannerConfig.continuousMode,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings reset to defaults')),
                          );
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Configuration class to hold scanner settings
class BarcodeScannerConfig {
  final ScannerConfig scannerMode;
  final bool autoFocus;
  final bool flashEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool visualFeedbackEnabled;
  final double sensitivity;
  final bool highPerformanceMode;

  const BarcodeScannerConfig({
    required this.scannerMode,
    this.autoFocus = true,
    this.flashEnabled = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.visualFeedbackEnabled = true,
    this.sensitivity = 0.7,
    this.highPerformanceMode = false,
  });

  BarcodeScannerConfig copyWith({
    ScannerConfig? scannerMode,
    bool? autoFocus,
    bool? flashEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? visualFeedbackEnabled,
    double? sensitivity,
    bool? highPerformanceMode,
  }) {
    return BarcodeScannerConfig(
      scannerMode: scannerMode ?? this.scannerMode,
      autoFocus: autoFocus ?? this.autoFocus,
      flashEnabled: flashEnabled ?? this.flashEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      visualFeedbackEnabled: visualFeedbackEnabled ?? this.visualFeedbackEnabled,
      sensitivity: sensitivity ?? this.sensitivity,
      highPerformanceMode: highPerformanceMode ?? this.highPerformanceMode,
    );
  }
} 