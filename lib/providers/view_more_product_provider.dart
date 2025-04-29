import 'package:brickapp/models/destination_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final viewMoreProductProvider = Provider((ref) {
  return [
    MoreProductViewModel(
      location: 'Kampala',
      contact: 075356556587,
      id: 2,
      img:
          'https://i.pinimg.com/736x/60/c3/a7/60c3a7e1ff908ddad6a8a95d0cb748f9.jpg',
      destinationTitle: 'London',
      price: 2000.0,
      description:
          'Luxsurious lekgrrlrjhjhojjhrrh gojjrblbohj5bnobjrr lfgdhhg4nrjvoejhvcscecjievvbhb eggnklbtnb',
    ),
    MoreProductViewModel(
      location: 'Kawempe',
      contact: 3796360936,
      id: 3,
      img:
          'https://i.pinimg.com/736x/54/8d/86/548d86c6dae590449cc3c32da98e8ce8.jpg',
      destinationTitle: 'France',
      price: 2500.0,
      description: 'Flat apertments rgbtj7ugunjukhgrsjgmgf',
    ),
    MoreProductViewModel(
      location: 'Luzira',
      contact: 86943705379,
      id: 4,
      img:
          'https://i.pinimg.com/736x/6b/10/90/6b10907234f44d13666f06439b840acf.jpg',
      destinationTitle: 'Italy',
      price: 3000.0,
      description: 'Tiled floor 56rt7uihufhehr6t78ktth5e 7llr5erj7t ',
    ),
    MoreProductViewModel(
      location: 'Mutungo',
      contact: 4957953590,
      id: 5,
      img:
          'https://i.pinimg.com/736x/2f/8a/5f/2f8a5f516b17fd49400ea5fba4d15c6f.jpg',
      destinationTitle: 'Germany',
      price: 2000.0,
      description:
          'Four bedrooms rhhmugdftny77tddrtn yki7h5h67nnffgugyjtdh sr6f',
    ),
    MoreProductViewModel(
      location: 'Enttebe',
      contact: 9743680946796,
      id: 6,
      img:
          'https://i.pinimg.com/736x/f5/b1/3c/f5b13cb784af884b59e506a8b3afe536.jpg',
      destinationTitle: 'Colombia',
      price: 3500.0,
      description: 'Self contained and fumgugytfg,hilhiu yik7kft',
    ),
  ];
});
