// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:lucide_icons/lucide_icons.dart';
// import 'package:permission_handler/permission_handler.dart';

// class FacialParalysisScreen extends StatefulWidget {
//   const FacialParalysisScreen({Key? key}) : super(key: key);

//   @override
//   _FacialParalysisScreenState createState() => _FacialParalysisScreenState();
// }

// class _FacialParalysisScreenState extends State<FacialParalysisScreen> with SingleTickerProviderStateMixin {
//   File? _image;
//   bool _isLoading = false;
//   String? _resultText;  // To hold the result message for display
//   String? _asymmetryScore; // To hold the score for display
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );

//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut,
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _checkCameraPermissionAndPickImage() async {
//     var status = await Permission.camera.status;
//     if (!status.isGranted) {
//       status = await Permission.camera.request();
//     }
//     if (status.isGranted) {
//       _pickImage();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Camera permission is required to proceed.'),
//           backgroundColor: Colors.red[400],
//         ),
//       );
//     }
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile == null) return;
//     setState(() {
//       _image = File(pickedFile.path);
//       _isLoading = true;
//     });

//     bool isValid = await _validateFacialImage(_image!);
//     if (!isValid) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('The image does not appear to contain a face. Please try again.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     await _uploadImage();
//   }

//   /// Simulated facial validation (replace with real model/API call if needed)
//   Future<bool> _validateFacialImage(File image) async {
//     try {
//       // Replace with real API or model logic here.
//       // For now, simulate a check by returning true.
//       await Future.delayed(const Duration(seconds: 1));
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<void> _uploadImage() async {
//     if (_image == null) return;
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('http://192.168.0.102:5000/detect_facial_drooping'),
//     );
//     request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

//     String resultMessage = '';
//     String asymmetryScore = '';
//     try {
//       var response = await request.send();
//       var responseData = await response.stream.bytesToString();
//       var decodedResponse = jsonDecode(responseData);
//       if (response.statusCode == 200) {
//         resultMessage = decodedResponse['message'];
//         asymmetryScore = decodedResponse['asymmetry_score'].toString();
//       } else {
//         resultMessage = "Error: ${decodedResponse['error']}";
//       }
//     } catch (e) {
//       resultMessage = "Failed to analyze image.";
//     }

//     setState(() {
//       _isLoading = false;
//       _resultText = resultMessage;  // Set the result to be displayed
//       _asymmetryScore = asymmetryScore; // Store the score
//     });
//   }

//   Widget _buildResultCard(String title, String content) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       elevation: 5,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             Icon(Icons.info_outline, color: Colors.blue, size: 28),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     content,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.black54,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInstructions() {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       elevation: 5,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Instructions for the Test:',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               '1. Position your face clearly in front of the camera.\n'
//               '2. Ensure proper lighting and no obstructions in the face.\n'
//               '3. Press the "Start Facial Test" button to begin.\n'
//               '4. A message will be displayed based on the detected facial asymmetry score.\n'
//               '5. Follow the instructions carefully for best results.',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.black54,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFF5F5F5),
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Facial Paralysis Detection',
//           style: TextStyle(
//             color: Colors.black87,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
//                 physics: const BouncingScrollPhysics(),
//                 children: [
//                   // Instructions Section
//                   _buildInstructions(),
//                   const SizedBox(height: 20),
//                   if (_resultText != null)
//                     _buildResultCard(
//                       'Test Result:',
//                       'Message: $_resultText\nAsymmetry Score: $_asymmetryScore',
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         child: ElevatedButton.icon(
//           onPressed: _isLoading ? null : _checkCameraPermissionAndPickImage,
//           icon: _isLoading
//               ? const SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     strokeWidth: 2.0,
//                   ),
//                 )
//               : const Icon(Icons.camera_alt),
//           label: Text(_isLoading ? 'Analyzing...' : 'Start Facial Test'),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             backgroundColor: Colors.blueAccent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// facial_paralysis_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'facial_result_screen.dart';

class FacialParalysisScreen extends StatefulWidget {
  const FacialParalysisScreen({Key? key}) : super(key: key);

  @override
  _FacialParalysisScreenState createState() => _FacialParalysisScreenState();
}

class _FacialParalysisScreenState extends State<FacialParalysisScreen> {
  File? _image;
  bool _isLoading = false;

  Future<void> _checkCameraPermissionAndPickImage() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (status.isGranted) {
      _pickImage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Camera permission is required to proceed.'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _isLoading = true;
    });

    bool isValid = await _validateFacialImage(_image!);
    if (!isValid) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The image does not appear to contain a face. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _uploadImage();
  }

  Future<bool> _validateFacialImage(File image) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.0.102:5000/detect_facial_drooping'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    String resultMessage = '';
    String asymmetryScore = '';
    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var decodedResponse = jsonDecode(responseData);
      if (response.statusCode == 200) {
        resultMessage = decodedResponse['message'];
        asymmetryScore = decodedResponse['asymmetry_score'].toString();
      } else {
        resultMessage = "Error: ${decodedResponse['error']}";
      }
    } catch (e) {
      resultMessage = "Failed to analyze image.";
    }

    setState(() => _isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacialResultScreen(
          imageFile: _image!,
          resultText: resultMessage,
          asymmetryScore: asymmetryScore,
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '📸 Instructions for the Test:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              '✅ Position your face clearly in front of the camera.\n'
              '✅ Ensure good lighting and no obstructions on your face.\n'
              '✅ Tap "Start Facial Test" to begin.\n'
              '✅ Wait for the analysis result on the next screen.\n',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Facial Paralysis Detection'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildInstructionsCard(),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkCameraPermissionAndPickImage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(_isLoading ? 'Analyzing...' : 'Start Facial Test'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
