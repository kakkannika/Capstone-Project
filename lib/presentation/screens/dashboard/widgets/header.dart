// import 'package:flutter/material.dart';
// import 'package:tourism_app/presentation/screens/dashboard/Screens/main_screen.dart';
// import 'package:tourism_app/theme/theme.dart';

// class Header extends StatelessWidget {
//   final ScreenType currentScreen;
//   const Header({
//     super.key,
//     required this.currentScreen,
//   });

//   String _getScreenTitle() {
//     switch (currentScreen) {
//       case ScreenType.dashboard:
//         return 'Dashboard';
//       case ScreenType.destination:
//         return 'Destinations';
//       case ScreenType.users:
//         return 'Users';
//       case ScreenType.notifications:
//         return 'Notifications';
//       case ScreenType.expenses:
//         return 'Expenses';
//       case ScreenType.settings:
//         return 'Settings';
//       default:
//         return 'Dashboard';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Text(_getScreenTitle(),
//             style:
//                 DertamTextStyles.heading.copyWith(color: DertamColors.primary)),
//         Spacer(
//           flex: 2,
//         ),
//         Expanded(child: SearchField()),
//         ProfileCard()
//       ],
//     );
//   }
// }

// class ProfileCard extends StatelessWidget {
//   const ProfileCard({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//           horizontal: DertamSpacings.m, vertical: DertamSpacings.m / 2),
//       margin: EdgeInsets.only(left: DertamSpacings.m),
//       decoration: BoxDecoration(
//         color: DertamColors.white,
//         borderRadius:
//             BorderRadius.all(Radius.circular(DertamSpacings.radius / 2)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: Offset(0, 3), // changes position of shadow
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Image.asset(
//             'lib/assets/images/kannika.jpg',
//             height: 38,
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 8),
//             child: Text('Kannika',
//                 style: DertamTextStyles.body
//                     .copyWith(color: DertamColors.neutralLighter)),
//           ),
//           Icon(Icons.keyboard_arrow_down, color: DertamColors.neutralLighter)
//         ],
//       ),
//     );
//   }
// }

// class SearchField extends StatelessWidget {
//   const SearchField({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.all(Radius.circular(DertamSpacings.radius)),
//         color: DertamColors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: 'Search',
//           fillColor: DertamColors.white,
//           filled: true,
//           suffixIcon: InkWell(
//             onTap: () {},
//             child: Container(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: DertamSpacings.m,
//                     vertical: DertamSpacings.m / 2),
//                 margin: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: DertamColors.primary,
//                   borderRadius:
//                       BorderRadius.all(Radius.circular(DertamSpacings.radius)),
//                 ),
//                 child: Icon(
//                   Icons.search,
//                   color: DertamColors.white,
//                 )),
//           ),
//           border: OutlineInputBorder(
//             borderRadius:
//                 BorderRadius.all(Radius.circular(DertamSpacings.radius)),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }
// }
