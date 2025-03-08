// import 'package:flutter/material.dart';

// class RecommendedPlacesSection extends StatefulWidget {
//   const RecommendedPlacesSection({Key? key}) : super(key: key);

//   @override
//   State<RecommendedPlacesSection> createState() =>
//       _RecommendedPlacesSectionState();
// }

// class _RecommendedPlacesSectionState extends State<RecommendedPlacesSection> {
//   bool isPlacesExpanded = true; // Set to true initially to be expanded

//   //Dummy data model
//   List<Place> places = [
//     Place(
//         name: 'Angkor Wat',
//         imageUrl:
//             'https://lp-cms-production.imgix.net/2025-01/Cambodia-Angkor-Wat-Waj-shutterstockRF312461543-crop.jpg?auto=format&q=72&w=1440&h=810&fit=crop'),
//     Place(
//         name: 'Bayon Temple',
//         imageUrl:
//             'https://lp-cms-production.imgix.net/2025-01/Cambodia-Angkor-Wat-Waj-shutterstockRF312461543-crop.jpg?auto=format&q=72&w=1440&h=810&fit=crop'),
//     Place(
//         name: 'Ta Prohm',
//         imageUrl:
//             'https://lp-cms-production.imgix.net/2025-01/Cambodia-Angkor-Wat-Waj-shutterstockRF312461543-crop.jpg?auto=format&q=72&w=1440&h=810&fit=crop'),
//     Place(
//         name: 'Royal Palace',
//         imageUrl:
//             'https://lp-cms-production.imgix.net/2025-01/Cambodia-Angkor-Wat-Waj-shutterstockRF312461543-crop.jpg?auto=format&q=72&w=1440&h=810&fit=crop'),
//     Place(
//         name: 'Koh Rong Island',
//         imageUrl:
//             'https://lp-cms-production.imgix.net/2025-01/Cambodia-Angkor-Wat-Waj-shutterstockRF312461543-crop.jpg?auto=format&q=72&w=1440&h=810&fit=crop'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return _buildRecommendedPlacesSection();
//   }

//   Widget _buildSectionHeader(String title, bool isExpanded, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlaceCard(String imageUrl, String placeName) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey.shade300, width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 imageUrl,
//                 width: 60,
//                 height: 60,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 placeName,
//                 style: const TextStyle(fontSize: 16),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.add),
//               onPressed: () {
//                 // Handle adding the place
//                 print('Added $placeName');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRecommendedPlacesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader('Recommended Places', isPlacesExpanded, () {
//           setState(() {
//             isPlacesExpanded = !isPlacesExpanded;
//           });
//         }),
//         if (isPlacesExpanded)
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Column(
//               children: [
//                 ListView.separated(
//                   physics:
//                       const NeverScrollableScrollPhysics(), // to disable ListView's own scrolling
//                   shrinkWrap: true, // Important to make ListView take only required space
//                   itemCount: places.length,
//                   separatorBuilder: (BuildContext context, int index) =>
//                       const SizedBox(height: 10),
//                   itemBuilder: (BuildContext context, int index) {
//                     return _buildPlaceCard(places[index].imageUrl, places[index].name);
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Navigate to attractions search
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.search, size: 18),
//                       SizedBox(width: 8),
//                       Text(
//                         'BROWSE MORE ATTRACTIONS',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
// }

// class Place {
//   String name;
//   String imageUrl;

//   Place({required this.name, required this.imageUrl});
// }
