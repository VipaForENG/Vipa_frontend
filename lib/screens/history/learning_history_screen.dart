import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../design/card_design.dart';
import 'learning_history_provider.dart';

// ✨ 분리해둔 스크립트 상세 화면 파일을 불러옵니다.
import 'script_detail_screen.dart'; 
import '../../models/learning_history_models.dart'; // ✨ 모델 임포트

class LearningHistoryScreen extends StatelessWidget {
  const LearningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LearningHistoryProvider()..loadHistory(),
      child: const _LearningHistoryView(),
    );
  }
}

class _LearningHistoryView extends StatelessWidget {
  const _LearningHistoryView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningHistoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('학습내역', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadHistory,
        child: _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LearningHistoryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline, size: 42, color: Colors.grey.shade500),
          const SizedBox(height: 12),
          Center(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
          child: Text(
            '내가 학습한 내역',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        cardContainer(
          child: _HistorySection(
            title: '실전회화',
            icon: Icons.chat_bubble_rounded,
            color: Colors.blueAccent,
            children: [
              _HistoryMenuButton(
                title: '최근 대화한 스크립트',
                countText: '${provider.recentSessions.length}개',
                icon: Icons.forum_rounded,
                onTap: () => _openDetail(
                  context,
                  '최근 대화한 상황별 세션',
                  _singleGroup(
                    provider.recentSessions.map(
                      (item) => _HistoryTileData(
                        icon: Icons.forum_rounded,
                        title: item.scenarioTitle,
                        subtitle: '${item.category} · ${_formatDateTime(item.createdAt)}',
                        onTap: () {
                          // ✨ 연결된 새 파일(ScriptDetailScreen)로 화면 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScriptDetailScreen(
                                sessionId: item.sessionId,
                                provider: provider, 
                              ),
                            ),
                          );
                        },
                      ),
                    ).toList(),
                  ),
                  '최근 대화 세션이 없습니다.',
                ),
              ),
            ],
          ),
        ),
        cardContainer(
          child: _HistorySection(
            title: '오늘의 어휘',
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFF7B61FF),
            children: [
              _HistoryMenuButton(
                title: '일별 퀴즈 완료 기록',
                countText: _dailyCountText(provider.dailyStats),
                icon: Icons.fact_check_rounded,
                onTap: () => _openDetail(
                  context,
                  '일별 퀴즈 완료 기록',
                  _singleGroup(_dailyStatsItems(provider.dailyStats)),
                  '오늘 완료한 퀴즈 기록이 없습니다.',
                ),
              ),
              _HistoryMenuButton(
                title: '오답 단어 리스트',
                countText: '${provider.wrongWords.length}개',
                icon: Icons.refresh_rounded,
                onTap: () => _openDetail(
                  context,
                  '오답 단어 리스트',
                  _singleGroup(
                    provider.wrongWords.map(
                      (item) => _HistoryTileData(
                        icon: Icons.refresh_rounded,
                        title: item.targetWord,
                        subtitle: item.meaning.isEmpty
                            ? '오답 ${item.incorrectCount}회'
                            : '${item.meaning} · 오답 ${item.incorrectCount}회',
                      ),
                    ).toList(),
                  ),
                  '누적 오답 단어가 없습니다.',
                ),
              ),
              _HistoryMenuButton(
                title: '즐겨찾기한 문장',
                countText: '${provider.bookmarkedSentences.length}개',
                icon: Icons.star_rounded,
                onTap: () => _openDetail(
                  context,
                  '즐겨찾기한 문장',
                  _singleGroup(
                    provider.bookmarkedSentences.map(
                      (item) => _HistoryTileData(
                        icon: Icons.star_rounded,
                        title: item.expression.isEmpty ? item.targetWord : item.expression,
                        subtitle: item.meaning,
                      ),
                    ).toList(),
                  ),
                  '즐겨찾기한 문장이 없습니다.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openDetail(BuildContext context, String title, List<_HistoryGroup> groups, String emptyText) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _HistoryDetailScreen(
          title: title,
          groups: groups,
          emptyText: emptyText,
        ),
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _HistorySection({required this.title, required this.icon, required this.color, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(thickness: 1, color: Color(0xFFF1F1F1)),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}

class _HistoryMenuButton extends StatelessWidget {
  final String title;
  final String countText;
  final IconData icon;
  final VoidCallback onTap;

  const _HistoryMenuButton({required this.title, required this.countText, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade500),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
            ),
            Text(countText, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _HistoryDetailScreen extends StatelessWidget {
  final String title;
  final List<_HistoryGroup> groups;
  final String emptyText;

  const _HistoryDetailScreen({required this.title, required this.groups, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    final visibleGroups = groups.where((group) => group.items.isNotEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          if (visibleGroups.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Center(child: Text(emptyText, style: TextStyle(fontSize: 15, color: Colors.grey.shade600))),
            )
          else
            ...visibleGroups.map((group) {
              return cardContainer(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (group.title != null) ...[
                        Text(group.title!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: Color(0xFFEAEAEA)),
                        const SizedBox(height: 8),
                      ],
                      ...group.items.map((item) => _HistoryTile(item: item)),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _HistoryGroup {
  final String? title;
  final List<_HistoryTileData> items;
  const _HistoryGroup({required this.title, required this.items});
}

class _HistoryTileData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap; 

  const _HistoryTileData({required this.icon, required this.title, required this.subtitle, this.onTap});
}

class _HistoryTile extends StatelessWidget {
  final _HistoryTileData item;

  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell( 
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title.isEmpty ? '내용 없음' : item.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(item.subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  ],
                ],
              ),
            ),
            if (item.onTap != null) 
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade300)
          ],
        ),
      ),
    );
  }
}

List<_HistoryGroup> _singleGroup(List<_HistoryTileData> items) {
  return [if (items.isNotEmpty) _HistoryGroup(title: null, items: items)];
}

String _dailyCountText(DailyVocabularyStats? stats) {
  if (stats == null || stats.totalQuizzesToday == 0) return '0개';
  return '${stats.totalQuizzesToday}문제';
}

List<_HistoryTileData> _dailyStatsItems(DailyVocabularyStats? stats) {
  if (stats == null || stats.totalQuizzesToday == 0) return [];
  return [
    _HistoryTileData(
      icon: Icons.fact_check_rounded,
      title: '${stats.totalQuizzesToday}문제 완료',
      subtitle: '정답 ${stats.correctQuizzesToday}개 · 정확도 ${stats.accuracyRate.toStringAsFixed(1)}%',
    ),
  ];
}

String _formatDateTime(DateTime? date) {
  if (date == null) return '날짜 없음';
  return DateFormat('yyyy.MM.dd HH:mm').format(date.toLocal());
}