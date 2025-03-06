// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:tourism_app/models/place/place.dart';

// class PlaceProvider with ChangeNotifier {
//   List<Place> _places = [];

//   List<Place> get places => _places;

//   // Fetch places from Firestore
//   Future<void> fetchPlaces() async {
//     try {
//       final firestore = FirebaseFirestore.instance;
//       final querySnapshot = await firestore.collection('places').get();

//       _places = querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         return Place(
//           id: doc.id,
//           name: data['name'],
//           description: data['description'],
//           location: GeoPoint(
//             data['location']['latitude'],
//             data['location']['longitude'],
//           ),
//           imageURL: List<String>.from(data['imageURL']),
//           category: data['category'],
//           averageRating: data['averageRating'],
//           entranceFees: data['entranceFees'],
//           openingHours: data['openingHours'],
//         );
//       }).toList();

//       notifyListeners();
//     } catch (e) {
//       print('Error fetching places: $e');
//     }
//   }
// }
