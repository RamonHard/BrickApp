import 'package:brickapp/models/house_views_model.dart';
import 'package:brickapp/models/product_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final productProvider = StateProvider((ref) {
  return [
    ProductModel(
      uploaderName: 'Ramon Wilson',
      uploaderEmail: 'ramon@gmail.com',
      id: 1,
      description: 'Five bed rooms,seating room,compound',
      location: 'Kampala',
      price: 200,
      houseType: 'Modern Luxury Villa',
      bedRoomNum: 5,
      unitsNum: 4,
      sqft: 3200,
      reviews: 24,
      starRating: 4.0,
      isActive: true,
      uploaderPhoneNumber: 075356556587,
      productIMG:
          'https://i.pinimg.com/736x/1a/45/09/1a4509d22b165852bc8115d5073a56ea.jpg',
      uploaderIMG:
          'https://c.pxhere.com/images/a2/27/664c2356da69a393253be7908838-1634236.jpg!d',
    ),
    ProductModel(
      uploaderName: 'Diablo Lopez',
      uploaderEmail: 'diablo@gmail.com',
      uploaderIMG:
          'https://st2.depositphotos.com/1719789/6697/i/600/depositphotos_66972237-stock-photo-pretty-vietnamese-girl-with-a.jpg',
      id: 2,
      description: 'Eight bed rooms,seating room,compound',
      location: 'Muyenga',
      price: 200,
      houseType: 'Modern Family Villa',
      bedRoomNum: 8,
      sqft: 5200,
      reviews: 50,
      unitsNum: 2,
      starRating: 8.0,
      uploaderPhoneNumber: 3796360936,
      isActive: false,
      productIMG:
          'https://i.pinimg.com/736x/46/9a/f7/469af73674363bdd1c5431f02254ab39.jpg',
    ),
    ProductModel(
      uploaderName: 'Jack Dorreto',
      uploaderEmail: 'dorreto@gmail.com',
      uploaderIMG:
          'https://thumbs.dreamstime.com/b/photo-curly-wavy-charming-cute-attractive-fascinating-nice-girlfriend-showing-you-to-stop-talking-isolated-over-yellow-160184733.jpg',
      id: 3,
      description: 'Ten bed rooms,seating room,compound',
      location: 'Gayaza',
      price: 200,
      houseType: 'Dark Luxury Home',
      bedRoomNum: 10,
      unitsNum: 8,
      sqft: 8300,
      reviews: 100,
      starRating: 4.0,
      uploaderPhoneNumber: 86943705379,
      isActive: true,
      productIMG:
          'https://i.pinimg.com/736x/6f/2b/5e/6f2b5e576db99eab1076061acae111dd.jpg',
    ),
    ProductModel(
      uploaderName: 'Hardluck Hi',
      uploaderEmail: 'hardluck@gmail.com',
      uploaderIMG:
          'https://www.incimages.com/uploaded_files/image/1920x1080/getty_624206636_200013332000928034_376810.jpg',
      id: 4,
      description: 'Eight bed rooms,seating room,compound',
      location: 'Mukono',
      price: 8000,
      houseType: 'Modern Luxury Villa',
      bedRoomNum: 8,
      unitsNum: 6,
      sqft: 3200,
      reviews: 24,
      starRating: 4.0,
      uploaderPhoneNumber: 4957953590,
      isActive: true,
      productIMG:
          'https://i.pinimg.com/736x/84/54/cd/8454cdf4d678c5b7005b53b7d9401158.jpg',
    ),
    ProductModel(
      uploaderName: 'Mars Light',
      uploaderEmail: 'marslight@gmail.com',
      uploaderIMG:
          'https://i.pinimg.com/736x/ad/68/46/ad684665aa17d095acebb84557d072e2.jpg',
      id: 5,
      description: 'Five bed rooms,seating room,compound',
      location: 'Jinja',
      price: 400,
      houseType: 'Contemporary Forest House',
      bedRoomNum: 5,
      unitsNum: 3,
      sqft: 3200,
      reviews: 24,
      starRating: 4.0,
      uploaderPhoneNumber: 973587073,
      isActive: true,
      productIMG:
          'https://i.pinimg.com/736x/ed/0a/1e/ed0a1e7c196b11ba4b24f3c9ff8d23b7.jpg',
    ),
    ProductModel(
      uploaderName: 'Karz Hatz',
      uploaderEmail: 'hatz@gmail.com',
      uploaderIMG:
          'https://image.cnbcfm.com/api/v1/image/106689818-1599150563582-musk.jpg?v=1653411695',
      id: 6,
      description: 'Twelve bed rooms,seating room,compound',
      location: 'Butabika',
      price: 200,
      houseType: 'Modern Luxury Villa',
      bedRoomNum: 12,
      unitsNum: 1,
      sqft: 3200,
      reviews: 24,
      starRating: 4.0,
      uploaderPhoneNumber: 9743680946796,
      isActive: false,
      productIMG:
          'https://i.pinimg.com/736x/33/2b/c7/332bc79ff66c0e9787c3b8b4cdf70080.jpg',
    ),
  ];
});

final feauturedImagesProvider = StateProvider((ref) {
  return [
    HouseViewsModel(
      insideView:
          'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg?cs=srgb&dl=pexels-vecislavas-popa-1571460.jpg&fm=jpg',
    ),
    HouseViewsModel(
      insideView:
          'https://brabbu.com/blog/wp-content/uploads/2021/08/Modern-Contemporary-Dining-Rooms-Uncover-Timeless-and-Fierce-Design-1.jpg',
    ),
    HouseViewsModel(
      insideView:
          'https://evolveindia.co/wp-content/uploads/2021/07/3_Go-Bold-Or-Go-Home-Modern-Bedroom-Interior-Design.jpg',
    ),
    HouseViewsModel(
      insideView:
          'https://havenly.com/blog/wp-content/uploads/2021/05/99b42126-7f24-45ea-9c11-64f7a151069c-1710x970.jpg',
    ),
    HouseViewsModel(
      insideView:
          'https://images.livspace-cdn.com/plain/https://d3gq2merok8n5r.cloudfront.net/abhinav/ond-1634120396-Obfdc/jfm-1643351360-ZAORQ/bathroom-1646656868-6Yffq/lk-in-br-0144-1646656943-bNRdr.png',
    ),
    HouseViewsModel(
      insideView:
          'https://images.livspace-cdn.com/plain/https://d3gq2merok8n5r.cloudfront.net/abhinav/ond-1634120396-Obfdc/ond-2022-1664872805-f0ijv/ki-1664875090-K8xX9/kitchen-1-1-1-1667540333-NLMUz.jpg',
    ),
  ];
});
