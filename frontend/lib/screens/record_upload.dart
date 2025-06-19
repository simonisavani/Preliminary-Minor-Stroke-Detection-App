import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class SpeechDetectionScreen extends StatefulWidget {
  @override
  _SpeechDetectionScreenState createState() => _SpeechDetectionScreenState();
}

class _SpeechDetectionScreenState extends State<SpeechDetectionScreen> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _filePath;
  String _resultText = "Press 'Record' to start";

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() {
        _resultText = "Microphone permission not granted!";
      });
      return;
    }
    await _recorder!.openRecorder();
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/recorded_audio.wav';
    try {
      await _recorder!.startRecorder(
        toFile: _filePath,
        codec: Codec.pcm16WAV, // Record as WAV
      );
      setState(() {
        _isRecording = true;
        _resultText = "Recording...";
      });
    } catch (e) {
      setState(() {
        _resultText = "Error starting recorder: $e";
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
        _resultText = "Recording stopped. Uploading...";
      });
      // Once recording is stopped, send the audio file to the API.
      await _sendAudioFile();
    } catch (e) {
      setState(() {
        _resultText = "Error stopping recorder: $e";
      });
    }
  }

  Future<void> _sendAudioFile() async {
    if (_filePath == null) return;
    File audioFile = File(_filePath!);
    if (!await audioFile.exists()) {
      setState(() {
        _resultText = "Audio file not found!";
      });
      return;
    }

    var uri = Uri.parse('http://192.168.0.101:5002/predict'); // Replace with your API URL
    var request = http.MultipartRequest('POST', uri);
    try {
      request.files.add(await http.MultipartFile.fromPath('audio', _filePath!));
    } catch (e) {
      setState(() {
        _resultText = "Error attaching file: $e";
      });
      return;
    }

    setState(() {
      _resultText = "Uploading audio...";
    });

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        setState(() {
          _resultText = "Result: $responseBody";
        });
      } else {
        setState(() {
          _resultText = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _resultText = "Error during upload: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dysarthria Detection"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: Text("Record"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: Text("Stop"),
            ),
            SizedBox(height: 32),
            Text(
              _resultText,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
