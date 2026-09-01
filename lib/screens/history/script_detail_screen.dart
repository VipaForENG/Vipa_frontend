import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// PDF 관련 패키지
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'learning_history_provider.dart';
import '../../models/learning_history_models.dart';

class SessionAudioPlayer extends StatefulWidget {
  final String? audioUrl;

  const SessionAudioPlayer({super.key, this.audioUrl});

  @override
  State<SessionAudioPlayer> createState() => _SessionAudioPlayerState();
}

class _SessionAudioPlayerState extends State<SessionAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isLoading = true;
  bool _autoPlay = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = '녹음이 없습니다.';
      });
      return;
    }

    try {
      await _player.setUrl(widget.audioUrl!);
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });

      if (_autoPlay) {
        await _player.play();
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = '오디오를 불러올 수 없습니다';
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '이 세션의 녹음이 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.grey.shade600),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '오디오 로딩 중...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border(
              left: BorderSide(color: Colors.grey.shade200),
              top: BorderSide(color: Colors.grey.shade200),
              right: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () async {
                  if (_player.playing) {
                    await _player.pause();
                  } else {
                    await _player.play();
                  }
                  setState(() {});
                },
                icon: StreamBuilder<bool>(
                  stream: _player.playingStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return Icon(
                      isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: const Color(0xFF7B61FF),
                      size: 32,
                    );
                  },
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '녹음 재생',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    StreamBuilder<Duration>(
                      stream: _player.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration = _player.duration ?? Duration.zero;
                        return Text(
                          '${_formatDuration(position)} / ${_formatDuration(duration)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async => _player.stop(),
                icon: const Icon(Icons.stop_circle_rounded, color: Colors.grey),
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            border: Border(
              left: BorderSide(color: Colors.grey.shade200),
              bottom: BorderSide(color: Colors.grey.shade200),
              right: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = _player.duration ?? Duration.zero;
              final progress = duration.inMilliseconds > 0
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0;

              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF7B61FF)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _autoPlay ? Icons.play_arrow : Icons.play_arrow,
                            size: 16,
                            color: _autoPlay ? const Color(0xFF7B61FF) : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '자동 재생',
                            style: TextStyle(
                              fontSize: 12,
                              color: _autoPlay ? const Color(0xFF7B61FF) : Colors.grey.shade600,
                              fontWeight: _autoPlay ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _autoPlay,
                        onChanged: (value) {
                          setState(() {
                            _autoPlay = value;
                          });
                        },
                        activeThumbColor: const Color(0xFF7B61FF),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

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
            if (scriptData != null) SessionAudioPlayer(audioUrl: scriptData!.audioUrl),
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