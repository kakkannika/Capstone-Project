import 'package:flutter/material.dart';
import 'package:tourism_app/ui/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/domain/models/place/place.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/ui/screens/dashboard/screen/destination_screen.dart';
import 'package:tourism_app/ui/providers/place_provider.dart';

class DataTables extends StatelessWidget {
  const DataTables({super.key});

  @override
  Widget build(BuildContext context) {
    final placeCrudService =
        Provider.of<PlaceProvider>(context, listen: true);

    return SizedBox(
      width: MediaQuery.of(context).size.width - 48,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('places').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final places = snapshot.data!.docs.map((doc) {
            return Place.fromFirestore(doc);
          }).toList();

          return Container(
            padding: EdgeInsets.all(DertamSpacings.m),
            decoration: BoxDecoration(
              color: DertamColors.backgroundAccent,
              borderRadius: BorderRadius.circular(DertamSpacings.radius),
            ),
            child: DataTable(
              columnSpacing: 20,
              horizontalMargin: 10,
              columns: [
                DataColumn(label: Text('Image', style: DertamTextStyles.body)),
                DataColumn(label: Text('Name', style: DertamTextStyles.body)),
                DataColumn(label: Text('Rating', style: DertamTextStyles.body)),
                DataColumn(
                    label: Text('Province', style: DertamTextStyles.body)),
                DataColumn(
                    label: Text('Category', style: DertamTextStyles.body)),
                DataColumn(label: Text('Fee', style: DertamTextStyles.body)),
                DataColumn(label: Text('Hours', style: DertamTextStyles.body)),
                DataColumn(
                    label: Text('Actions', style: DertamTextStyles.body)),
              ],
              rows: places
                  .map((place) => DataRow(cells: [
                        DataCell(
                          place.imageURL.isNotEmpty
                              ? Image.network(
                                  place.imageURL,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.image_not_supported),
                        ),
                        DataCell(Text(place.name)),
                        DataCell(
                            Text(place.averageRating.toString())),
                        DataCell(Text(place.province)),
                        DataCell(Text(place.category)),
                        DataCell(Text(
                            '\$${place.entranceFees.toStringAsFixed(2)}')),
                        DataCell(Text(place.openingHours)),
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Colors.green, size: 25),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DestinationScreen(place: place),
                                      ),
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                ),
                                SizedBox(width: DertamSpacings.s),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red, size: 25),
                                  onPressed: () async {
                                    // Delete the place using the service
                                    await placeCrudService
                                        .deletePlace(place.id);
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}