import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'speech_capture.dart';

class SlurredSpeechScreen extends StatefulWidget {
  const SlurredSpeechScreen({Key? key}) : super(key: key);

  @override
  _SlurredSpeechScreenState createState() => _SlurredSpeechScreenState();
}

class _SlurredSpeechScreenState extends State<SlurredSpeechScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> guidelines = [
    {
      'icon': LucideIcons.mic,
      'title': 'Speak Clearly',
      'description': 'Speak directly into the microphone to ensure accurate detection of your voice.',
      'color': const Color(0xFF7CC9F9)
    },
    {
      'icon': LucideIcons.volume2,
      'title': 'Reduce Background Noise',
      'description': 'Ensure you are in a quiet environment to avoid background noise interfering with the detection.',
      'color': const Color(0xFF8FD5A6)
    },
    {
      'icon': LucideIcons.hourglass,
      'title': 'Be Patient',
      'description': 'Wait for the app to detect and process your speech. Follow any on-screen prompts for guidance.',
      'color': const Color(0xFFFFB26B)
    },
    {
      'icon': LucideIcons.messageCircle,
      'title': 'Speak at a Normal Pace',
      'description': 'Avoid speaking too fast or too slow, as it may affect accuracy.',
      'color': const Color(0xFFE2C0FF)
    },
    {
      'icon': LucideIcons.repeat,
      'title': 'Repeat if Needed',
      'description': 'If the detection seems inaccurate, try repeating the sentence clearly.',
      'color': const Color(0xFFFF9B9B)
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (status.isGranted && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SpeechCaptureScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Microphone permission is required to proceed.'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildGuideline(Map<String, dynamic> guideline, int index) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _fadeAnimation,
        curve: Interval(0.1 * index, 1.0, curve: Curves.easeOut),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: guideline['color'].withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: guideline['color'].withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: guideline['color'],
                    width: 1.5,
                  ),
                ),
                child: Icon(guideline['icon'], color: guideline['color'], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guideline['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      guideline['description'],
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Speech Test',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7CC9F9).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.messageSquare,
                      color: Color(0xFF7CC9F9),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Guidelines for Speech Test',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Follow the instructions below to improve detection accuracy.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: guidelines.length,
                itemBuilder: (context, index) {
                  return _buildGuideline(guidelines[index], index);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ElevatedButton.icon(
          onPressed: _checkMicrophonePermission,
          icon: const Icon(LucideIcons.mic, color: Colors.white),
          label: const Text(
            'Start Testing',
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
            elevation: 4,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
