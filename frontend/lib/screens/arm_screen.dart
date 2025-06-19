// // import 'dart:async';
// // import 'dart:io';

// // import 'package:camera/camera.dart';
// // import 'package:flutter/material.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'arm_result_screen.dart';

// // class ArmWeaknessScreen extends StatefulWidget {
// //   @override
// //   _ArmWeaknessScreenState createState() => _ArmWeaknessScreenState();
// // }

// // class _ArmWeaknessScreenState extends State<ArmWeaknessScreen> {
// //   CameraController? _cameraController;
// //   bool _isRecording = false;
// //   bool _hasStarted = false;
// //   String? _videoPath;
// //   Timer? _timer;
// //   int _secondsRemaining = 10;

// //   @override
// //   void initState() {
// //     super.initState();
// //     initializeCamera();
// //   }

// //   Future<void> initializeCamera() async {
// //     final cameras = await availableCameras();
// //     final frontCamera = cameras.firstWhere(
// //       (camera) => camera.lensDirection == CameraLensDirection.front,
// //     );

// //     _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
// //     await _cameraController!.initialize();
// //     setState(() {});
// //   }

// //   Future<void> startRecording() async {
// //     if (_cameraController == null || !_cameraController!.value.isInitialized) return;

// //     final Directory extDir = await getTemporaryDirectory();
// //     final String dirPath = '${extDir.path}/Movies';
// //     await Directory(dirPath).create(recursive: true);
// //     final String filePath = '$dirPath/arm_weakness_${DateTime.now().millisecondsSinceEpoch}.mp4';

// //     try {
// //       await _cameraController!.startVideoRecording();
// //       setState(() {
// //         _isRecording = true;
// //         _hasStarted = true;
// //         _videoPath = filePath;
// //         _secondsRemaining = 10;
// //       });

// //       _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
// //         if (_secondsRemaining == 0) {
// //           await stopRecording();
// //           timer.cancel();
// //         } else {
// //           setState(() {
// //             _secondsRemaining--;
// //           });
// //         }
// //       });
// //     } catch (e) {
// //       print('Error starting video recording: $e');
// //     }
// //   }

// //   Future<void> stopRecording() async {
// //     if (_cameraController == null || !_cameraController!.value.isRecordingVideo) return;

// //     try {
// //       final file = await _cameraController!.stopVideoRecording();
// //       setState(() {
// //         _isRecording = false;
// //       });

// //       if (mounted && _videoPath != null) {
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) => ArmResultsScreen(videoPath: file.path),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       print('Error stopping video recording: $e');
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _cameraController?.dispose();
// //     _timer?.cancel();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     if (_cameraController == null || !_cameraController!.value.isInitialized) {
// //       return Scaffold(
// //         appBar: AppBar(title: Text('Arm Weakness Detection')),
// //         body: Center(child: CircularProgressIndicator()),
// //       );
// //     }

// //     return Scaffold(
// //       appBar: AppBar(title: Text('Arm Weakness Detection')),
// //       body: Column(
// //         children: [
// //           AspectRatio(
// //             aspectRatio: _cameraController!.value.aspectRatio,
// //             child: CameraPreview(_cameraController!),
// //           ),
// //           SizedBox(height: 20),
// //           if (!_hasStarted) ...[
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //               child: Text(
// //                 'Get ready! Please sit straight in front of the camera.\n\n'
// //                 'Raise both of your arms forward at shoulder level.\n\n'
// //                 'Stay still and keep your arms raised for 10 seconds.',
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
// //               ),
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: startRecording,
// //               child: Text('Start Recording'),
// //             ),
// //           ] else if (_isRecording) ...[
// //             Text(
// //               'Recording in progress...',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             Text(
// //               '$_secondsRemaining seconds remaining',
// //               style: TextStyle(fontSize: 16),
// //             ),
// //             SizedBox(height: 10),
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //               child: Text(
// //                 'Hold your arms steady and do not move during this time.',
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(fontSize: 15),
// //               ),
// //             ),
// //           ]
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'arm_weakness_camera_screen.dart';

// class ArmWeaknessInstructionsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Arm Weakness Test')),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Instructions:',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(
//               '1. Sit still and face the camera.\n'
//               '2. Hold both your arms straight out in front of you.\n'
//               '3. Remain steady for 10 seconds.\n'
//               '4. The camera will automatically stop after recording.',
//               style: TextStyle(fontSize: 16),
//             ),
//             Spacer(),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => ArmWeaknessCameraScreen()),
//                   );
//                 },
//                 child: Text('Start Recording'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'arm_weakness_camera_screen.dart';

class ArmWeaknessInstructionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arm Weakness Test'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.deepPurple.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 40, color: Colors.deepPurple),
            SizedBox(height: 16),
            Text(
              'Follow These Steps',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '1. Sit still and face the camera.\n'
              '2. Hold both your arms straight out in front of you.\n'
              '3. Remain steady for 10 seconds.\n'
              '4. The camera will automatically stop after recording.',
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CameraRecordScreen()),
                  );
                },
                icon: Icon(Icons.videocam),
                label: Text('Start Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
