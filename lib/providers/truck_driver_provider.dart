import 'package:brickapp/models/tuck_driver_model.dart';
import 'package:brickapp/models/user_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userProvider = StateProvider<UserModel?>((ref) {
  return null;
});

final truckProvider = Provider((ref) {
  return [
    TruckDriverModel(
      name: 'Ramon HL',
      email: 'ramon@gmail.com',
      phone: '074085674',
      location: "Luzira",
      startingPrice: 100000,
      starRating: 6,
      trips: 120,
      profileImg:
          'https://www.trucknews.com/wp-content/uploads/2020/11/iStock-170169493.jpg',
      truckImg:
          'https://media.wired.com/photos/590951f9d8c8646f38eef333/16:9/w_929,h_523,c_limit/walmart-advanced-vehicle-experience-wave-concept-truck.jpg',
    ),
    TruckDriverModel(
      name: 'Recado Glimps',
      email: 'glimps@gmail.com',
      phone: '074085674',
      location: "Kitintale",
      startingPrice: 100000,
      starRating: 4,
      trips: 100,
      profileImg:
          'https://media.istockphoto.com/id/170042558/photo/female-truck-driver-by-big-rig-with-digital-tablet.jpg?s=612x612&w=0&k=20&c=N0He6aw2ZxVnYXdPZZgwOstyNcsQYVF22gcCem7t9L4=',
      truckImg:
          'https://udtrucks.com.au/sites/default/files/styles/truck_specification_images_main/public/2022-12/Quester-CKE_512x446_2.jpg',
    ),
    TruckDriverModel(
      name: 'Tresure Bondy',
      email: 'tresure@gmail.com',
      phone: '074085674',
      location: "Kasokoso",
      startingPrice: 100000,
      starRating: 5,
      trips: 50,
      profileImg: 'https://i.insider.com/5eb4902c204ad3265a422ac7?width=700',
      truckImg:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ3Pa8vRIly1RjGD57f9MH2TfAufAH14r9ppQ&usqp=CAU',
    ),
    TruckDriverModel(
      name: 'Andrea Enidy',
      email: 'andrea@gmail.com',
      phone: '074085674',
      location: "Entebbe",
      startingPrice: 100000,
      starRating: 2,
      trips: 120,
      profileImg:
          'https://assets.website-files.com/5f70f0246e0318453837c2b9/645e490635327ca9b661bb47_becoming%20a%20truck%20driver.webp',
      truckImg:
          'https://www.hilldrup.com/wp-content/uploads/2018/01/truck-6.jpg',
    ),
    TruckDriverModel(
      name: 'Kazibwe Apuli',
      email: 'apuli@gmail.com',
      phone: '074085674',
      location: "Kawempe",
      startingPrice: 100000,
      starRating: 1,
      trips: 60,
      profileImg:
          'https://www.trucknews.com/wp-content/uploads/2022/08/Happy-truck-driver.jpg',
      truckImg:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT7VZAi1ikg_m96LDric7X_lI6MVMDC_ZmKIWy9V3PzbcR0rPRNzFOG0yF6EzhAzv7uwUU&usqp=CAU',
    ),
    TruckDriverModel(
      name: 'Robert Kiyosaki',
      email: 'kiyosaki@gmail.com',
      phone: '074085674',
      location: "Matuga",
      startingPrice: 100000,
      starRating: 9,
      trips: 120,
      profileImg:
          'https://www.trucknews.com/wp-content/uploads/2022/08/Happy-truck-driver.jpg',
      truckImg:
          'https://5.imimg.com/data5/GN/JB/PU/SELLER-34722340/tempo-transportation-service-500x500.jpg',
    ),
  ];
});
