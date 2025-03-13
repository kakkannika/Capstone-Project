import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/screens/home/home_screen.dart';
import 'package:tourism_app/theme/theme.dart';

class QuestionScreen extends StatefulWidget {
  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int currentIndex = 0;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "What type of places do you enjoy visiting?",
      "options": [
        "Beach",
        "Mountains",
        "Historical Sites",
        "Nature & Wildlife",
        "Shopping Malls",
        "City Exploration",
        "Local Villages"
      ],
      "maxSelection": 3,
      "minSelection": 1,
    },
    {
      "question": "What activities do you prefer?",
      "options": [
        "Adventure (Hiking, Rafting, Ziplining)",
        "Relaxation (Spas, Resorts, Beaches)",
        "Cultural Experiences (Temples, Museums, Traditional Events)",
        "Nightlife (Bars, Clubs, Concerts)",
        "Food & Dining (Street Food, Fine Dining, Cafés)",
        "Sightseeing (Famous Landmarks, Scenic Views)"
      ],
      "maxSelection": 3,
      "minSelection": 1,
    },
    {
      "question": "Do you have any special interests?",
      "options": [
        "Photography 📸",
        "Hiking ⛰",
        "Diving 🤿",
        "Shopping 🛍",
        "History & Culture 🏛",
        "Art 🎨"
      ],
      "maxSelection": 3,
      "minSelection": 1,
    }
  ];

  List<List<String>> selectedOptions = [[], [], []];

  void toggleSelection(int questionIndex, String option) {
    setState(() {
      if (selectedOptions[questionIndex].contains(option)) {
        selectedOptions[questionIndex].remove(option);
      } else {
        int? maxSelection = questions[questionIndex]["maxSelection"];
        if (maxSelection == null ||
            selectedOptions[questionIndex].length < maxSelection) {
          selectedOptions[questionIndex].add(option);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool canProceed = selectedOptions[currentIndex].length >=
        questions[currentIndex]["minSelection"];
    int? maxSelection = questions[currentIndex]["maxSelection"];

    return Scaffold(
      backgroundColor: DertamColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (currentIndex > 0) {
              setState(() {
                currentIndex--;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text("Skip", style: TextStyle(color: DertamColors.grey)))
        ],
        backgroundColor: DertamColors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
       
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Column(
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'lib/assets/images/Logo.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  SizedBox(height: DertamSpacings.m),
                  // Question number indicator
                  Text(
                    "Question ${currentIndex + 1} of ${questions.length}",
                    style: TextStyle(
                      fontSize: DertamTextStyles.title.fontSize,
                      fontWeight: FontWeight.bold,
                      color: DertamColors.primary,
                    ),
                  ),
                  SizedBox(height: DertamSpacings.m),
                ],
              ),
            ),

            // Scrollable content section
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Question container with light blue background
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: DertamColors.blueSky,
                          borderRadius: BorderRadius.circular(DertamSpacings.radius),
                        ),
                        child: Column(
                          children: [
                            // Question title
                            Text(
                              "${currentIndex + 1}. ${questions[currentIndex]["question"]}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: DertamTextStyles.title.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Max selection text
                            if (maxSelection != null)
                              Text(
                                "(Select up to $maxSelection)",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: DertamTextStyles.button.fontSize,
                                  color: DertamColors.black.withOpacity(0.7),
                                ),
                              ),
                            SizedBox(height: 16),
                            // Options
                            ...questions[currentIndex]["options"]
                                .map<Widget>((option) {
                              bool isSelected = selectedOptions[currentIndex]
                                  .contains(option);
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 6),
                                child: Material(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () =>
                                        toggleSelection(currentIndex, option),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? DertamColors.blueSky
                                            : DertamColors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? DertamColors.primary
                                              : DertamColors.greyLight,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              option,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          isSelected
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: DertamColors.primary,
                                                  ),
                                                  child: Icon(
                                                    Icons.check,
                                                    color: DertamColors.white,
                                                    size: 18,
                                                  ),
                                                )
                                              : Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: DertamColors.grey),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      // Space for scrolling beyond the container
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed footer with Next button
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canProceed
                      ? () {
                          if (currentIndex < questions.length - 1) {
                            setState(() {
                              currentIndex++;
                            });
                          } else {
                            print("All questions answered: $selectedOptions");
                            // Navigate to results or next screen
                            // Navigator.of(context).pushReplacement(
                            //   MaterialPageRoute(builder: (context) => HomeScreen()),
                            // );
                            
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DertamColors.primary,
                    foregroundColor: DertamColors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: DertamColors.primary.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
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