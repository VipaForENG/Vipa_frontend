import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// 도메인 모델 및 프로바이더 (데이터 처리 담당)
import '../../models/learning_history_models.dart';
import 'learning_history_provider.dart';
import 'script_detail_screen.dart';

// UI 디자인 시스템 및 색상 (vipa_front-dev 브랜치 반영)
import '../../design/card_design.dart';
import '../../design/app_colors.dart';
import '../login/auth_widgets.dart'; // AuthColors 대체용

/// 사용자의 전체 학습 내역을 보여주는 메인 스크린 위젯입니다.
/// [ChangeNotifierProvider]를 최상위에 배치하여 하위 위젯들이 학습 데이터 상태를 구독하게 합니다.
class LearningHistoryScreen extends StatelessWidget {
  const LearningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 화면 빌드 시 Provider를 생성하고, 즉시 loadHistory()를 호출해 초기 데이터를 가져옵니다.
    return ChangeNotifierProvider(
      create: (_) => LearningHistoryProvider()..loadHistory(),
      child: const _LearningHistoryContent(),
    );
  }
}

/// 현재 화면의 세부 보기 상태를 정의하는 열거형입니다.
/// 이 값에 따라 대시보드를 보여줄지, 특정 항목의 상세 리스트를 보여줄지 결정합니다.
enum _HistoryDetailType {
  correctedSentences,  // AI가 교정한 문장
  scenario,            // 상황별 시나리오
  bookmarkedSentences, // 즐겨찾기한 문장
  wrongWords,          // 오답 단어
}

/// 카드 리스트에 들어갈 개별 아이템의 데이터 모델입니다.
class _CategoryItem {
  final String title;
  final _HistoryDetailType type;

  _CategoryItem(this.title, this.type);
}

/// 학습 내역의 실제 화면(UI)을 구성하는 상태 기반 위젯입니다.
class _LearningHistoryContent extends StatefulWidget {
  const _LearningHistoryContent();

  @override
  State<_LearningHistoryContent> createState() => _LearningHistoryContentState();
}

class _LearningHistoryContentState extends State<_LearningHistoryContent> {
  // 현재 선택된 상세 보기 타입입니다. null일 경우 메인 대시보드를 보여줍니다.
  _HistoryDetailType? _detailType;

  /// 상세 보기 상태를 변경하는 함수입니다.
  void _setDetailType(_HistoryDetailType? type) {
    setState(() => _detailType = type);
  }

  @override
  Widget build(BuildContext context) {
    // Provider의 상태를 구독하여 데이터 로딩, 에러, 완료 상태에 따라 UI를 갱신합니다.
    final provider = context.watch<LearningHistoryProvider>();

    // PopScope: 안드로이드 뒤로가기 버튼이나 스와이프 제스처 발생 시 동작을 제어합니다.
    // (WillPopScope의 최신 대체제로서 라우팅 안전성과 메모리 관리에 유리합니다)
    return PopScope(
      // _detailType이 null(메인 화면)일 때만 실제 pop(화면 종료)을 허용합니다.
      canPop: _detailType == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // 이미 pop 된 경우 무시
        if (_detailType != null) {
          // 상세 화면인 경우 뒤로가기를 누르면 메인 대시보드로 돌아갑니다.
          _setDetailType(null);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              // 태블릿 등 넓은 화면에서도 UI가 깨지지 않도록 최대 너비를 제한합니다.
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

  /// 상단 앱바를 구성하는 함수입니다. 상태에 따라 타이틀과 뒤로가기 동작이 변경됩니다.
  AppBar _buildAppBar(BuildContext context) {
    // 상세 화면일 경우 해당 타이틀을, 아니면 기본 타이틀을 사용합니다.
    String title = '학습내역';
    if (_detailType == _HistoryDetailType.correctedSentences) title = 'AI가 교정한 문장';
    if (_detailType == _HistoryDetailType.scenario) title = '상황별 시나리오';
    if (_detailType == _HistoryDetailType.bookmarkedSentences) title = '즐겨찾기한 문장';
    if (_detailType == _HistoryDetailType.wrongWords) title = '오답 단어';

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () {
          // 상세 화면이면 메인으로, 메인이면 이전 스크린으로 이동합니다.
          if (_detailType != null) {
            _setDetailType(null);
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Provider의 상태(로딩, 에러)와 _detailType에 따라 메인 콘텐츠를 분기 처리합니다.
  Widget _buildBody(BuildContext context, LearningHistoryProvider provider) {
    // 1. 로딩 중
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AuthColors.primary),
      );
    }

    // 2. 에러 발생 시
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

    // 3. 상세 리스트 화면 (상태값 존재 시)
    if (_detailType == _HistoryDetailType.correctedSentences) {
      return _HistoryListWidget(
        items: _conversationItems(context, provider),
        emptyText: '교정된 회화 문장이 없습니다.',
      );
    }
    if (_detailType == _HistoryDetailType.scenario) {
      return _HistoryListWidget(
        items: _scenarioItems(context, provider),
        emptyText: '최근 대화 세션이 없습니다.',
        showPdfIcon: true,
      );
    }
    if (_detailType == _HistoryDetailType.bookmarkedSentences) {
      return _HistoryListWidget(
        items: _bookmarkedItems(provider),
        emptyText: '즐겨찾기한 문장이 없습니다.',
      );
    }
    if (_detailType == _HistoryDetailType.wrongWords) {
      return _HistoryListWidget(
        items: _wrongWordItems(provider),
        emptyText: '누적 오답 단어가 없습니다.',
      );
    }

    // 4. 메인 대시보드 화면 (vipa_front-dev 디자인 적용)
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '내가 학습한 내역',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),

        // 실전회화 섹션 (디자인의 cardContainer 활용)
        cardContainer(
          child: _buildCategoryContent(
            title: '실전회화',
            icon: Icons.chat_bubble_rounded,
            color: Colors.blueAccent,
            items: [
              _CategoryItem('최근 대화한 상황별 세션', _HistoryDetailType.scenario),
              _CategoryItem('AI 교정 받은 문장 리스트', _HistoryDetailType.correctedSentences),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // 오늘의 어휘 섹션
        cardContainer(
          child: _buildCategoryContent(
            title: '오늘의 어휘',
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFF7B61FF),
            items: [
              _CategoryItem('즐겨찾기한 문장', _HistoryDetailType.bookmarkedSentences),
              _CategoryItem('오답 단어 다시 보기', _HistoryDetailType.wrongWords),
            ],
          ),
        ),
      ],
    );
  }

  /// 카드 내부의 카테고리별 콘텐츠를 구성합니다.
  Widget _buildCategoryContent({
    required String title,
    required IconData icon,
    required Color color,
    required List<_CategoryItem> items,
  }) {
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
                  // 호환성을 위해 withValues(alpha: ...) 대신 withOpacity를 사용했습니다.
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(thickness: 1, color: Color(0xFFF1F1F1)),
          const SizedBox(height: 10),
          // map을 사용하여 리스트의 각 아이템 위젯을 생성합니다.
          ...items.map((item) => _buildListItem(item)),
        ],
      ),
    );
  }

  /// 개별 메뉴 아이템 렌더링 함수입니다. 탭 이벤트를 연결합니다.
  Widget _buildListItem(_CategoryItem item) {
    return InkWell(
      onTap: () => _setDetailType(item.type),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: Colors.grey.shade300,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 이하 상세 리스트 관련 위젯 및 데이터 매핑 함수들 (기존 HEAD 로직 최적화)
// -----------------------------------------------------------------------------

/// 타일 클릭 이벤트와 텍스트를 담아두기 위한 데이터 클래스입니다.
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

/// 상세 데이터 리스트를 렌더링하는 위젯입니다.
/// (기존 Column 래핑을 제거하고 순수 ListView로 구조를 평탄화하여 렌더링 최적화 진행)
class _HistoryListWidget extends StatelessWidget {
  const _HistoryListWidget({
    required this.items,
    required this.emptyText,
    this.showPdfIcon = false,
  });

  final List<_HistoryTileData> items;
  final String emptyText;
  final bool showPdfIcon;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              emptyText,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 32),
      itemBuilder: (context, index) => _HistoryTile(
        item: items[index],
        showPdfIcon: showPdfIcon,
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemCount: items.length,
    );
  }
}

/// 개별 데이터의 형태를 출력하는 타일(카드) 형태의 위젯입니다.
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
              color: Colors.black.withValues(alpha: 0.14),
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

// -----------------------------------------------------------------------------
// Provider 데이터를 UI 모델(_HistoryTileData)로 변환하는 Helper 함수들
// -----------------------------------------------------------------------------

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

/// 날짜 객체를 보기 편한 형태(예: 2026.06.08 14:30)로 포매팅하는 유틸리티 함수입니다.
String _formatDateTime(DateTime? date) {
  if (date == null) return '날짜 없음';
  return DateFormat('yyyy.MM.dd HH:mm').format(date.toLocal());
}