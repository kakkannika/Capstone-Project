// import 'package:flutter/material.dart';

// class ImageScreen extends StatelessWidget {
//   final String imageUrl;

//   const ImageScreen({Key? key, required this.imageUrl}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Image Viewer'),
//       ),
//       body: Center(
//         child: Image.network(
//           imageUrl,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Container(
//               color: Colors.grey[300],
//               child: const Icon(Icons.image, size: 80, color: Colors.grey),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }