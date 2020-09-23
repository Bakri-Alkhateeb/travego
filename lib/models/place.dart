import 'package:flutter/foundation.dart';

class Place with ChangeNotifier {
  final id;
  final name;
  final rate;
  final latitude;
  final longitude;
  final image;
  final description;
  final places;
  final price;
  final category;

  Place({
    @required this.id,
    @required this.name,
    @required this.rate,
    @required this.latitude,
    @required this.longitude,
    @required this.image,
    @required this.description,
    @required this.places,
    @required this.price,
    @required this.category,
  });
}
