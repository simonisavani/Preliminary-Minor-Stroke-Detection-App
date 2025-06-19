// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ArmResultsScreen extends StatefulWidget {
//   final String videoPath;

//   const ArmResultsScreen({Key? key, required this.videoPath}) : super(key: key);

//   @override
//   _ArmResultsScreenState createState() => _ArmResultsScreenState();
// }

// class _ArmResultsScreenState extends State<ArmResultsScreen> {
//   File? _videoFile;
//   String _result = '';
//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();
//     _videoFile = File(widget.videoPath);
//     _sendVideoToAPI(_videoFile!);
//   }

//   Future<void> _sendVideoToAPI(File videoFile) async {
//     setState(() {
//       _loading = true;
//       _result = '';
//     });

//     var uri = Uri.parse('http://192.168.0.102:5001/detect'); // Replace with your actual API

//     var request = http.MultipartRequest('POST', uri);
//     request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

//     try {
//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         setState(() {
//           _result = jsonEncode(data, toEncodable: (e) => e.toString());
//         });
//       } else {
//         setState(() {
//           _result = 'Error: ${response.reasonPhrase}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _result = 'Failed to connect to API: $e';
//       });
//     }

//     setState(() => _loading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Arm Weakness Result')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Analyzing Video...',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             if (_loading) Center(child: CircularProgressIndicator()),
//             if (!_loading && _result.isNotEmpty)
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Text(
//                     _result,
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//             if (!_loading && _result.isEmpty)
//               Text(
//                 'No result received.',
//                 style: TextStyle(fontSize: 16),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResultScreen extends StatefulWidget {
  final File videoFile;

  ResultScreen({required this.videoFile});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _weakness = '';
  String _formattedResult = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _uploadVideo();
  }

  Future<void> _uploadVideo() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.0.101:5001/detect'), // Replace with your IP
    );
    request.files.add(await http.MultipartFile.fromPath('file', widget.videoFile.path));

    try {
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var data = json.decode(responseBody);
        setState(() {
          _weakness = data['status'] ?? 'Status unknown';
          _formattedResult = '''
Left Arm:
- Avg Angle: ${data['avg_left_angle']?.toStringAsFixed(2) ?? 'N/A'}°
- Weakness: ${data['left_weakness'] == true ? 'Yes' : 'No'}

Right Arm:
- Avg Angle: ${data['avg_right_angle']?.toStringAsFixed(2) ?? 'N/A'}°
- Weakness: ${data['right_weakness'] == true ? 'Yes' : 'No'}
''';
          _loading = false;
        });
      } else {
        setState(() {
          _weakness = 'Error analyzing video';
          _formattedResult = 'Server responded with status code ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _weakness = 'Error: $e';
        _formattedResult = 'Could not upload video.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arm Movement Analysis'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _weakness,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _weakness.contains('No') ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Analysis:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formattedResult,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}
