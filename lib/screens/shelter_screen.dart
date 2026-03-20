import 'package:flutter/material.dart';

class ShelterService {
  List<Map<String, dynamic>> shelters = [
    {'name': '埔里地下停車場', 'lat': 23.964, 'lng': 120.967, 'capacity': '500 人', 'distance': '0.3 km', 'status': '開放中'},
    {'name': '南投縣政府防空洞', 'lat': 23.960, 'lng': 120.972, 'capacity': '300 人', 'distance': '0.7 km', 'status': '開放中'},
    {'name': '埔里鎮公所地下室', 'lat': 23.961, 'lng': 120.969, 'capacity': '200 人', 'distance': '1.1 km', 'status': '開放中'},
    {'name': '埔里國中地下室', 'lat': 23.967, 'lng': 120.965, 'capacity': '400 人', 'distance': '1.4 km', 'status': '即將滿員'},
    {'name': '愛蘭國小避難所', 'lat': 23.955, 'lng': 120.970, 'capacity': '250 人', 'distance': '2.0 km', 'status': '開放中'},
  ];

  List<Map<String, dynamic>> getShelters() => shelters;
}

class ShelterScreen extends StatelessWidget {
  const ShelterScreen({super.key});

  static const _bg = Color(0xFFF7F3EC);
  static const _card = Color(0xFFFEFDF9);
  static const _textPrimary = Color(0xFF3D2C1E);
  static const _textSecondary = Color(0xFF8C7B6E);
  static const _green = Color(0xFF7AA67A);

  @override
  Widget build(BuildContext context) {
    final shelters = ShelterService().getShelters();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('防空洞地圖'),
        iconTheme: const IconThemeData(color: _textPrimary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 摘要卡
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3D2C1E).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shield_rounded, color: _green, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '附近共 ${shelters.length} 個避難所',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary),
                        ),
                        Text('依距離由近至遠排列', style: TextStyle(fontSize: 12, color: _textSecondary)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('即時更新', style: TextStyle(fontSize: 11, color: _green, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 清單
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: shelters.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final s = shelters[index];
                  final isFull = s['status'] == '即將滿員';
                  final statusColor = isFull ? const Color(0xFFBF7A5A) : _green;

                  return GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('導航至：${s["name"]}'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFF5C3D2E),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3D2C1E).withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 編號圓
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _green.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _green,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s['name'] as String,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.people_outline_rounded, size: 13, color: _textSecondary),
                                    const SizedBox(width: 3),
                                    Text(s['capacity'] as String, style: TextStyle(fontSize: 12, color: _textSecondary)),
                                    const SizedBox(width: 12),
                                    Icon(Icons.near_me_rounded, size: 13, color: _textSecondary),
                                    const SizedBox(width: 3),
                                    Text(s['distance'] as String, style: TextStyle(fontSize: 12, color: _textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  s['status'] as String,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.directions_rounded, size: 14, color: _textSecondary),
                                  const SizedBox(width: 3),
                                  Text('導航', style: TextStyle(fontSize: 12, color: _textSecondary)),
                                ],
                              ),
                            ],
                          ),
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
    );
  }
}
