import 'package:flutter/material.dart';
import 'knowledge_screen.dart';
import 'shelter_screen.dart';
import 'sos_screen.dart';
import 'health_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _bg = Color(0xFFF7F3EC);
  static const _card = Color(0xFFFEFDF9);
  static const _textPrimary = Color(0xFF3D2C1E);
  static const _textSecondary = Color(0xFF8C7B6E);
  static const _sosRed = Color(0xFFC4553A);

  // 目前狀態：0=安全, 1=需要協助, 2=緊急
  int _statusIndex = 0;

  static const _statusOptions = [
    {'label': '安全',    'color': Color(0xFF7AA67A), 'dotColor': Color(0xFF7AA67A), 'textColor': Color(0xFF4A7A4A), 'icon': Icons.check_circle_outline},
    {'label': '需要協助', 'color': Color(0xFFD4945A), 'dotColor': Color(0xFFD4945A), 'textColor': Color(0xFF8B4A00), 'icon': Icons.pan_tool_alt_outlined},
    {'label': '緊急',    'color': Color(0xFFC4553A), 'dotColor': Color(0xFFC4553A), 'textColor': Color(0xFFB52A10), 'icon': Icons.warning_amber_rounded},
  ];

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Color(0xFFFEFDF9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('更新目前狀態', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF3D2C1E))),
            const SizedBox(height: 16),
            ..._statusOptions.asMap().entries.map((e) {
              final i = e.key;
              final opt = e.value;
              final isSelected = _statusIndex == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _statusIndex = i);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? (opt['color'] as Color).withValues(alpha: 0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? (opt['color'] as Color) : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(opt['icon'] as IconData, color: opt['color'] as Color, size: 22),
                      const SizedBox(width: 12),
                      Text(opt['label'] as String,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: opt['textColor'] as Color)),
                      if (isSelected) ...[const Spacer(), Icon(Icons.check, color: opt['color'] as Color, size: 18)],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': '防災知識',
        'sub': '學習應急技能',
        'icon': Icons.auto_stories_rounded,
        'color': const Color(0xFF7AA67A),
        'screen': const KnowledgeScreen(),
      },
      {
        'title': '防空洞地圖',
        'sub': '附近避難所',
        'icon': Icons.location_on_rounded,
        'color': const Color(0xFF6B9EAD),
        'screen': const ShelterScreen(),
      },
      {
        'title': '健康回報',
        'sub': '回報您的狀況',
        'icon': Icons.favorite_rounded,
        'color': const Color(0xFFBF7A5A),
        'screen': const HealthScreen(),
      },
      {
        'title': '聊天室',
        'sub': '互助聯絡',
        'icon': Icons.chat_bubble_rounded,
        'color': const Color(0xFF9B88B3),
        'screen': const ChatScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 手工感 AppBar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _sosRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shield_rounded, color: _sosRed, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '防災 APP',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.more_horiz, color: _textSecondary),
                  ],
                ),
              ),
            ),

            // 歡迎語
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '平安是福',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '做好準備，守護自己與家人',
                      style: TextStyle(fontSize: 14, color: _textSecondary),
                    ),
                    const SizedBox(height: 16),
                    // 狀態橫幅（可點擊）
                    GestureDetector(
                      onTap: _showStatusPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: (_statusOptions[_statusIndex]['color'] as Color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (_statusOptions[_statusIndex]['color'] as Color).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _statusOptions[_statusIndex]['dotColor'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '目前狀態：${_statusOptions[_statusIndex]['label']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _statusOptions[_statusIndex]['textColor'] as Color,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '更新狀態 →',
                              style: TextStyle(
                                fontSize: 12,
                                color: (_statusOptions[_statusIndex]['color'] as Color).withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 功能卡片格
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        '功能選單',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.05,
                      children: features.map((f) {
                        final color = f['color'] as Color;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => f['screen'] as Widget),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3D2C1E).withValues(alpha: 0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // 右上角裝飾圓
                                Positioned(
                                  right: -14,
                                  top: -14,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color.withValues(alpha: 0.08),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(f['icon'] as IconData, color: color, size: 24),
                                      ),
                                      const Spacer(),
                                      Text(
                                        f['title'] as String,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: _textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        f['sub'] as String,
                                        style: TextStyle(fontSize: 11, color: _textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // SOS 按鈕
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SOSScreen()),
                  ),
                  child: Container(
                    height: 68,
                    decoration: BoxDecoration(
                      color: _sosRed,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _sosRed.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.sos_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'SOS  緊急求救',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
