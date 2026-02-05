import 'package:flutter/material.dart';
import 'package:petbacker/pages/map/map_bloc.dart';
import 'package:petbacker/pages/map/map_view.dart';
import 'package:petbacker/pages/map/map_event.dart';
import 'package:petbacker/pages/pet/pet_view.dart';
import 'package:petbacker/pages/pet/pet_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petbacker/pages/pet/pet_bloc.dart';
import 'package:petbacker/repositories/pet_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Tracker')),

      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlueAccent),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Map Tracking'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => MapBloc()..add(MapStarted()),
                      child: const MapView(),
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Pet Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          PetsBloc(PetRepository())..add(FetchPets()),
                      child: const PetView(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: const Center(
        child: Text(
          'Welcome to Pet Tracker 🐶🐱',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
