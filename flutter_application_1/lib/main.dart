import 'package:flutter/material.dart';

void main() {
  runApp(const EcoEnergyApp());
}

class EcoEnergyApp extends StatelessWidget {
  const EcoEnergyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoEnergy Monitor - SDG 7',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // State untuk Scale/Pinch (Memperbesar/memperkecil grafik)
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;

  // State untuk Double Tap (Mengubah tema/warna card)
  bool _isNightMode = false;

  // State untuk Swipe/Horizontal Drag (Menggeser notifikasi)
  double _dragOffset = 0.0;
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'EcoEnergy Monitor',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Column(
        children: [
          // KOMPONEN 1: Swipe/Horizontal Drag (Dismissible Notification Card)
          if (!_isDismissed)
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragOffset += details.primaryDelta!;
                });
              },
              onHorizontalDragEnd: (details) {
                // Jika digeser lebih dari 100 pixel ke kanan/kiri, hilangkan
                if (_dragOffset.abs() > 100) {
                  setState(() {
                    _isDismissed = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifikasi diabaikan')),
                  );
                } else {
                  // Kembalikan ke posisi semula jika geseran kurang
                  setState(() {
                    _dragOffset = 0.0;
                  });
                }
              },
              child: Transform.translate(
                offset: Offset(_dragOffset, 0),
                child: Opacity(
                  opacity: (1 - (_dragOffset.abs() / 200)).clamp(0.0, 1.0),
                  child: Card(
                    margin: const EdgeInsets.all(16.0),
                    color: Colors.yellow[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Cuaca mendung terdeteksi. Efisiensi panel surya diprediksi turun 20% hari ini. (Geser untuk menutup)',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // KOMPONEN 2: Double Tap & Pinch/Scale (Interactive Dashboard Card)
          Expanded(
            child: GestureDetector(
              // DOUBLE TAP: Ganti mode siang/malam (Warna Card)
              onDoubleTap: () {
                setState(() {
                  _isNightMode = !_isNightMode;
                });
              },
              // SCALE / PINCH: Zoom in/out pada ilustrasi panel surya
              onScaleStart: (details) {
                _baseScaleFactor = _scaleFactor;
              },
              onScaleUpdate: (details) {
                setState(() {
                  // Membatasi zoom antara 0.5x hingga 3.0x
                  _scaleFactor = (_baseScaleFactor * details.scale).clamp(0.5, 3.0);
                });
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 6,
                clipBehavior: Clip.antiAlias,
                color: _isNightMode ? const Color(0xFF1E293B) : Colors.white,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Element (Visual Feedback untuk Double Tap)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isNightMode
                              ? [Colors.blueGrey[900]!, Colors.black]
                              : [Colors.green[50]!, Colors.blue[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),

                    // Ilustrasi yang bisa di-zoom (Scale/Pinch)
                    Transform.scale(
                      scale: _scaleFactor,
                      child: Icon(
                        Icons.solar_power_rounded,
                        size: 150,
                        color: _isNightMode ? Colors.cyanAccent : Colors.green[600],
                      ),
                    ),

                    // Overlay Teks & Data (Menggunakan Column & Row)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Panel: ${_isNightMode ? 'Standby (Malam)' : 'Aktif (Siang)'}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _isNightMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Ketuk 2x untuk ubah mode, Cubit untuk zoom',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isNightMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            title: 'Daya Dihasilkan',
                            value: '4.2 kWh',
                            icon: Icons.bolt,
                            isNightMode: _isNightMode,
                          ),
                          _buildStatCard(
                            title: 'Efisiensi',
                            value: '92%',
                            icon: Icons.analytics_outlined,
                            isNightMode: _isNightMode,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Widget modular untuk menampilkan data statistik
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isNightMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNightMode ? Colors.black54 : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNightMode ? Colors.cyanAccent.withOpacity(0.3) : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: isNightMode ? Colors.cyanAccent : Colors.green[700]),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isNightMode ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isNightMode ? Colors.grey[300] : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}