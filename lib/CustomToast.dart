// import 'package:flutter/material.dart';

// class CustomToast extends StatefulWidget {
//   final String message;

//   const CustomToast({Key? key, required this.message}) : super(key: key);

//   @override
//   _CustomToastState createState() => _CustomToastState();
// }

// class _CustomToastState extends State<CustomToast>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<Offset> _offsetAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );

//     _offsetAnimation = Tween<Offset>(
//       begin: const Offset(0, -1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut,
//     ));

//     _animationController.forward();

//     Future.delayed(const Duration(seconds: 1), () {
//       _animationController.reverse().then((value) {
//         if (mounted) {
//           Navigator.of(context).pop();
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SlideTransition(
//       position: _offsetAnimation,
//       child: GestureDetector(
//         onVerticalDragEnd: (details) {
//           _animationController.reverse().then((value) {
//             if (mounted) {
//               Navigator.of(context).pop();
//             }
//           });
//         },
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//             margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
//             decoration: BoxDecoration(
//               color: Colors.red,
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Text(
//               widget.message,
//               style: const TextStyle(color: Colors.white, fontSize: 16),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// void showCustomToast(BuildContext context, String message) {
//   OverlayEntry overlayEntry = OverlayEntry(
//     builder: (context) => CustomToast(message: message),
//   );

//   Overlay.of(context).insert(overlayEntry);

//   Future.delayed(const Duration(seconds: 2), () {
//     overlayEntry.remove();
//   });
// }


