// import 'package:flutter/material.dart';

// class SideMenu extends StatelessWidget {
//   final List<String> menuItems;
//   final int selectedIndex;
//   final Function(int) onItemSelected;

//   const SideMenu({
//     required this.menuItems,
//     required this.selectedIndex,
//     required this.onItemSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 200,
//       color: Colors.blueAccent,
//       child: ListView.builder(
//         padding: EdgeInsets.zero,
//         itemCount: menuItems.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () => onItemSelected(index),
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
//               color: selectedIndex == index ? Colors.blue : Colors.blueAccent,
//               child: Text(
//                 menuItems[index],
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
