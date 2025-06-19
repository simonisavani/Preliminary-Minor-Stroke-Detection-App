import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'arm_result_screen.dart';

class CameraRecordScreen extends StatefulWidget {
  @override
  _CameraRecordScreenState createState() => _CameraRecordScreenState();
}

class _CameraRecordScreenState extends State<CameraRecordScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  CameraDescription? _currentCamera;
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> initializeCamera([CameraDescription? specificCamera]) async {
    _cameras = await availableCameras();
    _currentCamera = specificCamera ??
        _cameras!.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

    _cameraController = CameraController(_currentCamera!, ResolutionPreset.medium);
    await _cameraController!.initialize();
    await _cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp);

    setState(() {});
    await Future.delayed(Duration(seconds: 2));
    _startRecording();
  }

  Future<void> _flipCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    final newCamera = _currentCamera!.lensDirection == CameraLensDirection.front
        ? _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.back)
        : _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.front);

    await _cameraController?.dispose();

    _currentCamera = newCamera;
    _cameraController = CameraController(_currentCamera!, ResolutionPreset.medium);

    await _cameraController!.initialize();
    await _cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp);

    setState(() {});
  }

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/arm_${DateTime.now().millisecondsSinceEpoch}.mp4';

    await _cameraController!.startVideoRecording();
    setState(() => _isRecording = true);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        final file = await _cameraController!.stopVideoRecording();
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(videoFile: File(file.path)),


          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final cameraHeight = screenHeight * 0.75;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Arm Weakness Detection',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Camera Preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: cameraHeight,
                      child: _currentCamera!.lensDirection == CameraLensDirection.front
                          ? Transform.rotate(
                              angle: -90 * math.pi / 180, // Rotate front camera preview
                              child: CameraPreview(_cameraController!),
                            )
                          : CameraPreview(_cameraController!), // No rotation for back camera
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.cameraswitch, color: Colors.white),
                        onPressed: _flipCamera,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Timer display
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(Icons.timer, color: Colors.orange, size: 28),
                  SizedBox(height: 8),
                  Text(
                    _isRecording
                        ? 'Recording for $_secondsRemaining seconds...'
                        : 'Preparing...',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // Record status button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: _isRecording
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Recording...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Starting...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
