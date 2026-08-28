import 'package:flutter_test/flutter_test.dart';
import 'package:vipa/models/level_test_model.dart';

void main() {
  group('VIPA Frontend Unit Tests', () {
    test('LevelTestResult JSON deserialization test', () {
      final json = {
        'cefr_level': 'B2',
        'overall_score': 85.5,
        'weakness_tags': '시제오류, 전치사미숙',
        'raw_analysis_json': {
          'grammar_score': 80,
          'vocabulary_score': 90,
          'detailed_feedback': '우수한 어휘력을 보유하고 있습니다.',
          'correct_answers_count': 17,
        }
      };

      final result = LevelTestResult.fromJson(json);

      expect(result.cefrLevel, 'B2');
      expect(result.overallScore, 85.5);
      expect(result.weaknessTags.length, 2);
      expect(result.grammarScore, 80);
      expect(result.vocabularyScore, 90);
      expect(result.correctAnswersCount, 17);
    });
  });
}
