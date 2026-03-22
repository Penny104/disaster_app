import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ── 防空洞資料模型 ──────────────────────────────────────────
class Shelter {
  final String name;
  final double lat;
  final double lng;
  final String capacity;
  final String status;

  Shelter({
    required this.name,
    required this.lat,
    required this.lng,
    required this.capacity,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': lat,
        'lng': lng,
        'capacity': capacity,
        'status': status,
      };

  factory Shelter.fromJson(Map<String, dynamic> json) => Shelter(
        name: json['name'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        capacity: json['capacity'] as String,
        status: json['status'] as String,
      );
}

// ── 模擬伺服器資料（實際上線時替換為 API 呼叫）──────────────
final _serverShelters = [
  Shelter(name: '埔里地下停車場', lat: 23.964, lng: 120.967, capacity: '500 人', status: '開放中'),
  Shelter(name: '南投縣政府防空洞', lat: 23.960, lng: 120.972, capacity: '300 人', status: '開放中'),
  Shelter(name: '埔里鎮公所地下室', lat: 23.961, lng: 120.969, capacity: '200 人', status: '開放中'),
  Shelter(name: '埔里國中地下室', lat: 23.967, lng: 120.965, capacity: '400 人', status: '即將滿員'),
  Shelter(name: '愛蘭國小避難所', lat: 23.955, lng: 120.970, capacity: '250 人', status: '開放中'),
];

const _prefsKeyShelters = 'offline_shelters';
const _prefsKeyUpdatedAt = 'shelters_updated_at';

// ── 主畫面 ─────────────────────────────────────────────────
class ShelterScreen extends StatefulWidget {
  const ShelterScreen({super.key});

  @override
  State<ShelterScreen> createState() => _ShelterScreenState();
}

class _ShelterScreenState extends State<ShelterScreen> {
  static const _bg = Color(0xFFF7F3EC);
  static const _card = Color(0xFFFEFDF9);
  static const _textPrimary = Color(0xFF3D2C1E);
  static const _textSecondary = Color(0xFF8C7B6E);
  static const _green = Color(0xFF7AA67A);
  static const _orange = Color(0xFFBF7A5A);

  bool _isOnline = false;
  bool _isLoading = true;
  bool _isSaving = false;
  List<Shelter> _shelters = [];
  String? _lastUpdatedAt;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final result = await Connectivity().checkConnectivity();
    final online = result.any((r) => r != ConnectivityResult.none);

    if (online) {
      // 有網路：從伺服器取得最新資料
      await _loadOnlineData();
    } else {
      // 無網路：讀取上次下載的快取
      await _loadOfflineData();
    }

    setState(() {
      _isOnline = online;
      _isLoading = false;
    });
  }

  Future<void> _loadOnlineData() async {
    // TODO: 替換為實際 API 呼叫，例如 http.get(Uri.parse('https://your-api/shelters'))
    await Future.delayed(const Duration(milliseconds: 500)); // 模擬網路延遲
    _shelters = List.from(_serverShelters);
  }

  Future<void> _loadOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKeyShelters);
    _lastUpdatedAt = prefs.getString(_prefsKeyUpdatedAt);

    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _shelters = list.map((e) => Shelter.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  // 下載並儲存離線地圖資料
  Future<void> _downloadOfflineMap() async {
    setState(() => _isSaving = true);
    await _loadOnlineData(); // 確保取得最新資料

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final nowStr =
        '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    await prefs.setString(
      _prefsKeyShelters,
      jsonEncode(_shelters.map((s) => s.toJson()).toList()),
    );
    await prefs.setString(_prefsKeyUpdatedAt, nowStr);

    setState(() {
      _isSaving = false;
      _lastUpdatedAt = nowStr;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('離線地圖已儲存，無網路時仍可查閱'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFF5C3D2E),
        ),
      );
    }
  }

  // 開啟 GPS 導航（需網路）
  Future<void> _openNavigation(Shelter shelter) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${shelter.lat},${shelter.lng}&travelmode=walking',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('無法開啟地圖，請確認已安裝地圖應用程式'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('防空洞地圖'),
        iconTheme: const IconThemeData(color: _textPrimary),
        actions: [
          if (_isOnline)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _isSaving
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      icon: const Icon(Icons.download_rounded, color: _green),
                      tooltip: '下載離線地圖',
                      onPressed: _downloadOfflineMap,
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // ── 網路狀態橫幅 ──
                  _NetworkBanner(
                    isOnline: _isOnline,
                    lastUpdatedAt: _lastUpdatedAt,
                    onDownload: _isOnline ? _downloadOfflineMap : null,
                  ),

                  // ── 摘要卡 ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                                _shelters.isEmpty
                                    ? '尚無避難所資料'
                                    : '附近共 ${_shelters.length} 個避難所',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                ),
                              ),
                              Text(
                                _isOnline ? '線上資料・依距離由近至遠' : '離線資料・依距離由近至遠',
                                style: TextStyle(fontSize: 12, color: _textSecondary),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (_isOnline ? _green : _orange).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isOnline ? '即時更新' : '離線模式',
                              style: TextStyle(
                                fontSize: 11,
                                color: _isOnline ? _green : _orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── 無資料提示 ──
                  if (_shelters.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off_rounded, size: 52, color: _textSecondary.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text(
                              '尚未下載離線地圖',
                              style: TextStyle(fontSize: 15, color: _textSecondary),
                            ),
                            Text(
                              '請連上網路後點選右上角下載圖示',
                              style: TextStyle(fontSize: 13, color: _textSecondary.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // ── 避難所清單 ──
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: _shelters.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final s = _shelters[index];
                          final isFull = s.status == '即將滿員';
                          final statusColor = isFull ? _orange : _green;

                          return Container(
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
                                        s.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: _textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.people_outline_rounded, size: 13, color: _textSecondary),
                                          const SizedBox(width: 3),
                                          Text(s.capacity, style: TextStyle(fontSize: 12, color: _textSecondary)),
                                          const SizedBox(width: 10),
                                          Icon(Icons.location_on_outlined, size: 13, color: _textSecondary),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${s.lat.toStringAsFixed(3)}, ${s.lng.toStringAsFixed(3)}',
                                            style: TextStyle(fontSize: 11, color: _textSecondary),
                                          ),
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
                                        s.status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // 導航按鈕：有網路才可點
                                    GestureDetector(
                                      onTap: _isOnline ? () => _openNavigation(s) : null,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.directions_rounded,
                                            size: 14,
                                            color: _isOnline ? _green : _textSecondary.withValues(alpha: 0.35),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '導航',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _isOnline ? _green : _textSecondary.withValues(alpha: 0.35),
                                              fontWeight: _isOnline ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

// ── 網路狀態橫幅元件 ──────────────────────────────────────
class _NetworkBanner extends StatelessWidget {
  final bool isOnline;
  final String? lastUpdatedAt;
  final VoidCallback? onDownload;

  const _NetworkBanner({required this.isOnline, this.lastUpdatedAt, this.onDownload});

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      return Container(
        width: double.infinity,
        color: const Color(0xFF7AA67A).withValues(alpha: 0.12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.wifi_rounded, size: 15, color: Color(0xFF7AA67A)),
            const SizedBox(width: 6),
            const Text(
              '已連線・顯示最新防空洞位置',
              style: TextStyle(fontSize: 12, color: Color(0xFF5C8A5C), fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onDownload,
              child: const Row(
                children: [
                  Icon(Icons.download_rounded, size: 14, color: Color(0xFF7AA67A)),
                  SizedBox(width: 3),
                  Text(
                    '儲存離線版',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7AA67A), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        color: const Color(0xFFBF7A5A).withValues(alpha: 0.12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.wifi_off_rounded, size: 15, color: Color(0xFFBF7A5A)),
                SizedBox(width: 6),
                Text(
                  '無網路連線・顯示離線地圖（無法使用導航）',
                  style: TextStyle(fontSize: 12, color: Color(0xFFBF7A5A), fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (lastUpdatedAt != null)
              Padding(
                padding: const EdgeInsets.only(left: 21, top: 2),
                child: Text(
                  '上次更新：$lastUpdatedAt',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFBF7A5A)),
                ),
              ),
          ],
        ),
      );
    }
  }
}
