class AppUrls {
  static const String baseUrl = 'http://127.17.0.1:3000';

  // Auth
  static const String login = '$baseUrl/users/login';
  static const String register = '$baseUrl/users/register';
  static const String profile = '$baseUrl/users/profile';
  static const String editProfile = '$baseUrl/users/edit-profile';
  static const String upgrade = '$baseUrl/users/upgrade';

  // Properties
  static const String properties = '$baseUrl/properties';
  static const String myListings = '$baseUrl/properties/my-listings';

  // Vehicles
  static const String vehicles = '$baseUrl/vehicles';
  static const String vehicleTypes = '$baseUrl/vehicles/types';
  static const String myVehicles = '$baseUrl/vehicles/my-vehicles';
  static const String addVehicle = '$baseUrl/vehicles/add';

  // Transport
  static const String transportCalculate = '$baseUrl/transport/calculate';
  static const String transportBook = '$baseUrl/transport/book';
  static const String truckTypes = '$baseUrl/transport/truck-types';
  static const String calculateTransport = '$baseUrl/transport/calculate';
  static const String bookTransport = '$baseUrl/bookings/transport';
  // Property Bookings
  static const String createBooking = '$baseUrl/bookings/create';

  // Favourites
  static const String favourites = '$baseUrl/favourites';
  static const String addFavourite = '$baseUrl/favourites/add';

  // Payments
  static const String initiatePayment = '$baseUrl/payments/initiate';
  static const String myPayments = '$baseUrl/payments/my-payments';
  static const String publicSettings = '$baseUrl/settings/public';
  static String propertyById(int id) => '$baseUrl/properties/$id';
  static String togglePropertyStatus(int id) =>
      '$baseUrl/properties/$id/toggle-status';
  static const String myBookings = '$baseUrl/bookings/history/property';
  static const String myTransportBookings =
      '$baseUrl/bookings/history/transport';
  // Property Manager Stats
  static const String managerStats = '$baseUrl/properties/stats';

  // Bookings
  static const String bookProperty = '$baseUrl/bookings/property';
  static String refundBooking(int id) =>
      '$baseUrl/bookings/property/$id/refund';
  static String respondToTransport(int id) =>
      '$baseUrl/bookings/transport/$id/respond';
  static String payForTransport(int id) =>
      '$baseUrl/bookings/transport/$id/pay';
  static const String managerRequests = '$baseUrl/bookings/requests/manager';
  static const String providerRequests = '$baseUrl/bookings/requests/provider';
  static const String clientRequests = '$baseUrl/bookings/requests/client';
  static String approveRefund(int id) =>
      '$baseUrl/bookings/property/$id/approve-refund';
}
