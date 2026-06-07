import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// PDF 관련 패키지
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'learning_history_provider.dart';
import '../../models/learning_history_models.dart'; // ✨ 모델 임포트

class ScriptDetailScreen extends StatefulWidget {
  final int sessionId;
  final LearningHistoryProvider provider;

  const ScriptDetailScreen({super.key, required this.sessionId, required this.provider});

  @override
  State<ScriptDetailScreen> createState() => _ScriptDetailScreenState();
}

class _ScriptDetailScreenState extends State<ScriptDetailScreen> {
  ConversationScriptDetail? scriptData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScript();
  }

  Future<void> _loadScript() async {
  final data = await widget.provider.fetchSessionScript(widget.sessionId);
    debugPrint("🔍 디버그: AI 지문 데이터 확인 -> ${data?.aiPassageEn}"); // 이 로그가 찍히는지 확인
  setState(() {
    scriptData = data;
    isLoading = false;
  });
}

  // ✨ PDF 생성 및 공유 함수
  Future<void> _sharePDF() async {
    if (scriptData == null || scriptData!.fullTurns.isEmpty) return;
    
    final font = await PdfGoogleFonts.nanumGothicRegular();
    final boldFont = await PdfGoogleFonts.nanumGothicBold();
    
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('VIPA 회화 복습 스크립트', style: pw.TextStyle(font: boldFont, fontSize: 24, color: PdfColors.blue800)),
                  pw.SizedBox(height: 5),
                  pw.Text('시나리오: ${scriptData!.scenarioTitle}', style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey700)),
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 10),
                ]
              ),
            ),
            
            // ✨ 시나리오 전체 흐름을 PDF로 렌더링
            ...scriptData!.fullTurns.map((turn) {
              final isAi = turn['speaker'] == 'ai';
              final englishText = isAi ? (turn['en'] ?? '') : (turn['expected_en'] ?? '');
              final koreanText = turn['ko'] ?? '';

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: isAi ? pw.CrossAxisAlignment.start : pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(isAi ? 'AI' : 'You', style: pw.TextStyle(font: boldFont, fontSize: 9, color: PdfColors.grey600)),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: isAi ? PdfColors.grey100 : PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(8)
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(englishText, style: pw.TextStyle(font: boldFont, fontSize: 11)),
                          pw.Text(koreanText, style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700)),
                        ]
                      )
                    ),
                  ]
                )
              );
            }),
          ];
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/vipa_script_${widget.sessionId}.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '내 VIPA 회화 학습 스크립트(PDF)입니다!',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : scriptData == null
                      ? const Center(child: Text("데이터가 없습니다."))
                      : _buildScriptList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          Expanded(child: Center(child: Text(scriptData?.scenarioTitle ?? '...', style: const TextStyle(fontWeight: FontWeight.bold)))),
          IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent), onPressed: _sharePDF),
        ],
      ),
    );
  }

Widget _buildScriptList() {
    // 로딩 중이거나 데이터가 없으면 리스트를 그리지 않음
    if (scriptData == null || scriptData!.fullTurns.isEmpty) {
      return const Center(child: Text("시나리오 데이터가 없습니다."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: scriptData!.fullTurns.length,
      itemBuilder: (context, index) {
        final turn = scriptData!.fullTurns[index];
        final isAi = turn['speaker'] == 'ai';
        
        // AI는 'en', User는 'expected_en'을 사용
        final englishText = isAi ? (turn['en'] ?? '') : (turn['expected_en'] ?? '');
        final koreanText = turn['ko'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isAi ? Colors.white : const Color(0xFFF8F4FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isAi ? Colors.grey.shade200 : const Color(0xFFEADDFF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isAi ? Icons.smart_toy : Icons.person, 
                size: 20, 
                color: isAi ? Colors.blue : const Color(0xFF7B61FF)
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      englishText, 
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      koreanText, 
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600)
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}