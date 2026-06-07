import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/learning_history_models.dart';
import '../login/auth_widgets.dart';
import 'learning_history_provider.dart';
import 'script_detail_screen.dart';

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
    return const _LearningHistoryContent();
  }
}

class _LearningHistoryContent extends StatefulWidget {
  const _LearningHistoryContent();

  @override
  State<_LearningHistoryContent> createState() => _LearningHistoryContentState();
}

class _LearningHistoryContentState extends State<_LearningHistoryContent> {
  _HistoryDetailType? _detailType;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningHistoryProvider>();

    return WillPopScope(
      onWillPop: () async {
        if (_detailType != null) {
          setState(() => _detailType = null);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: RefreshIndicator(
                onRefresh: provider.loadHistory,
                color: AuthColors.primary,
                child: _buildBody(context, provider),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LearningHistoryProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AuthColors.primary),
      );
    }

    if (provider.errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ],
      );
    }

    if (_detailType == _HistoryDetailType.correctedSentences) {
      return _HistoryListPage(
        title: 'AI가 교정한 문장',
        items: _conversationItems(context, provider),
        emptyText: '교정된 회화 문장이 없습니다.',
      );
    }

    if (_detailType == _HistoryDetailType.scenario) {
      return _HistoryListPage(
        title: '상황별 시나리오',
        items: _scenarioItems(context, provider),
        emptyText: '최근 대화 세션이 없습니다.',
        showPdfIcon: true,
      );
    }

    if (_detailType == _HistoryDetailType.bookmarkedSentences) {
      return _HistoryListPage(
        title: '즐겨찾기한 문장',
        items: _bookmarkedItems(provider),
        emptyText: '즐겨찾기한 문장이 없습니다.',
      );
    }

    if (_detailType == _HistoryDetailType.wrongWords) {
      return _HistoryListPage(
        title: '오답 단어',
        items: _wrongWordItems(provider),
        emptyText: '누적 오답 단어가 없습니다.',
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 32),
      children: [
        const Center(
          child: Text(
            '학습 내역',
            style: TextStyle(
              color: AuthColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 42),
        const _HistorySectionTitle('실전회화'),
        const SizedBox(height: 13),
        _HistoryMenuButton(
          title: 'AI가 교정한 문장',
          onTap: () => setState(
            () => _detailType = _HistoryDetailType.correctedSentences,
          ),
        ),
        const SizedBox(height: 12),
        _HistoryMenuButton(
          title: '상황별 시나리오',
          onTap: () => setState(() => _detailType = _HistoryDetailType.scenario),
        ),
        const SizedBox(height: 28),
        const _HistorySectionTitle('오늘의 어휘'),
        const SizedBox(height: 13),
        _HistoryMenuButton(
          title: '즐겨찾기한 문장',
          onTap: () => setState(
            () => _detailType = _HistoryDetailType.bookmarkedSentences,
          ),
        ),
        const SizedBox(height: 12),
        _HistoryMenuButton(
          title: '오답 단어',
          onTap: () => setState(
            () => _detailType = _HistoryDetailType.wrongWords,
          ),
        ),
      ],
    );
  }
}

enum _HistoryDetailType {
  correctedSentences,
  scenario,
  bookmarkedSentences,
  wrongWords,
}

class _HistorySectionTitle extends StatelessWidget {
  const _HistorySectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HistoryMenuButton extends StatelessWidget {
  const _HistoryMenuButton({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _HistoryListPage extends StatelessWidget {
  const _HistoryListPage({
    required this.title,
    required this.items,
    required this.emptyText,
    this.showPdfIcon = false,
  });

  final String title;
  final List<_HistoryTileData> items;
  final String emptyText;
  final bool showPdfIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            color: AuthColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 28),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    emptyText,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 32),
                  itemBuilder: (context, index) => _HistoryTile(
                    item: items[index],
                    showPdfIcon: showPdfIcon,
                  ),
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemCount: items.length,
                ),
        ),
      ],
    );
  }
}

class _HistoryTileData {
  const _HistoryTileData({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item, this.showPdfIcon = false});

  final _HistoryTileData item;
  final bool showPdfIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.fromLTRB(20, 16, 18, 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title.isEmpty ? '내용 없음' : item.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showPdfIcon)
              Container(
                width: 22,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AuthColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  'PDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

List<_HistoryTileData> _conversationItems(
  BuildContext context,
  LearningHistoryProvider provider,
) {
  return provider.recentSessions
      .map(
        (item) => _HistoryTileData(
          title: item.scenarioTitle,
          subtitle: _formatDateTime(item.createdAt),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScriptDetailScreen(
                sessionId: item.sessionId,
                provider: provider,
              ),
            ),
          ),
        ),
      )
      .toList();
}

List<_HistoryTileData> _scenarioItems(
  BuildContext context,
  LearningHistoryProvider provider,
) {
  return provider.recentSessions
      .map(
        (item) => _HistoryTileData(
          title: item.scenarioTitle,
          subtitle: _formatDateTime(item.createdAt),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScriptDetailScreen(
                sessionId: item.sessionId,
                provider: provider,
              ),
            ),
          ),
        ),
      )
      .toList();
}

List<_HistoryTileData> _bookmarkedItems(LearningHistoryProvider provider) {
  return provider.bookmarkedSentences
      .map(
        (item) => _HistoryTileData(
          title: item.expression.isEmpty ? item.targetWord : item.expression,
          subtitle: item.meaning,
        ),
      )
      .toList();
}

List<_HistoryTileData> _wrongWordItems(LearningHistoryProvider provider) {
  return provider.wrongWords
      .map(
        (item) => _HistoryTileData(
          title: item.targetWord,
          subtitle: item.meaning.isEmpty
              ? '오답 ${item.incorrectCount}회'
              : '${item.meaning} · 오답 ${item.incorrectCount}회',
        ),
      )
      .toList();
}

String _formatDateTime(DateTime? date) {
  if (date == null) return '날짜 없음';
  return DateFormat('yyyy.MM.dd HH:mm').format(date.toLocal());
}
