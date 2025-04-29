import 'package:brickapp/models/client_requests_model.dart';
import 'package:brickapp/models/notification_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

final notificationProvider = StateProvider((ref) {
  return [
    RequestModel(
      clientName: "Juliet Vega",
      image:
          "https://c0.wallpaperflare.com/preview/902/404/8/blurred-background-close-up-colors-dark.jpg",
      itemName: "Benga Appartments",
      itemID: 1,
      time: DateFormat.yMMMMEEEEd().format(DateTime.now()),
      amount: 200000,
      phone: 0740856741,
    ),
    RequestModel(
      clientName: "Ramon Wilson",
      image:
          "https://miro.medium.com/v2/resize:fit:1079/1*G6bWZ2AzAAPVsl86NU-2bQ.png",
      itemName: "Brick Appartments",
      itemID: 3,
      time: DateFormat.yMMMMEEEEd().format(DateTime.now()),
      amount: 200000,
      phone: 0740856741,
    ),
    RequestModel(
      clientName: "Juliet Vega",
      image:
          "https://c0.wallpaperflare.com/preview/902/404/8/blurred-background-close-up-colors-dark.jpg",
      itemName: "Benga Appartments",
      itemID: 10,
      time: DateFormat.yMMMMEEEEd().format(DateTime.now()),
      amount: 200000,
      phone: 0740856741,
    ),
    RequestModel(
      clientName: "Ramon Wilson",
      image:
          "https://miro.medium.com/v2/resize:fit:1079/1*G6bWZ2AzAAPVsl86NU-2bQ.png",
      itemName: "Brick Appartments",
      itemID: 5,
      time: DateFormat.yMMMMEEEEd().format(DateTime.now()),
      amount: 200000,
      phone: 0740856741,
    ),
    RequestModel(
      clientName: "Juliet Vega",
      image:
          "https://c0.wallpaperflare.com/preview/902/404/8/blurred-background-close-up-colors-dark.jpg",
      itemName: "Benga Appartments",
      itemID: 11,
      time: DateFormat.yMMMMEEEEd().format(DateTime.now()),
      amount: 200000,
      phone: 0740856741,
    ),
    RequestModel(
      clientName: "Ramon Wilson",
      image:
          "https://miro.medium.com/v2/resize:fit:1079/1*G6bWZ2AzAAPVsl86NU-2bQ.png",
      itemName: "Brick Appartments",
      itemID: 6,
      time: DateFormat.yMMMMEEEEd().format(DateTime.now()),
      amount: 200000,
      phone: 0740856741,
    ),
  ];
});

final clietntReqestProvider = Provider((ref) {
  return [
    ClientHistoryModel(
      clientName: "Ramon Hardluck",
      image:
          "https://miro.medium.com/v2/resize:fit:1079/1*G6bWZ2AzAAPVsl86NU-2bQ.png",
      itemName: "Brick Appartments",
      itemID: 6,
      time: DateFormat.yMMMMEEEEd().format(DateTime.now()),
      amount: 200000,
    ),
    ClientHistoryModel(
      clientName: "Ramon Hardluck",
      image:
          "https://miro.medium.com/v2/resize:fit:1079/1*G6bWZ2AzAAPVsl86NU-2bQ.png",
      itemName: "Brick Appartments",
      itemID: 6,
      time: DateFormat.MMMMEEEEd().format(DateTime.now()),
      amount: 200000,
    ),
    ClientHistoryModel(
      clientName: "Ramon Hardluck",
      image:
          "https://miro.medium.com/v2/resize:fit:1079/1*G6bWZ2AzAAPVsl86NU-2bQ.png",
      itemName: "Brick Appartments",
      itemID: 6,
      time: DateFormat.MMMMEEEEd().format(DateTime.now()),
      amount: 200000,
    ),
  ];
});
