import 'package:brickapp/models/add_post_model.dart';
import 'package:brickapp/models/destination_model.dart';
import 'package:brickapp/models/product_model.dart';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/pages/client_pages/booking-pages/appartment_booking_page.dart';
import 'package:brickapp/pages/client_pages/booking-pages/booking_page_for_more_view.dart';
import 'package:brickapp/pages/client_pages/booking-pages/more_product_booking_page.dart';
import 'package:brickapp/pages/client_pages/change_password.dart';
import 'package:brickapp/pages/client_pages/client_book_tuck_Services/Home.dart';
import 'package:brickapp/pages/client_pages/fave_items.dart';
import 'package:brickapp/pages/client_pages/home_page.dart';
import 'package:brickapp/pages/client_pages/edit_profile.dart';
import 'package:brickapp/pages/client_pages/history_page.dart';
import 'package:brickapp/pages/client_pages/main_favourite.dart';
import 'package:brickapp/pages/client_pages/profile_page.dart';
import 'package:brickapp/pages/client_pages/transporter.dart';
import 'package:brickapp/pages/client_pages/favorite_s_provider.dart';
import 'package:brickapp/pages/client_pages/view_more_products.dart';
import 'package:brickapp/pages/client_pages/view_selected_product.dart';
import 'package:brickapp/pages/pManagerPages/add_post.dart';
import 'package:brickapp/pages/pManagerPages/edit_post.dart';
import 'package:brickapp/pages/sProviderPages/post_truck.dart';
import 'package:brickapp/pages/pManagerPages/price_demo.dart';
import 'package:brickapp/pages/sProviderPages/profile.dart';
import 'package:brickapp/pages/sProviderPages/requests_for_t_and_l.dart';
import 'package:brickapp/pages/sProviderPages/your_posts.dart';
import 'package:brickapp/pages/main_display.dart';
import 'package:brickapp/pages/onboardingPages/login.dart';
import 'package:flutter/material.dart';

class NavigatorKeys {
  static GlobalKey<NavigatorState> baseKey = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> mainKey = GlobalKey<NavigatorState>();
}

class BaseNavigation {
  static String indexRoute = "/";
  static String mainDisplayRoute = "/mainDisplayRoute";
  static String logInPageRoute = "/logInPageRoute";

  static Route onGenerateRoute(RouteSettings settings) {
    if (settings.name == mainDisplayRoute) {
      return MaterialPageRoute(builder: (context) => MainDisplay());
    }
    if (settings.name == logInPageRoute) {
      return MaterialPageRoute(builder: (context) => LoginPage());
    }

    return MaterialPageRoute(builder: (context) => LoginPage());
  }

  static navigateToRoute(String routeName, {Object? data}) {
    NavigatorKeys.mainKey.currentState!.pushNamed(routeName, arguments: data);
  }
}

class MainNavigation {
  // static String homePageRoute = "/homePageRoute";
  static String logOutRoute = "/logOutRoute";

  static String requestsRoute = "/requestsRoute";
  static String mainContent = "/mainContent";

  static String sortByRoute = "/sortByRoute";
  static String clientHomePageRoute = "/clientHomePageRoute";
  static String transporterRoute = "/transporterRoute";
  static String postViewRoute = "/postViewRoute";
  static String landAndTruckProfileRoute = "/landAndTruckProfileRoute";
  static String addPostRoute = "/addPostRoute";
  static String postTruckRoute = "/postTruckRoute";

  static String clientprofilePageRoute = "/clientprofilePageRoute";
  static String clientHistoryPageRoute = "/clientHistoryPageRoute";
  static String clientEditProfilePageRoute = "/clientEditProfilePageRoute";
  static String viewFavouritePageRoute = "/viewFavouritePageRoute";
  static String mainFavouriteDisplayRoute = "/mainFavouriteDisplayRoute";

  static String viewFavItemPage = "/viewFavItemPage";
  static String changePasswordRoute = "/changePasswordRoute";

  static String priceDemoRoute = "/priceDemoRoute";
  static String bookingPageForMoreRoute = "/bookingPageForMoreRoute";
  // static String truckPageRoute = "/truckPageRoute";
  static String viewSelectedProductRoute = "/viewSelectedProductRoute";
  static String viewMoreProducts = "/viewMoreProductsRoute";
  static String moreBookingRoute = "/moreBookingRoute";

  static String editPostPae = "/editPostPageRoute";
  static String paymentMethodRoute = "/paymentMethodRoute";

  static Route onGenerateRoute(RouteSettings settings, bool isClient) {
    print("Route ${settings.name}");
    if (settings.name == clientHistoryPageRoute) {
      return MaterialPageRoute(builder: (context) => ClientHistoryPage());
    }
    if (settings.name == clientHomePageRoute) {
      return MaterialPageRoute(builder: (context) => HomePage());
    }
    if (settings.name == transporterRoute) {
      return MaterialPageRoute(builder: (context) => FindTransporterPage());
    }

    if (settings.name == clientprofilePageRoute) {
      return MaterialPageRoute(builder: (context) => ClientProfile());
    }
    if (settings.name == clientEditProfilePageRoute) {
      return MaterialPageRoute(builder: (context) => EditProfile());
    }
    if (settings.name == viewFavouritePageRoute) {
      return MaterialPageRoute(builder: (context) => FavoriteSProvider());
    }
    if (settings.name == mainFavouriteDisplayRoute) {
      return MaterialPageRoute(builder: (context) => MainFavoriteDisplay());
    }
    if (settings.name == viewFavItemPage) {
      return MaterialPageRoute(builder: (context) => FavouriteItemList());
    }
    if (settings.name == changePasswordRoute) {
      return MaterialPageRoute(builder: (context) => ChangeClientPassword());
    }
    if (settings.name == postViewRoute) {
      return MaterialPageRoute(builder: (context) => ViewYourPosts());
    }
    if (settings.name == addPostRoute) {
      return MaterialPageRoute(builder: (context) => AddPost());
    }
    if (settings.name == postTruckRoute) {
      return MaterialPageRoute(builder: (context) => PostTruckPage());
    }
    if (settings.name == landAndTruckProfileRoute) {
      return MaterialPageRoute(builder: (context) => LandAndTruckProfilePage());
    }

    if (settings.name == requestsRoute) {
      return MaterialPageRoute(builder: (context) => LandAndTruckRequestPage());
    }
    // if (settings.name == bookingPageRoute) {
    //   return MaterialPageRoute(
    //     builder:
    //         (context) =>
    //             BookingPage(selectedItem: settings.arguments as ProductModel),
    //   );
    // }
    if (settings.name == editPostPae) {
      return MaterialPageRoute(
        builder:
            (context) => EditPostPage(
              editPostModel: settings.arguments as MoreProductViewModel,
            ),
      );
    }
    if (settings.name == bookingPageForMoreRoute) {
      return MaterialPageRoute(
        builder:
            (context) => BookingPageForMore(
              selectedItem: settings.arguments as MoreProductViewModel,
            ),
      );
    }
    if (settings.name == priceDemoRoute) {
      return MaterialPageRoute(builder: (context) => PriceDemo());
    }
    if (settings.name == paymentMethodRoute) {
      return MaterialPageRoute(
        builder:
            (context) => ApartmentBookingPage(
              productModel: settings.arguments as ProductModel,
            ),
        // BookingPageForMore(
        //   selectedItem: settings.arguments as MoreProductViewModel,
        // ),
      );
    }

    if (settings.name == viewMoreProducts) {
      return MaterialPageRoute(
        builder:
            (context) => ViewMoreProducts(
              productModel: settings.arguments as PropertyModel,
            ),
      );
    }
    if (settings.name == moreBookingRoute) {
      return MaterialPageRoute(
        builder:
            (context) => MoreProductBookingPage(
              moreProductViewModel: settings.arguments as MoreProductViewModel,
            ),
      );
    }
    if (settings.name == viewSelectedProductRoute) {
      return MaterialPageRoute(
        builder:
            (context) => ViewSelectedProduct(
              selectedProduct: settings.arguments as PropertyModel,
            ),
      );
    }
    if (settings.name == logOutRoute) {
      return MaterialPageRoute(builder: (context) => LoginPage());
    }

    return MaterialPageRoute(
      builder: (context) {
        print("Is Client $isClient");
        if (isClient) {
          return HomePage();
        } else {
          return LandAndTruckRequestPage();
        }
      },
    );
  }

  static navigateToRoute(String routeName, {Object? data}) {
    NavigatorKeys.mainKey.currentState!.pushNamed(routeName, arguments: data);
  }
}
