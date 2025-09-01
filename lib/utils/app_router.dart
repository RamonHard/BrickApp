// // lib/app_router.dart
// import 'package:brickapp/models/destination_model.dart';
// import 'package:brickapp/models/product_model.dart';
// import 'package:brickapp/models/property_model.dart';
// import 'package:brickapp/pages/client_pages/booking-pages/appartment_booking_page.dart';
// import 'package:brickapp/pages/client_pages/booking-pages/booking_page_for_more_view.dart';
// import 'package:brickapp/pages/client_pages/booking-pages/more_product_booking_page.dart';
// import 'package:brickapp/pages/client_pages/change_password.dart';
// import 'package:brickapp/pages/client_pages/client_book_tuck_Services/Home.dart';
// import 'package:brickapp/pages/client_pages/edit_profile.dart';
// import 'package:brickapp/pages/client_pages/fave_items.dart';
// import 'package:brickapp/pages/client_pages/favorite_s_provider.dart';
// import 'package:brickapp/pages/client_pages/history_page.dart';
// import 'package:brickapp/pages/client_pages/home_page.dart';
// import 'package:brickapp/pages/client_pages/main_favourite.dart';
// import 'package:brickapp/pages/client_pages/profile_page.dart';
// import 'package:brickapp/pages/client_pages/view_more_products.dart';
// import 'package:brickapp/pages/client_pages/view_selected_product.dart';
// import 'package:brickapp/pages/main_display.dart';
// import 'package:brickapp/pages/onboardingPages/login.dart';
// import 'package:brickapp/pages/pManagerPages/add_post.dart';
// import 'package:brickapp/pages/pManagerPages/edit_post.dart';
// import 'package:brickapp/pages/pManagerPages/price_demo.dart';
// import 'package:brickapp/pages/sProviderPages/post_truck.dart';
// import 'package:brickapp/pages/sProviderPages/profile.dart';
// import 'package:brickapp/pages/sProviderPages/requests_for_t_and_l.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// // Import your pages

// // Import models if passing data

// final GoRouter appRouter = GoRouter(
//   initialLocation: "/login",
//   routes: [
//     // Auth
//     GoRoute(path: "/login", builder: (context, state) => LoginPage()),

//     // Main
//     GoRoute(path: "/main", builder: (context, state) => MainDisplay()),

//     // Client Pages
//     GoRoute(path: "/home", builder: (context, state) => HomePage()),
//     GoRoute(path: "/profile", builder: (context, state) => ClientProfile()),
//     GoRoute(path: "/editProfile", builder: (context, state) => EditProfile()),
//     GoRoute(path: "/history", builder: (context, state) => ClientHistoryPage()),
//     GoRoute(
//       path: "/changePassword",
//       builder: (context, state) => ChangeClientPassword(),
//     ),

//     // Favourites
//     GoRoute(
//       path: "/favourites",
//       builder: (context, state) => FavoriteSProvider(),
//     ),
//     GoRoute(
//       path: "/mainFavourite",
//       builder: (context, state) => MainFavoriteDisplay(),
//     ),
//     GoRoute(
//       path: "/faveItems",
//       builder: (context, state) => FavouriteItemList(),
//     ),

//     // Transport & Posts
//     GoRoute(
//       path: "/transporter",
//       builder: (context, state) => FindTransporterPage(),
//     ),
//     GoRoute(path: "/addPost", builder: (context, state) => AddPost()),
//     GoRoute(
//       path: "/editPost",
//       builder: (context, state) {
//         final args = state.extra as ProductModel;
//         return EditPostPage(editPostModel: args);
//       },
//     ),
//     GoRoute(path: "/postTruck", builder: (context, state) => PostTruckPage()),

//     // Service Provider
//     GoRoute(
//       path: "/sProviderProfile",
//       builder: (context, state) => LandAndTruckProfilePage(),
//     ),
//     GoRoute(
//       path: "/requests",
//       builder: (context, state) => LandAndTruckRequestPage(),
//     ),

//     // Pricing
//     GoRoute(path: "/priceDemo", builder: (context, state) => PriceDemo()),

//     // Bookings
//     GoRoute(
//       path: "/bookingForMore",
//       builder: (context, state) {
//         final args = state.extra as MoreProductViewModel;
//         return BookingPageForMore(selectedItem: args);
//       },
//     ),
//     GoRoute(
//       path: "/apartmentBooking",
//       builder: (context, state) {
//         final args = state.extra as ProductModel;
//         return ApartmentBookingPage(productModel: args);
//       },
//     ),
//     GoRoute(
//       path: "/viewMoreProducts",
//       builder: (context, state) {
//         final args = state.extra as PropertyModel;
//         return ViewMoreProducts(productModel: args);
//       },
//     ),
//     GoRoute(
//       path: "/moreBooking",
//       builder: (context, state) {
//         final args = state.extra as MoreProductViewModel;
//         return MoreProductBookingPage(moreProductViewModel: args);
//       },
//     ),
//     GoRoute(
//       path: "/viewSelectedProduct",
//       builder: (context, state) {
//         final args = state.extra as PropertyModel;
//         return ViewSelectedProduct(selectedProduct: args);
//       },
//     ),
//   ],
// );
