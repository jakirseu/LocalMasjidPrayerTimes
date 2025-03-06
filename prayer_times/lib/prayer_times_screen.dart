import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'dart:convert'; // For JSON encoding and decoding
import 'network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PrayerTimesScreen extends StatefulWidget {
  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final myCoordinates = Coordinates(23.9088, 89.1220);
  final params = CalculationMethod.karachi.getParameters();
  final NetworkService _networkService = NetworkService();

  Map<String, dynamic>? prayerData;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  // Load prayer data from SharedPreferences
  Future<Map<String, dynamic>?> _loadPrayerData() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedPrayerData = prefs.getString('prayerData');
    
    if (savedPrayerData != null) {
      try {
        // Convert the JSON string back to Map and print for debugging
        print("Loaded prayer data: $savedPrayerData");
        return Map<String, dynamic>.from(jsonDecode(savedPrayerData));
      } catch (e) {
        print('Error decoding prayer data: $e');
        return null; // Return null if decoding fails
      }
    }
    
    return null; // Return null if no data found
  }

  // Function to sync Jamat time
  Future<void> syncJamatData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // use this to load json data from assets folder. 
       final data = await _networkService.fetchPrayerDataLocal();
       // use this to load Jamat data from url
      //final data = await _networkService.fetchPrayerData();
      setState(() {
        prayerData = data;
        isLoading = false;
      });

      final prefs = await SharedPreferences.getInstance();
      // Convert the Map to JSON string and save it
      String jsonData = jsonEncode(prayerData);
      print("Saving prayer data: $jsonData");
      await prefs.setString('prayerData', jsonData); // Save updated Jamat data
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to sync data. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    params.madhab = Madhab.hanafi;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    return Scaffold(
      appBar: AppBar(title: Text('Prayer Times')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadPrayerData(), // Load data from SharedPreferences
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }

          prayerData = snapshot.data;

          return Column(
            children: [
              // Show error message as text if any
              if (errorMessage.isNotEmpty && prayerData == null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    MosqueInfoCard(mosqueName: "Baitul Mukarram", location: "Topkhana Road, Paltan Dhaka", imagePath: 'assets/BaitulMukarram.jpg'),
                    TimeCard(prayerTimes: prayerTimes,),
       
                    ElevatedButton(
                      onPressed: syncJamatData,
                      child: Text('Sync Jamat Times'),
                    ),
                    PrayerTimeCard(
                      title: 'Fajr',
                      time: _formatTime(prayerTimes.fajr),
                      jamat: prayerData?['jamat']['Fajr'] ?? 'N/A',
                      icon: Icons.nightlight_round,
                    ),
                    
                    PrayerTimeCard(
                      title: 'Dhuhr',
                      time: _formatTime(prayerTimes.dhuhr),
                      jamat: prayerData?['jamat']['Dhuhr'] ?? 'N/A',
                      icon: Icons.sunny,
                    ),
                    PrayerTimeCard(
                      title: 'Asr',
                      time: _formatTime(prayerTimes.asr),
                      jamat: prayerData?['jamat']['Asr'] ?? 'N/A',
                      icon: Icons.access_time,
                    ),
                    PrayerTimeCard(
                      title: 'Maghrib',
                      time: _formatTime(prayerTimes.maghrib),
                      jamat: prayerData?['jamat']['Maghrib'] ?? 'N/A',
                      icon: Icons.nights_stay,
                    ),
                    PrayerTimeCard(
                      title: 'Isha',
                      time: _formatTime(prayerTimes.isha),
                      jamat: prayerData?['jamat']['Isha'] ?? 'N/A',
                      icon: Icons.nightlight,
                    ),
                      PrayerTimeCard(
                      title: 'Jumuah',
                      time: _formatTime(prayerTimes.dhuhr),
                      jamat: prayerData?['jamat']['Jumuah'] ?? 'N/A',
                      icon: Icons.sunny,
                    ),
                  
     DailyIslamicCard(
  title: 'Dua of the Day',
  content: prayerData?['dua_of_the_day'] ?? 'اللهم إني أسألك العافية في الدنيا والآخرة',  
  icon: Icons.self_improvement,
),
    DailyIslamicCard(
      title: 'Hadith of the Day',
      content:  prayerData?['hadith_of_the_day'] ?? 'The best among you are those who have the best manners and character. (Bukhari)',
      icon: Icons.menu_book,
    ),
    DailyIslamicCard(
      title: 'Ayat of the Day',
      content: prayerData?['quran_ayat_of_the_day'] ??  'Indeed, with hardship comes ease. (Quran 94:6)',
      icon: Icons.book,
    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

String _formatTime(DateTime time) {
  return DateFormat('hh:mm a').format(time); // Formats time in 12-hour format with AM/PM
}
}


class PrayerTimeCard extends StatelessWidget {
  final String title;
  final String time;
  final String jamat;
  final IconData icon;

  PrayerTimeCard({required this.title, required this.time, required this.jamat, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(icon, color: Colors.blue, size: 40),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Distribute space between Adhan and Jamat
          children: [
            Text(
              'Adhan: $time',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              'Jamat: $jamat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green, // Bold and red color for Jamat time
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeCard extends StatelessWidget {
  final PrayerTimes prayerTimes;

  TimeCard({required this.prayerTimes});

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time); // Formats time in 12-hour format with AM/PM
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Distribute space between left and right
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sunrise: ${_formatTime(prayerTimes.sunrise)}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Sunset: ${_formatTime(prayerTimes.maghrib)}', style: TextStyle(fontSize: 16)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Sehri: ${_formatTime(prayerTimes.fajr)}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Iftar: ${_formatTime(prayerTimes.maghrib)}', style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MosqueInfoCard extends StatelessWidget {
  final String mosqueName;
  final String location;
  final String imagePath; // Path to the image in assets

  MosqueInfoCard({
    required this.mosqueName,
    required this.location,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150, // Adjust height for better layout
            ),
          ),
          // Overlay with Mosque Info
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withOpacity(0.5), // Dark overlay
            ),
            padding: EdgeInsets.all(12),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mosqueName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DailyIslamicCard extends StatelessWidget {
  final String title; // Title: Dua of the Day, Hadith of the Day, Ayat of the Day
  final String content; // The actual text
  final IconData icon; // Icon to visually distinguish the type

  DailyIslamicCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 28), // Title Icon
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}