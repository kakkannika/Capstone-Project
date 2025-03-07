import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wishlist App',
      home: WishlistScreen(),
    );
  }
}

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final List<Map<String, String>> favorites = [
    {
      'title': 'Independence Monument',
      'location': 'Phnom Penh, Cambodia',
      'image': 'lib/assets/trip_plan_images/indepenence_monument.jpg', 
    },
    {
      'title': 'Independence Monument',
      'location': 'Phnom Penh, Cambodia',
      'image': 'lib/assets/trip_plan_images/indepenence_monument.jpg', 
    },
     {
      'title': 'Independence Monument',
      'location': 'Phnom Penh, Cambodia',
      'image': 'lib/assets/trip_plan_images/indepenence_monument.jpg', 
    },
     {
      'title': 'Independence Monument',
      'location': 'Phnom Penh, Cambodia',
      'image': 'lib/assets/trip_plan_images/indepenence_monument.jpg', 
    },
  ];

  void _showDetails(Map<String, String> place) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(place['title']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(place['image']!),
              SizedBox(height: 10),
              Text(place['location']!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  favorites.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: InkWell(
              onTap: () => _showDetails(favorites[index]),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(favorites[index]['image']!),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          favorites[index]['title']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          favorites[index]['location']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () => _confirmDelete(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}