import 'package:brickapp/models/product_model.dart';
import 'package:brickapp/models/destination_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final viewMoreProductProvider = Provider((ref) {
  return [
    MoreProductViewModel(
      img:
          'https://i.pinimg.com/736x/60/c3/a7/60c3a7e1ff908ddad6a8a95d0cb748f9.jpg',
      destinationTitle: 'London',
      product: ProductModel(
        uploaderName: 'Mars Light',
        uploaderEmail: 'marslight@gmail.com',
        uploaderIMG:
            'https://i.pinimg.com/736x/ad/68/46/ad684665aa17d095acebb84557d072e2.jpg',
        id: 5,
        description: 'Five bed rooms, seating room, compound',
        location: 'Jinja',
        price: 200000,
        discount: 75000,
        houseType: 'Contemporary Forest House',
        bedRoomNum: 5,
        unitsNum: 3,
        amenities: ['Furnished', 'Security'],
        sqft: 3200,
        reviews: 24,
        starRating: 4.0,
        uploaderPhoneNumber: 973587073,
        isActive: true,
        productIMG:
            'https://i.pinimg.com/736x/ed/0a/1e/ed0a1e7c196b11ba4b24f3c9ff8d23b7.jpg',
      ),
    ),

    // 1️⃣ Unique Product
    MoreProductViewModel(
      img:
          'https://i.pinimg.com/736x/9b/e6/99/9be699e36c437d2eb9d70b01df0e79ef.jpg',
      destinationTitle: 'Paris',
      product: ProductModel(
        uploaderName: 'Alice Springs',
        uploaderEmail: 'alice.springs@example.com',
        uploaderIMG:
            'https://i.pinimg.com/736x/5e/8a/8c/5e8a8ce512ad06f9f0e4c4b9c83ee509.jpg',
        id: 6,
        description: 'Luxury apartment with panoramic Eiffel views',
        location: 'Central Paris',
        price: 200000,
        discount: 75000,
        houseType: 'Luxury Apartment',
        bedRoomNum: 3,
        unitsNum: 5,
        amenities: ['Elevator', 'Air Conditioning', 'Balcony'],
        sqft: 1800,
        reviews: 120,
        starRating: 4.8,
        uploaderPhoneNumber: 748292019,
        isActive: true,
        productIMG:
            'https://i.pinimg.com/736x/47/aa/3d/47aa3d9677d5f41ac44f8c5c2bb27a07.jpg',
      ),
    ),

    // 2️⃣ Unique Product
    MoreProductViewModel(
      img:
          'https://i.pinimg.com/736x/f5/48/cb/f548cb4bbd13f7d4db1d7d4503d229f6.jpg',
      destinationTitle: 'Tokyo',
      product: ProductModel(
        uploaderName: 'Kenji Yamato',
        uploaderEmail: 'kenji.yamato@tokyorealestate.jp',
        uploaderIMG:
            'https://i.pinimg.com/736x/70/cf/ed/70cfedc3f7d6ef9ef278da38947efb1e.jpg',
        id: 7,
        description: 'Compact smart home with advanced tech features',
        location: 'Shibuya, Tokyo',
        price: 200000,
        discount: 75000,
        houseType: 'Modern Smart Apartment',
        bedRoomNum: 2,
        unitsNum: 10,
        amenities: ['Smart Home Features', 'Gym Access', '24hr Security'],
        sqft: 950,
        reviews: 78,
        starRating: 4.5,
        uploaderPhoneNumber: 907356412,
        isActive: true,
        productIMG:
            'https://i.pinimg.com/736x/62/21/bf/6221bf2cb936740e7ef5fb657a22fd08.jpg',
      ),
    ),

    // 3️⃣ Unique Product
    MoreProductViewModel(
      img:
          'https://i.pinimg.com/736x/a1/f6/ef/a1f6efc8533b9d6db0c7c85383f7aaeb.jpg',
      destinationTitle: 'Cape Town',
      product: ProductModel(
        uploaderName: 'Nomsa Dlamini',
        uploaderEmail: 'nomsa.homes@capetownreal.co.za',
        uploaderIMG:
            'https://i.pinimg.com/736x/98/6a/b5/986ab5ac30dc872e4a289383af08f64f.jpg',
        id: 8,
        description: '4 Bedroom villa overlooking Table Mountain',
        location: 'Constantia, Cape Town',
        price: 200000,
        discount: 75000,
        houseType: 'Villa',
        bedRoomNum: 4,
        unitsNum: 2,
        amenities: ['Swimming Pool', 'Fireplace', 'Private Garden'],
        sqft: 2700,
        reviews: 33,
        starRating: 4.2,
        uploaderPhoneNumber: 835678213,
        isActive: true,
        productIMG:
            'https://i.pinimg.com/736x/c3/0a/21/c30a21c7d4cfaf682ce8c9099fd3bcb0.jpg',
      ),
    ),

    // 4️⃣ Unique Product
    MoreProductViewModel(
      img:
          'https://i.pinimg.com/736x/f2/15/6e/f2156e5a3a4fa7fc228e34bc54159e9a.jpg',
      destinationTitle: 'Sydney',
      product: ProductModel(
        uploaderName: 'Ethan Clarke',
        uploaderEmail: 'ethan.clarke@aushomes.au',
        uploaderIMG:
            'https://i.pinimg.com/736x/2f/3b/96/2f3b964ab30ef4c819f11616e74c0a45.jpg',
        id: 9,
        description: 'Seaside penthouse with private rooftop pool',
        location: 'Bondi Beach, Sydney',
        price: 1200000,
        discount: 75000,
        houseType: 'Penthouse',
        bedRoomNum: 3,
        unitsNum: 1,
        amenities: ['Private Rooftop Pool', 'Ocean View', 'Concierge'],
        sqft: 2000,
        reviews: 64,
        starRating: 4.9,
        uploaderPhoneNumber: 654981247,
        isActive: true,
        productIMG:
            'https://i.pinimg.com/736x/b3/8f/3b/b38f3b1f7ab6d3f6915d87f63c7c2b8f.jpg',
      ),
    ),

    // 5️⃣ Unique Product
    MoreProductViewModel(
      img:
          'https://i.pinimg.com/736x/93/04/6f/93046f5648b61f1f4c3a1cfd2f9b9f08.jpg',
      destinationTitle: 'New York',
      product: ProductModel(
        uploaderName: 'Jordan Rivera',

        uploaderEmail: 'jordan.rivera@nyhomes.com',
        uploaderIMG:
            'https://i.pinimg.com/736x/7d/ca/45/7dca45f91f5adfd3559d9c771cb8cdef.jpg',
        id: 10,
        description: 'Open loft with skyline views',
        location: 'Brooklyn, New York',
        price: 200000,
        discount: 75000,
        houseType: 'Industrial Loft',
        bedRoomNum: 2,
        unitsNum: 4,
        amenities: ['Loft Design', 'Open Kitchen', 'Rooftop Access'],
        sqft: 1400,
        reviews: 89,
        starRating: 4.3,
        uploaderPhoneNumber: 932745019,
        isActive: true,
        productIMG:
            'https://i.pinimg.com/736x/11/65/43/116543f5ec81c3c672f2c1b2738f34d4.jpg',
      ),
    ),
  ];
});
