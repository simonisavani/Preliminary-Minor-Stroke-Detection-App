import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TimeScreen extends StatefulWidget {
  @override
  _TimeScreenState createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  Position? _currentPosition;
  List<Map<String, dynamic>> _hospitals = [];
  final String _googleApiKey = 'YOUR_GOOGLE_API_KEY'; 

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (!serviceEnabled || permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
    _getNearbyHospitals();
  }

  Future<void> _getNearbyHospitals() async {
    final lat = _currentPosition?.latitude;
    final lng = _currentPosition?.longitude;
    if (lat == null || lng == null) return;

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=3000&type=hospital&key=$_googleApiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      List results = data['results'];
      List<Map<String, dynamic>> hospitals = [];

      for (var result in results) {
        String placeId = result['place_id'];
        String name = result['name'];
        String vicinity = result['vicinity'];

        // Fetch place details for phone number
        String detailsUrl =
            'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,formatted_phone_number&key=$_googleApiKey';
        final detailsResponse = await http.get(Uri.parse(detailsUrl));
        final detailsData = json.decode(detailsResponse.body);

        String? phone = detailsData['result']?['formatted_phone_number'];

        hospitals.add({
          'name': name,
          'vicinity': vicinity,
          'phone': phone,
        });
      }

      setState(() {
        _hospitals = hospitals;
      });
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTime = TimeOfDay.now().format(context);

    return Scaffold(
      appBar: AppBar(title: Text('Nearby Hospitals - $currentTime')),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _hospitals.length,
              itemBuilder: (context, index) {
                final hospital = _hospitals[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(Icons.local_hospital, color: Colors.redAccent),
                    title: Text(hospital['name']),
                    subtitle: Text(hospital['vicinity']),
                    trailing: hospital['phone'] != null
                        ? IconButton(
                            icon: Icon(Icons.phone, color: Colors.green),
                            onPressed: () => _makePhoneCall(hospital['phone']),
                          )
                        : SizedBox.shrink(),
                  ),
                );
              },
            ),
    );
  }
}
