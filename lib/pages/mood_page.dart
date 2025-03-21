import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodPieChart extends StatefulWidget {
  final String userID;
  const MoodPieChart({super.key, required this.userID});

  @override
  _MoodPieChartState createState() => _MoodPieChartState();
}

class _MoodPieChartState extends State<MoodPieChart> {
  final Color backgroundColor = Color(0xFFFAF3E0); // Soft Cream Background
  String? selectedMood; // Stores currently selected mood

  // Mapping emotions to numerical values
  final Map<String, double> emotionMap = {
    'happy': 1,
    'calm': 2,
    'surprised': 3,
    'neutral': 4,
    'sad': 5,
    'fearful': 6,
    'angry': 7,
    'disgust': 8
  };

  // Emojis for easy visual representation
  final Map<String, String> emojiMap = {
    'happy': '😄',
    'calm': '😊',
    'surprised': '😲',
    'neutral': '😐',
    'sad': '😢',
    'fearful': '😨',
    'angry': '😡',
    'disgust': '🤢'
  };

  // Emotion Colors (Pastel gradient theme)
  final List<Color> moodColors = [
    Color(0xFF9FE6A0), // Happy - Light Green
    Color(0xFFB5E7A0), // Calm - Soft Green
    Color(0xFFFFE082), // Surprised - Soft Yellow
    Color(0xFFFFAB91), // Neutral - Peach
    Color(0xFFFF8A65), // Sad - Orange
    Color(0xFFD84315), // Fearful - Deep Orange
    Color(0xFFD32F2F), // Angry - Red
    Color(0xFF6A1B9A), // Disgust - Dark Purple
  ];

  Map<String, int> moodData = {};

  @override
  void initState() {
    super.initState();
    fetchMoodData();
  }

  // Fetch mood data from Firestore
  Future<void> fetchMoodData() async {
    String userId = widget.userID;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('emotions')
        .orderBy('timestamp', descending: false)
        .get();

    Map<String, int> tempMoodData = {};

    for (var doc in snapshot.docs) {
      var emotion = doc['emotion'];
      if (emotionMap.containsKey(emotion)) {
        tempMoodData[emotion] = (tempMoodData[emotion] ?? 0) + 1;
      }
    }

    setState(() {
      moodData = tempMoodData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Mood Overview",
          style: GoogleFonts.merriweather(color: Colors.black),
        ),
      ),
      body: Center(
        child: moodData.isEmpty
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Mood Distribution",
                    style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(4, 4),
                        ),
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(-4, -4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: PieChart(
                        PieChartData(
                          sections: moodData.entries.map((entry) {
                            String emotion = entry.key;
                            int count = entry.value;
                            int index = emotionMap[emotion]!.toInt() - 1;

                            bool isSelected = (selectedMood == null ||
                                selectedMood == emotion);

                            return PieChartSectionData(
                              color: isSelected
                                  ? moodColors[index]
                                  : moodColors[index].withOpacity(0.2),
                              value: count.toDouble(),
                              title: emojiMap[emotion] ?? '',
                              radius: isSelected ? 70 : 50,
                              titleStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              badgeWidget: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedMood = (selectedMood == emotion)
                                        ? null
                                        : emotion;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    emojiMap[emotion] ?? '',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  selectedMood != null
                      ? Text(
                          "You selected: ${emojiMap[selectedMood!]!} ${selectedMood!.toUpperCase()}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        )
                      : Text(
                          "Tap on a mood to focus",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                ],
              ),
      ),
    );
  }
}
