import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Import this
import 'package:google_fonts/google_fonts.dart';
import 'screens/face_screen.dart';
import 'screens/arm_screen.dart';
import 'screens/slurred_speech.dart';
import 'screens/time_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
   runApp(const StrokeAlertApp());
}


class StrokeAlertApp extends StatelessWidget {
  const StrokeAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stroke Alert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const StrokeHomePage(),
    );
  }
}

class StrokeHomePage extends StatelessWidget {
  const StrokeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stroke Alert'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 30),
            _buildFastTile(
              context,
              icon: Icons.face_retouching_natural,
              title: "Facial Drooping",
              color: Colors.pinkAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FacialParalysisScreen()),
                );
              },
            ),
            _buildFastTile(
              context,
              icon: Icons.pan_tool_alt_rounded,
              title: "Arm Weakness",
              color: Colors.orangeAccent,
              onTap: () {
                Navigator.push(
                  context,
                 MaterialPageRoute(builder: (context) => ArmWeaknessInstructionsScreen()),

                );
              },
            ),
            _buildFastTile(
              context,
              icon: Icons.record_voice_over,
              title: "Slurred Speech",
              color: Colors.teal,
              onTap: () { 
                Navigator.push(
                  context,
                 MaterialPageRoute(builder: (context) => SlurredSpeechScreen()),

                );
              }, // Empty action for now
            ),
            _buildFastTile(
              context,
              icon: Icons.local_phone_rounded,
              title: "Time to Call Emergency",
              color: Colors.redAccent,
              onTap: () {
                Navigator.push(
                  context,
                 MaterialPageRoute(builder: (context) => TimeScreen()),

                );
              }, // Empty action for now
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("What is a Stroke?",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const SizedBox(height: 10),
            Text(
              "A stroke occurs when the blood supply to part of your brain is interrupted or reduced, "
              "preventing brain tissue from getting oxygen and nutrients. Early recognition using the FAST method is critical.",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, height: 1.4),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFastTile(BuildContext context,
      {required IconData icon,
      required String title,
      required Color color,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
