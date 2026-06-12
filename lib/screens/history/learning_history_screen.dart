import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// [의존성 임포트] 로직 및 UI 디자인 시스템 통합
// -----------------------------------------------------------------------------
import 'learning_history_provider.dart';
import 'script_detail_screen.dart';

// UI 디자인 시스템 및 색상 (팀원의 vipa_front-dev 브랜치 UI 반영)
import '../../design/card_design.dart';
import '../../design/app_colors.dart';

/// 현재 화면의 세부 보기 상태를 정의하는 열거형입니다.
/// 이 값에 따라 메인 대시보드를 보여줄지, 특정 항목의 상세 리스트를 보여줄지 결정합니다.
enum HistoryDetailType {
  correctedSentences, // AI가 교정한 문장
  scenario, // 상황별 시나리오
  bookmarkedSentences, // 즐겨찾기한 문장
  wrongWords, // 오답 단어
}

/// 사용자의 전체 학습 내역을 보여주는 메인 스크린 위젯입니다.
/// [ChangeNotifierProvider]를 최상위에 배치하여 하위 위젯들이 학습 데이터 상태를 구독하게 합니다.
class LearningHistoryScreen extends StatelessWidget {
  const LearningHistoryScreen({super.key, this.initialDetailType});

  final HistoryDetailType? initialDetailType;

  @override
  Widget build(BuildContext context) {
    // 화면 빌드 시 Provider를 생성하고, 즉시 loadHistory()를 호출해 초기 데이터를 서버나 로컬에서 가져옵니다.
    return ChangeNotifierProvider(
      create: (_) => LearningHistoryProvider()..loadHistory(),
      child: _LearningHistoryContent(initialDetailType: initialDetailType),
    );
  }
}

/// 학습 내역의 실제 화면(UI)을 구성하는 상태 기반 위젯입니다.
class _LearningHistoryContent extends StatefulWidget {
  const _LearningHistoryContent({this.initialDetailType});

  final HistoryDetailType? initialDetailType;

  @override
  State<_LearningHistoryContent> createState() =>
      _LearningHistoryContentState();
}

class _LearningHistoryContentState extends State<_LearningHistoryContent> {
  // 현재 선택된 상세 보기 타입입니다. null일 경우 기본 화면인 메인 대시보드를 보여줍니다.
  late HistoryDetailType? _detailType;

  @override
  void initState() {
    super.initState();
    _detailType = widget.initialDetailType;
  }

  /// 상세 보기 상태를 변경하는 함수입니다.
  /// 상태 변경 시 setState를 호출하여 UI를 해당 리스트 화면이나 대시보드로 리빌드합니다.
  void _setDetailType(HistoryDetailType? type) {
    setState(() => _detailType = type);
  }

  @override
  Widget build(BuildContext context) {
    // Provider의 상태를 구독합니다. 데이터 로딩, 에러, 완료 상태에 따라 화면이 갱신됩니다.
    final provider = context.watch<LearningHistoryProvider>();

    // PopScope: 안드로이드 뒤로가기 버튼이나 스와이프 제스처 발생 시 동작을 제어합니다.
    // 기존 라우팅 스택 메모리 누수를 방지하고, 상세 화면에서 바로 앱이 꺼지지 않도록 안전망을 제공합니다.
    return PopScope(
      // _detailType이 null(메인 화면)일 때만 실제 pop(이전 화면으로 돌아가기)을 허용합니다.
      canPop: _detailType == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // 이미 시스템에 의해 pop 된 경우 중복 실행 무시
        if (_detailType != null) {
          // 상세 화면인 경우 뒤로가기를 누르면 이전 화면이 아닌 메인 대시보드로 돌아가도록 상태를 초기화합니다.
          _setDetailType(null);
        }
      },
      child: Scaffold(
        // 팀원의 공통 디자인 시스템 배경색 적용
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              // 태블릿 등 넓은 화면에서도 UI 레이아웃이 깨지지 않도록 최대 너비를 430으로 제한합니다.
              constraints: const BoxConstraints(maxWidth: 430),
              child: RefreshIndicator(
                onRefresh: provider.loadHistory, // 당겨서 새로고침 기능 연결
                color: AppColors.primary,
                child: _buildBody(context, provider),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 상단 앱바를 구성하는 함수입니다.
  /// _detailType 상태에 따라 타이틀 문자열과 뒤로가기 동작 로직이 동적으로 변경됩니다.
  AppBar _buildAppBar(BuildContext context) {
    String title = '학습내역'; // 기본 타이틀
    // 현재 선택된 상세 타입에 맞게 타이틀 매핑
    if (_detailType == HistoryDetailType.correctedSentences) {
      title = 'AI가 교정한 문장';
    }
    if (_detailType == HistoryDetailType.scenario) title = '상황별 시나리오';
    if (_detailType == HistoryDetailType.bookmarkedSentences) {
      title = '즐겨찾기한 문장';
    }
    if (_detailType == HistoryDetailType.wrongWords) title = '오답 단어';

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
          // 뒤로가기 버튼 클릭 시: 상세 화면이면 메인 대시보드로, 메인이면 네비게이터 팝 수행
          if (_detailType != null) {
            _setDetailType(null);
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Provider의 데이터 상태(로딩/에러)와 _detailType에 따라 렌더링할 메인 콘텐츠를 분기 처리합니다.
  Widget _buildBody(BuildContext context, LearningHistoryProvider provider) {
    // 1. 데이터 로딩 중 화면
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // 2. 에러 발생 시 에러 메시지 화면
    if (provider.errorMessage != null) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(), // 새로고침이 가능하도록 스크롤 속성 강제 부여
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

    // 3. 상세 리스트 화면 (상태값이 null이 아닐 경우 해당 리스트 렌더링)
    if (_detailType == HistoryDetailType.correctedSentences) {
      return _HistoryListWidget(
        items: _conversationItems(context, provider),
        emptyText: '교정된 회화 문장이 없습니다.',
      );
    }
    if (_detailType == HistoryDetailType.scenario) {
      return _HistoryListWidget(
        items: _scenarioItems(context, provider),
        emptyText: '최근 대화 세션이 없습니다.',
        showPdfIcon: true,
      );
    }
    if (_detailType == HistoryDetailType.bookmarkedSentences) {
      return _HistoryListWidget(
        items: _bookmarkedItems(provider),
        emptyText: '즐겨찾기한 문장이 없습니다.',
      );
    }
    if (_detailType == HistoryDetailType.wrongWords) {
      return _HistoryListWidget(
        items: _wrongWordItems(provider),
        emptyText: '누적 오답 단어가 없습니다.',
      );
    }

    // 4. 메인 대시보드 화면 (상태값이 null일 경우)
    // 리더님의 로직 구조 + 팀원의 cardContainer 디자인 통합
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            '내가 학습한 내역',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        // [섹션 1] 실전회화 카테고리 (팀원의 cardContainer 래퍼 사용)
        cardContainer(
          child: _HistorySection(
            title: '실전회화',
            icon: Icons.chat_bubble_rounded,
            color: Colors.blueAccent,
            children: [
              _HistoryMenuButton(
                title: '최근 대화한 상황별 세션',
                countText:
                    '${provider.recentSessions.length}개', // Provider에서 갯수 동적 맵핑
                icon: Icons.forum_rounded,
                onTap: () => _setDetailType(HistoryDetailType.scenario),
              ),
              _HistoryMenuButton(
                title: 'AI 교정 받은 문장 리스트',
                countText: '', // 교정 문장 카운트가 Provider에 있다면 추가 가능
                icon: Icons.auto_fix_high_rounded,
                onTap: () =>
                    _setDetailType(HistoryDetailType.correctedSentences),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // [섹션 2] 오늘의 어휘 카테고리
        cardContainer(
          child: _HistorySection(
            title: '오늘의 어휘',
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFF7B61FF),
            children: [
              _HistoryMenuButton(
                title: '즐겨찾기한 문장',
                countText: '${provider.bookmarkedSentences.length}개',
                icon: Icons.star_rounded,
                onTap: () =>
                    _setDetailType(HistoryDetailType.bookmarkedSentences),
              ),
              _HistoryMenuButton(
                title: '오답 단어 다시 보기',
                countText: '${provider.wrongWords.length}개',
                icon: Icons.error_outline_rounded,
                onTap: () => _setDetailType(HistoryDetailType.wrongWords),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// [UI 컴포넌트] 대시보드 내부 구성 위젯 (팀원 디자인 코드 통합)
// -----------------------------------------------------------------------------

/// 카드 내부의 카테고리별 헤더 및 구분선을 포함하는 공통 섹션 래퍼 위젯입니다.
class _HistorySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _HistorySection({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

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
                  color: color.withValues(alpha: 0.1), // 투명도를 주어 부드러운 배경색 생성
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
          const Divider(thickness: 1, color: Color(0xFFF1F1F1)), // 항목 간 구분선
          const SizedBox(height: 10),
          ...children, // 전달받은 버튼 위젯 리스트를 전개(spread)하여 렌더링
        ],
      ),
    );
  }
}

/// 개별 메뉴 항목을 렌더링하는 버튼 위젯입니다. (아이콘, 타이틀, 갯수, 화살표 포함)
class _HistoryMenuButton extends StatelessWidget {
  final String title;
  final String countText;
  final IconData icon;
  final VoidCallback onTap; // 터치 시 실행될 콜백 (상태 변경용)

  const _HistoryMenuButton({
    required this.title,
    required this.countText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade500),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (countText.isNotEmpty)
              Text(
                countText,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// [리스트 UI 컴포넌트] 상세 데이터 렌더링 위젯 (리더님 렌더링 최적화 코드)
// -----------------------------------------------------------------------------

/// 타일 클릭 이벤트와 텍스트를 담아두기 위한 뷰-모델(View-Model) 데이터 클래스입니다.
/// Provider의 복잡한 데이터를 UI 렌더링에 필요한 정보만 추출하여 저장합니다.
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
/// ListView.separated를 사용하여 메모리를 절약하고(lazy-loading) 렌더링 속도를 최적화했습니다.
class _HistoryListWidget extends StatelessWidget {
  const _HistoryListWidget({
    required this.items,
    required this.emptyText,
    this.showPdfIcon = false,
  });

  final List<_HistoryTileData> items;
  final String emptyText; // 데이터가 없을 때 보여줄 안내 문구
  final bool showPdfIcon;

  @override
  Widget build(BuildContext context) {
    // 데이터가 비어있을 경우 예외 처리 UI
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
      itemBuilder: (context, index) =>
          _HistoryTile(item: items[index], showPdfIcon: showPdfIcon),
      separatorBuilder: (_, _) => const SizedBox(height: 14), // 타일 간 간격
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
              color: Colors.black.withValues(
                alpha: 0.14,
              ), // 그림자 효과 (withOpacity 사용 권장)
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
            // PDF 지원 여부에 따라 우측 아이콘 렌더링
            if (showPdfIcon)
              Container(
                width: 22,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
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
// [데이터 매핑 헬퍼 함수] Provider 데이터 -> UI 모델(_HistoryTileData) 변환
// -----------------------------------------------------------------------------

/// '교정된 회화 문장' 데이터를 리스트 아이템 형식으로 변환합니다.
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

/// '상황별 시나리오' 데이터를 리스트 아이템 형식으로 변환합니다.
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

/// '즐겨찾기한 문장' 데이터를 리스트 아이템 형식으로 변환합니다.
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

/// '오답 단어' 데이터를 리스트 아이템 형식으로 변환합니다.
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

/// 날짜(DateTime) 객체를 UI에 표시하기 좋은 포맷(예: 2026.06.08 14:30)으로 변환합니다.
String _formatDateTime(DateTime? date) {
  if (date == null) return '날짜 없음';
  return DateFormat('yyyy.MM.dd HH:mm').format(date.toLocal());
}
