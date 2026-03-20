import 'package:flutter/material.dart';

class HealthService {
  String status = 'unknown';
  void updateStatus(String newStatus) => status = newStatus;
  String getStatus() => status;
}

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final HealthService _healthService = HealthService();
  String _selectedStatus = '尚未回報';

  static const _bg = Color(0xFFF7F3EC);
  static const _card = Color(0xFFFEFDF9);
  static const _textPrimary = Color(0xFF3D2C1E);
  static const _textSecondary = Color(0xFF8C7B6E);

  final List<Map<String, dynamic>> _statusOptions = [
    {
      'label': '安全',
      'desc': '本人平安，無需協助',
      'icon': Icons.check_circle_rounded,
      'color': const Color(0xFF7AA67A),
    },
    {
      'label': '輕傷',
      'desc': '有輕微傷口，能自行行動',
      'icon': Icons.medical_services_rounded,
      'color': const Color(0xFFBF7A5A),
    },
    {
      'label': '重傷',
      'desc': '受傷嚴重，需要醫療協助',
      'icon': Icons.emergency_rounded,
      'color': const Color(0xFFC4553A),
    },
    {
      'label': '需要救援',
      'desc': '被困或無法自行脫困',
      'icon': Icons.sos_rounded,
      'color': const Color(0xFF9B88B3),
    },
  ];

  Color _statusColor() {
    final match = _statusOptions.where((o) => o['label'] == _selectedStatus);
    return match.isEmpty ? _textSecondary : match.first['color'] as Color;
  }

  void _select(String status) {
    _healthService.updateStatus(status);
    setState(() => _selectedStatus = status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已回報：$status'),
        backgroundColor: _statusColor(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('健康回報'),
        iconTheme: const IconThemeData(color: _textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 目前狀態卡
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3D2C1E).withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _statusColor().withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _statusOptions.where((o) => o['label'] == _selectedStatus).isEmpty
                            ? Icons.help_outline_rounded
                            : _statusOptions.firstWhere((o) => o['label'] == _selectedStatus)['icon'] as IconData,
                        color: _statusColor(),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('目前回報狀態', style: TextStyle(fontSize: 12, color: _textSecondary)),
                        const SizedBox(height: 3),
                        Text(
                          _selectedStatus,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _statusColor(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  '選擇狀態',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textSecondary, letterSpacing: 1.2),
                ),
              ),

              Expanded(
                child: ListView.separated(
                  itemCount: _statusOptions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = _statusOptions[index];
                    final color = option['color'] as Color;
                    final isSelected = _selectedStatus == option['label'];
                    return GestureDetector(
                      onTap: () => _select(option['label'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.08) : _card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? color.withValues(alpha: 0.6) : const Color(0xFFE8E0D5),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF3D2C1E).withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(option['icon'] as IconData, color: color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['label'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? color : _textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    option['desc'] as String,
                                    style: const TextStyle(fontSize: 12, color: _textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: color, size: 22)
                            else
                              Icon(Icons.circle_outlined, color: const Color(0xFFE8E0D5), size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
