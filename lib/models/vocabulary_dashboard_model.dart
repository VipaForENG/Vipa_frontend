class VocabularyDashboardModel {
  final int newWordsCount;
  final int reviewWordsCount;
  final int retryWordsCount;

  VocabularyDashboardModel({
    required this.newWordsCount,
    required this.reviewWordsCount,
    required this.retryWordsCount,
  });

  // 백엔드 JSON 데이터를 플러터 객체로 변환해 주는 마법의 함수
  factory VocabularyDashboardModel.fromJson(Map<String, dynamic> json) {
    return VocabularyDashboardModel(
      newWordsCount: json['new_words_count'] ?? 0,
      reviewWordsCount: json['review_words_count'] ?? 0,
      retryWordsCount: json['retry_words_count'] ?? 0,
    );
  }
}