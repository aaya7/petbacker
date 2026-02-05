import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState {
  final LatLng? currentP;
  final Map<PolylineId, Polyline> polylines;
  final Set<Marker> userMarkers;
  final List<LatLng> recordedPath;
  final bool isRecording;
  final bool isLoading;

  MapState({
    this.currentP,
    this.polylines = const {},
    this.userMarkers = const {},
    this.recordedPath = const [],
    this.isRecording = false,
    this.isLoading = true,
  });

  MapState copyWith({
    LatLng? currentP,
    Map<PolylineId, Polyline>? polylines,
    Set<Marker>? userMarkers,
    List<LatLng>? recordedPath,
    bool? isRecording,
    bool? isLoading,
  }) {
    return MapState(
      currentP: currentP ?? this.currentP,
      polylines: polylines ?? this.polylines,
      userMarkers: userMarkers ?? this.userMarkers,
      recordedPath: recordedPath ?? this.recordedPath,
      isRecording: isRecording ?? this.isRecording,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
