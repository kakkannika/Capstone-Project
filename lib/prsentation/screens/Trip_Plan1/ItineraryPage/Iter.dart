// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'SF Pro Display',
//       ),
//       home: const ItineraryPage(),
//     );
//   }
// }

// class ItineraryPage extends StatelessWidget {
//   const ItineraryPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header section with back button, title, and menu
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Icon(Icons.home, color: Colors.black),
//                   const Text(
//                     'Trip to Siem Reap',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       const Icon(Icons.share, color: Colors.black),
//                       const SizedBox(width: 16),
//                       Icon(Icons.more_vert, color: Colors.black),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
            
//             // Main content
//             Expanded(
//               child: Container(
//                 margin: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     // Tabs
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Row(
//                         children: [
//                           const Text(
//                             'Overview',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(width: 24),
//                           const Text(
//                             'Itinerary',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.blue,
//                             ),
//                           ),
//                           const Spacer(),
//                           const Text(
//                             '\$',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     const Divider(height: 1),
                    
//                     // Date selection
//                     SizedBox(
//                       height: 60,
//                       child: ListView(
//                         scrollDirection: Axis.horizontal,
//                         children: [
//                           _buildDateTab('Wed 1/8', true),
//                           _buildDateTab('Thu 1/9', false),
//                           _buildDateTab('Fri 1/10', false),
//                           _buildDateTab('Sat 1/11', false),
//                         ],
//                       ),
//                     ),
                    
//                     // Itinerary content
//                     Expanded(
//                       child: ListView(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         children: [
//                           _buildItineraryItem(
//                             day: 'Wed 1/8',
//                             place: 'Angkor Wat',
//                             description: 'From the web: This iconic, sprawling temple complex is surrounded by a wide moat & features intricate stone carvings.',
//                             imageUrl: 'assets/angkor_wat.jpg',
//                           ),
//                           const SizedBox(height: 16),
//                           _buildPlaceHolder('Add a place'),
                          
//                           const SizedBox(height: 24),
                          
//                           _buildItineraryItem(
//                             day: 'Thu 1/9',
//                             place: 'Angkor Wat',
//                             description: 'From the web: This iconic, sprawling temple complex is surrounded by a wide moat & features intricate stone carvings.',
//                             imageUrl: 'assets/angkor_wat.jpg',
//                           ),
//                           const SizedBox(height: 16),
//                           _buildPlaceHolder('Add a place'),
                          
//                           const SizedBox(height: 24),
                          
//                           // Recommended places section
//                           const Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                             child: Text(
//                               'Recommended places',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
                          
//                           SizedBox(
//                             height: 120,
//                             child: ListView(
//                               scrollDirection: Axis.horizontal,
//                               padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                               children: [
//                                 _buildRecommendedPlace('Royal Palace'),
//                                 _buildRecommendedPlace('Royal Palace'),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
      
//       // Floating action buttons
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: () {},
//             backgroundColor: Colors.black,
//             child: const Icon(Icons.add, color: Colors.white),
//           ),
//           const SizedBox(height: 16),
//           FloatingActionButton(
//             onPressed: () {},
//             backgroundColor: Colors.black,
//             child: const Icon(Icons.map, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildDateTab(String date, bool isSelected) {
//     return Container(
//       width: 90,
//       margin: const EdgeInsets.symmetric(horizontal: 4.0),
//       decoration: BoxDecoration(
//         color: isSelected ? Colors.grey[300] : Colors.transparent,
//         borderRadius: BorderRadius.circular(4.0),
//       ),
//       child: Center(
//         child: Text(
//           date,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildItineraryItem({
//     required String day,
//     required String place,
//     required String description,
//     required String imageUrl,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             day,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.blue,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Icon(Icons.location_on, color: Colors.blue, size: 20),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       place,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       description,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4.0),
//                   image: DecorationImage(
//                     image: AssetImage(imageUrl),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildPlaceHolder(String text) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16.0),
//       padding: const EdgeInsets.symmetric(vertical: 12.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(4.0),
//       ),
//       child: Row(
//         children: [
//           const SizedBox(width: 16),
//           const Icon(Icons.location_on, color: Colors.grey),
//           const SizedBox(width: 8),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildRecommendedPlace(String name) {
//     return Container(
//       width: 150,
//       margin: const EdgeInsets.symmetric(horizontal: 4.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(8.0),
//                 topRight: Radius.circular(8.0),
//               ),
//               child: Image.asset(
//                 'assets/royal_palace.jpg',
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.grey),
//                   ),
//                   child: const Icon(Icons.add, size: 16),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }