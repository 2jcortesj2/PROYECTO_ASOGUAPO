import 'package:latlong2/latlong.dart';

class CounterModel {
  final String id;
  final String name;
  final LatLng location;
  final String veredaId;
  String? lastReading;
  DateTime? lastReadingDate;

  CounterModel({
    required this.id,
    required this.name,
    required this.location,
    required this.veredaId,
    this.lastReading,
    this.lastReadingDate,
  });
}
