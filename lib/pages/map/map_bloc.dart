import 'dart:io';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'map_event.dart';
import 'map_state.dart';
import 'package:flutter/material.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final Location location = Location();
  StreamSubscription<LocationData>? locationSubscription;

  final double distanceThreshold = 5.0;

  MapBloc() : super(MapState()) {
    on<MapStarted>(onMapStarted);
    on<MapLocationUpdated>(onMapLocationUpdated);
    on<ToggleRecording>(onToggleRecording);
    on<AddCustomMarker>(onAddMarker);
    on<StopAndSave>(onStopAndSave);
  }

  Future<void> onMapStarted(MapStarted event, Emitter<MapState> emit) async {
    bool hasPermission = await ensureLocationPermission();
    if (!hasPermission) return;

    locationSubscription?.cancel();
    locationSubscription = location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        add(
          MapLocationUpdated(
            LatLng(locationData.latitude!, locationData.longitude!),
          ),
        );
      }
    });
  }

  void onMapLocationUpdated(MapLocationUpdated event, Emitter<MapState> emit) {
    List<LatLng> newPath = List.from(state.recordedPath);
    Map<PolylineId, Polyline> newPolylines = Map.from(state.polylines);

    if (state.isRecording) {
      if (newPath.isEmpty) {
        newPath.add(event.location);
      } else {
        double distance = Geolocator.distanceBetween(
          newPath.last.latitude,
          newPath.last.longitude,
          event.location.latitude,
          event.location.longitude,
        );

        if (distance > distanceThreshold) {
          newPath.add(event.location);

          // Update the Polyline path on map
          newPolylines[const PolylineId("recording_path")] = Polyline(
            polylineId: const PolylineId("recording_path"),
            color: Colors.red,
            width: 5,
            points: newPath,
          );
        }
      }
    }

    emit(
      state.copyWith(
        currentP: event.location,
        recordedPath: newPath,
        polylines: newPolylines,
        isLoading: false,
      ),
    );
  }

  void onToggleRecording(ToggleRecording event, Emitter<MapState> emit) {
    emit(state.copyWith(isRecording: !state.isRecording));
  }

  void onAddMarker(AddCustomMarker event, Emitter<MapState> emit) {
    if (state.currentP == null) return;

    final newMarker = Marker(
      markerId: MarkerId("custom_${DateTime.now().millisecondsSinceEpoch}"),
      position: state.currentP!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: "Manual Marker"),
    );

    final updatedMarkers = Set<Marker>.from(state.userMarkers)..add(newMarker);
    emit(state.copyWith(userMarkers: updatedMarkers));
  }

  Future<void> onStopAndSave(StopAndSave event, Emitter<MapState> emit) async {
    emit(state.copyWith(isRecording: false));

    if (event.imageBytes != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            "${directory.path}/map_capture_${DateTime.now().millisecondsSinceEpoch}.png";
        final file = File(filePath);
        await file.writeAsBytes(event.imageBytes!);
        debugPrint("Screenshot saved to: $filePath");
      } catch (e) {
        debugPrint("Error saving screenshot: $e");
      }
    }
  }

  Future<bool> ensureLocationPermission() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) return false;
    }
    return true;
  }

  @override
  Future<void> close() {
    locationSubscription?.cancel();
    return super.close();
  }
}
