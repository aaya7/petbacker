import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_bloc.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});
  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final Completer<GoogleMapController> controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Tracker')),
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state.currentP != null) moveCamera(state.currentP!);
        },
        builder: (context, state) {
          if (state.isLoading || state.currentP == null) {
            // return const Center(child: CircularProgressIndicator());
            return const Center(child: Text("Loading..."));
          }

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: (c) => controller.complete(c),
                initialCameraPosition: CameraPosition(
                  target: state.currentP!,
                  zoom: 15,
                ),
                myLocationEnabled: true,
                markers: state.userMarkers,
                polylines: Set<Polyline>.of(state.polylines.values),
              ),

              Positioned(
                right: 15,
                top: 15,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag: "recordButton",
                      onPressed: () =>
                          context.read<MapBloc>().add(ToggleRecording()),
                      backgroundColor: state.isRecording
                          ? Colors.orange
                          : Colors.green,
                      child: Icon(
                        state.isRecording ? Icons.pause : Icons.play_arrow,
                      ),
                    ),
                    const SizedBox(height: 10),

                    FloatingActionButton(
                      heroTag: "markButton",
                      onPressed: () =>
                          context.read<MapBloc>().add(AddCustomMarker()),
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.add_location_alt),
                    ),
                    const SizedBox(height: 10),

                    FloatingActionButton(
                      heroTag: "stopButton",
                      onPressed: () async {
                        final controller = await this.controller.future;
                        final bytes = await controller.takeSnapshot();
                        if (mounted) {
                          context.read<MapBloc>().add(StopAndSave(bytes));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Recording Saved & Screenshot Taken",
                              ),
                            ),
                          );
                        }
                      },
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.stop),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> moveCamera(LatLng pos) async {
    final c = await controller.future;
    c.animateCamera(CameraUpdate.newLatLng(pos));
  }
}
