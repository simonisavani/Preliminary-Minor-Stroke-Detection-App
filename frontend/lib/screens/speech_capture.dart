import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/scheduler.dart';

// // Firebase imports.
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// PDF and Printing packages
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class SpeechCaptureScreen extends StatefulWidget {
  const SpeechCaptureScreen({Key? key}) : super(key: key);

  @override
  _SpeechCaptureScreenState createState() => _SpeechCaptureScreenState();
}

class _SpeechCaptureScreenState extends State<SpeechCaptureScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isRecorderInitialized = false;
  String? _filePath;
  int _recordingDuration = 0;
  Timer? _timer;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initRecorder();

    // Setup animation for recording button
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  /// Initialize recorder with permission handling
  Future<void> _initRecorder() async {
    try {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        debugPrint("Microphone permission denied.");
        return;
      }
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
      debugPrint("Recorder initialized.");
    } catch (e) {
      debugPrint("Error initializing recorder: $e");
    }
  }

  /// Start recording audio
  Future<void> _startRecording() async {
    try {
      if (!_isRecorderInitialized) {
        debugPrint("Recorder not initialized properly.");
        return;
      }
      final dir = await getTemporaryDirectory(); // Better for quick recordings
      _filePath = '${dir.path}/recording.wav';


      await _recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.pcm16WAV,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      // Start timer to track recording duration
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });
      });

      debugPrint("Recording started at: $_filePath");
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }

  /// Stop recording
  Future<void> _stopRecording() async {
    try {
      if (!_isRecording) {
        debugPrint("Recorder is not recording.");
        return;
      }

      await _recorder.stopRecorder();
      _timer?.cancel();

      setState(() {
        _isRecording = false;
      });

      debugPrint("Recording stopped.");
    } catch (e) {
      debugPrint("Error stopping recording: $e");
    }
  }

  /// Send audio file to Flask API and store result in Firestore
  Future<void> _analyzeAudio() async {
    if (_filePath == null || !File(_filePath!).existsSync()) {
  print("DEBUG: Audio file not found at path: $_filePath");
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('No recording found. Please record audio first.'),
      backgroundColor: Colors.red[400],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
  return;
} else {
  print("DEBUG: Audio file found at $_filePath");
}


    setState(() {
      _isProcessing = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.0.101:5002/predict'),
      );
      // request.files
      //     .add(await http.MultipartFile.fromPath('file', _filePath!));
    request.files.add(await http.MultipartFile.fromPath('file', _filePath!));
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var result = jsonDecode(responseBody);

      setState(() {
        _isProcessing = false;
      });

      // Store the test result in Firestore
      await storeTestResult(result);

      // Navigate to results screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpeechResultScreen(result: result),
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing speech: $e'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      debugPrint("Error sending audio: $e");
    }
  }

Future<void> storeTestResult(Map<String, dynamic> result) async {
  try {
    final String uid = "anonymous"; // Hardcoded or dynamically assigned if needed
    final String speechResult = result['result'] ?? '';
    final double accuracy = result['accuracy']?.toDouble() ?? 0.0;
    final String transcribedText = result['transcribed_text'] ?? '';
    final DateTime timestamp = DateTime.now();

    // For now, just log the results (you can write this to a local file or database)
    debugPrint("Storing result locally:");
    debugPrint("User ID: $uid");
    debugPrint("Result: $speechResult");
    debugPrint("Accuracy: $accuracy");
    debugPrint("Transcribed Text: $transcribedText");
    debugPrint("Timestamp: $timestamp");

    // Optional: Add local storage logic here
  } catch (e) {
    debugPrint("Error processing test result locally: $e");
  }
}

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildWaveform() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          30,
              (index) {
            // Create a more dynamic waveform effect
            final randomHeight = 10.0 + (index % 7) * 5.0 + (index % 3) * 8.0;

            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 10)),
              width: 4,
              height: randomHeight,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.7),
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.blue[300]!,
                    Colors.blue[400]!,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.closeRecorder();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Speech Analysis Test',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Top section with instructions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Read the following text aloud:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Text(
                        'The quick brown fox jumps over the lazy dog.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Timer display
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  _formatDuration(_recordingDuration),
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w300,
                    color: _isRecording ? Colors.red : Colors.black87,
                  ),
                ),
              ),
              // Audio visualization
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isRecording ? 100 : 0,
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: _isRecording ? _buildWaveform() : const SizedBox(),
              ),
              const Spacer(),
              // Recording controls
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Record button with pulsing animation
                    GestureDetector(
                      onTap: _isRecording ? _stopRecording : _startRecording,
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isRecording ? _pulseAnimation.value : 1.0,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _isRecording ? Colors.red : Colors.blue,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isRecording ? Colors.red : Colors.blue)
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Status text
                    Text(
                      _isRecording
                          ? 'Recording in progress...'
                          : 'Tap to start recording',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Analyze button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                        _isProcessing || _isRecording ? null : _analyzeAudio,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                          shadowColor: Colors.black.withOpacity(0.3),
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child: _isProcessing
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Analyzing...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                            : const Text(
                          'Analyze Speech',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpeechResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const SpeechResultScreen({Key? key, required this.result}) : super(key: key);

  /// Generate a PDF document that includes the speech analysis results.
  Future<Uint8List> generatePdf() async {
    final String transcribedText =
        result['transcribed_text'] ?? 'No transcription available';
    final double accuracy =
        double.tryParse(result['accuracy'].toString()) ?? 0.0;
    final String speechResult = result['result'] ?? 'Unknown';

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Speech Analysis Test Result',
                style:
                pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Transcribed Text:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(transcribedText),
              pw.SizedBox(height: 12),
              pw.Text('Accuracy:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${accuracy.toStringAsFixed(2)}%'),
              pw.SizedBox(height: 12),
              pw.Text('Result:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(speechResult),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final String transcribedText =
        result['transcribed_text'] ?? 'No transcription available';
    final double accuracy =
        double.tryParse(result['accuracy'].toString()) ?? 0.0;
    final String speechResult = result['result'] ?? 'Unknown';

    // Refined logic for detecting dysarthria or error conditions:
    final String lowerSpeechResult = speechResult.toLowerCase();
    final bool isDysarthriaDetected =
        (lowerSpeechResult.contains("dysarthria") &&
            !lowerSpeechResult.contains("no dysarthria") &&
            !lowerSpeechResult.contains("normal")) ||
            lowerSpeechResult.contains("error") ||
            lowerSpeechResult.contains("failed") ||
            lowerSpeechResult.contains("unknown");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Test Result',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Audio visualization card
              Container(
                width: double.infinity,
                height: 180,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDysarthriaDetected ? Colors.red[50]! : Colors.green[50]!,
                      isDysarthriaDetected ? Colors.red[100]! : Colors.green[100]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.graphic_eq,
                    size: 80,
                    color: isDysarthriaDetected ? Colors.red[300] : Colors.green[300],
                  ),
                ),
              ),
              // Result card with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, double value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDysarthriaDetected
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: isDysarthriaDetected
                          ? Colors.red.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDysarthriaDetected
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDysarthriaDetected
                              ? Icons.warning_rounded
                              : Icons.check_circle_rounded,
                          size: 48,
                          color: isDysarthriaDetected ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        speechResult,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDysarthriaDetected ? Colors.red : Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Accuracy indicator
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Accuracy',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${accuracy.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDysarthriaDetected ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: accuracy / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDysarthriaDetected ? Colors.red : Colors.green,
                              ),
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Transcribed text card
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, double value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.text_fields_rounded,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Transcribed Text',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          transcribedText,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Download PDF button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Uint8List pdfBytes = await generatePdf();
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename: 'speech_analysis_result.pdf',
                    );
                  },
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  label: const Text(
                    'Download PDF',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Button to retake test
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.mic, color: Colors.white),
                  label: const Text(
                    'Record New Speech',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
