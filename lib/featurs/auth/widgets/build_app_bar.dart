
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// /// Builds the AppBar for the LoginView and other views.
// AppBar buildAppBar(
//   BuildContext context, {
//   required String title,
//   bool showBackButton = true,
//   bool showNotification = true,
// }) {
//   return AppBar(
//     title: Text(
//       title,
//       style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//     ),
//     centerTitle: true,
//     elevation: 0,
//     actions: showNotification
//         ? [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: BlocBuilder<OrdersCubit, OrdersState>(
//                 builder: (context, state) {
//                   int count = 0;
//                   if (state is OrdersSuccess) {
//                     // عد الطلبات النشطة فقط
//                     count = state.orders
//                         .where((o) => o.status.toLowerCase() != 'delivered')
//                         .length;
//                   }
//                   return NotifecationWidgets(
//                     notificationCount: count,
//                     onTap: () {
//                       // نمرر الكيوبت الحالي لصفحة الإشعارات لضمان استمرار التدفق
//                       Navigator.pushNamed(
//                         context,
//                         AppRoutes.notificationsView,
//                         arguments: context.read<OrdersCubit>(),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ]
//         : null,
//     leading: showBackButton
//         ? IconButton(
//             icon: const SizedBox(
//               width: 7.097500324249268,
//               height: 15.84000015258789,
//               child: Icon(Icons.arrow_back_ios_new),
//             ),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           )
//         : null,
//   );
// }