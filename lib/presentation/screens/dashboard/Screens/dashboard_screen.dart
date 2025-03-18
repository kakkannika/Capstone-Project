import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/screens/dashboard/Screens/destination_screen.dart';
import 'package:tourism_app/presentation/screens/dashboard/widgets/data_table.dart';
import 'package:tourism_app/theme/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DertamColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              margin: EdgeInsets.all(DertamSpacings.m),
              padding: EdgeInsets.all(DertamSpacings.m),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DertamSpacings.radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  // Search Bar
                  Container(
                    width: 300,
                    height: 40,
                    padding: EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: DertamSpacings.m),
                  // Notifications
                  // IconButton(
                  //   icon: Stack(
                  //     children: [
                  //       Icon(Icons.notifications_outlined),
                  //       Positioned(
                  //         right: 0,
                  //         top: 0,
                  //         child: Container(
                  //           padding: EdgeInsets.all(2),
                  //           decoration: BoxDecoration(
                  //             color: Colors.red,
                  //             borderRadius: BorderRadius.circular(6),
                  //           ),
                  //           constraints: BoxConstraints(
                  //             minWidth: 12,
                  //             minHeight: 12,
                  //           ),
                  //           child: Text(
                  //             '5',
                  //             style: TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 8,
                  //             ),
                  //             textAlign: TextAlign.center,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  //   onPressed: () {},
                  // ),
                  SizedBox(width: DertamSpacings.s),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(DertamSpacings.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: InfoCard(
                            title: 'Site Traffic',
                            value: '12',
                            trend: '+2.5%',
                            color: Colors.red[400]!,
                            icon: Icons.trending_up,
                          ),
                        ),
                        SizedBox(width: DertamSpacings.m),
                        Expanded(
                          child: InfoCard(
                            title: 'Site Traffic',
                            value: '278',
                            trend: '+3.1%',
                            color: Colors.blue[400]!,
                            icon: Icons.bar_chart,
                          ),
                        ),
                        SizedBox(width: DertamSpacings.m),
                        Expanded(
                          child: InfoCard(
                            title: 'Site Traffic',
                            value: '36%',
                            trend: '+4.9%',
                            color: Colors.green[400]!,
                            icon: Icons.show_chart,
                          ),
                        ),
                        SizedBox(width: DertamSpacings.m),
                        Expanded(
                          child: InfoCard(
                            title: 'Site Traffic',
                            value: '849',
                            trend: '+1.2%',
                            color: Colors.orange[400]!,
                            icon: Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: DertamSpacings.l),
                    // Places Table
                    Container(
                      padding: EdgeInsets.all(DertamSpacings.m),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(DertamSpacings.radius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Places',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DestinationScreen(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.add),
                                label: Text('Add New Place'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DertamColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: DertamSpacings.m),
                          DataTables(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final Color color;
  final IconData icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DertamSpacings.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DertamSpacings.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: DertamSpacings.s),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Icon(icon, color: color),
            ],
          ),
          SizedBox(height: DertamSpacings.s),
          Text(
            trend,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
