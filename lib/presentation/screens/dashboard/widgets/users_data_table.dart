import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../models/user/user_model.dart';
import '../../../../theme/theme.dart';

class UsersDataTable extends StatelessWidget {
  const UsersDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 48,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          }

          final users = snapshot.data!.docs
              .map((doc) {
                try {
                  return AppUser.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing user data: $e');
                  return null;
                }
              })
              .where((user) => user != null)
              .toList();

          if (users.isEmpty) {
            return Center(child: Text('No valid user data found'));
          }

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
                DataColumn(label: Text('Email', style: DertamTextStyles.body)),
                DataColumn(label: Text('Role', style: DertamTextStyles.body)),
                DataColumn(
                    label: Text('Actions', style: DertamTextStyles.body)),
              ],
              rows: users
                  .map((user) => DataRow(cells: [
                        DataCell(
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: DertamColors.primary.withOpacity(0.1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: user?.photoUrl != null &&
                                      user!.photoUrl!.isNotEmpty
                                  ? Image.network(
                                      user.photoUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/avatar.jpg',
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/avatar.jpg',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        DataCell(Text(user?.displayName ?? 'N/A')),
                        DataCell(Text(user?.email ?? 'N/A')),
                        DataCell(Text(user?.role != null
                            ? user!.role == UserRole.admin
                                ? 'Admin'
                                : 'User'
                            : 'N/A')),
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
                                  onPressed: () {},
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
                                  onPressed: () async {},
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
