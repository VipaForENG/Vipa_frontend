import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../design/app_colors.dart';
import '../../models/learning_history_models.dart';
import 'learning_history_provider.dart';
import 'script_detail_screen.dart';

enum HistoryDetailType {
  correctedSentences,
  scenario,
  bookmarkedSentences,
  wrongWords,
}

class LearningHistoryScreen extends StatelessWidget {
  const LearningHistoryScreen({super.key, this.initialDetailType});

  final HistoryDetailType? initialDetailType;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LearningHistoryProvider()..loadHistory(),
      child: _LearningHistoryContent(initialDetailType: initialDetailType),
    );
  }
}

class _LearningHistoryContent extends StatefulWidget {
  const _LearningHistoryContent({this.initialDetailType});

  final HistoryDetailType? initialDetailType;

  @override
  State<_LearningHistoryContent> createState() => _LearningHistoryContentState();
}

class _LearningHistoryContentState extends State<_LearningHistoryContent> {
  late HistoryDetailType? _detailType;

  @override
  void initState() {
    super.initState();
    _detailType = widget.initialDetailType;
  }

  String get _title => switch (_detailType) {
    HistoryDetailType.correctedSentences => 'AI가 교정한 문장',
    HistoryDetailType.scenario => '상황별 시나리오',
    HistoryDetailType.bookmarkedSentences => '즐겨찾기한 문장',
    HistoryDetailType.wrongWords => '오답 단어',
    null => '학습내역',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningHistoryProvider>();

    return PopScope(
      canPop: _detailType == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _detailType != null) {
          setState(() => _detailType = null);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: _detailType == null
              ? null
              : IconButton(
                  onPressed: () => setState(() => _detailType = null),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
          title: Text(
            _title,
            style: TextStyle(
              color: _detailType == null ? AppColors.primary : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: RefreshIndicator(
                onRefresh: provider.loadHistory,
                color: AppColors.primary,
                child: _body(provider),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(LearningHistoryProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (provider.errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 160),
          Center(child: Text(provider.errorMessage!)),
        ],
      );
    }

    return switch (_detailType) {
      HistoryDetailType.correctedSentences => _SessionList(
        sessions: provider.recentSessions,
        provider: provider,
      ),
      HistoryDetailType.scenario => _SessionList(
        sessions: provider.recentSessions,
        provider: provider,
      ),
      HistoryDetailType.bookmarkedSentences => _BookmarkedList(
        items: provider.bookmarkedSentences,
      ),
      HistoryDetailType.wrongWords => _WrongWordList(items: provider.wrongWords),
      null => _mainDashboard(provider),
    };
  }

  Widget _mainDashboard(LearningHistoryProvider provider) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
      children: [
        const _SimpleSectionTitle(title: '실전회화'),
        const SizedBox(height: 8),
        _SimpleHistoryButton(
          title: '상황별 시나리오',
          onTap: () => setState(() => _detailType = HistoryDetailType.scenario),
        ),
        const SizedBox(height: 22),
        const _SimpleSectionTitle(title: '오늘의 어휘'),
        const SizedBox(height: 8),
        _SimpleHistoryButton(
          title: '즐겨찾기한 문장',
          onTap: () => setState(
            () => _detailType = HistoryDetailType.bookmarkedSentences,
          ),
        ),
        const SizedBox(height: 8),
        _SimpleHistoryButton(
          title: '오답 단어',
          onTap: () => setState(() => _detailType = HistoryDetailType.wrongWords),
        ),
      ],
    );
  }
}

class _SimpleSectionTitle extends StatelessWidget {
  const _SimpleSectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SimpleHistoryButton extends StatelessWidget {
  const _SimpleHistoryButton({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({
    required this.sessions,
    required this.provider,
  });

  final List<RecentConversationSession> sessions;
  final LearningHistoryProvider provider;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const _EmptyHistory(text: '학습한 회화 세션이 없습니다.');
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
      itemCount: sessions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = sessions[index];
        return _DetailCard(
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
        );
      },
    );
  }
}

class _BookmarkedList extends StatelessWidget {
  const _BookmarkedList({required this.items});

  final List<BookmarkedSentenceItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyHistory(text: '즐겨찾기한 문장이 없습니다.');
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final item = items[index];
        return _DetailCard(
          title: item.expression.isEmpty ? item.targetWord : item.expression,
          subtitle: item.meaning,
          leading: const Icon(Icons.star_rounded, color: AppColors.primary),
        );
      },
    );
  }
}

class _WrongWordList extends StatelessWidget {
  const _WrongWordList({required this.items});

  final List<WrongVocabularyItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyHistory(text: '오답 단어가 없습니다.');
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final item = items[index];
        return _DetailCard(
          title: item.targetWord,
          subtitle: '오답 ${item.incorrectCount}회',
        );
      },
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 88),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFB7B7B7),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 150),
        Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatDateTime(DateTime? date) {
  if (date == null) return '';
  return DateFormat('yyyy.MM.dd HH:mm').format(date.toLocal());
}
