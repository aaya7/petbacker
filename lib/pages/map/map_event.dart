import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';

abstract class MapEvent {}

class MapStarted extends MapEvent {}

class MapLocationUpdated extends MapEvent {
  final LatLng location;
  MapLocationUpdated(this.location);
}

class ToggleRecording extends MapEvent {}

class AddCustomMarker extends MapEvent {}

class StopAndSave extends MapEvent {
  final Uint8List? imageBytes;
  StopAndSave(this.imageBytes);
}
