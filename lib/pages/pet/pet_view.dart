import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petbacker/pages/pet/pet_bloc.dart';
import 'package:petbacker/pages/pet/pet_state.dart';
import 'package:petbacker/models/pet_model.dart';

class PetView extends StatelessWidget {
  const PetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Pet Details')),
      body: BlocBuilder<PetsBloc, PetsState>(
        builder: (context, state) {
          if (state is PetsLoading) return const Center(child: CircularProgressIndicator());
          if (state is PetsError) return Center(child: Text(state.message));
          if (state is PetsLoaded) {
            return ListView.builder(
              itemCount: state.pets.length,
              itemBuilder: (context, index) => PetCard(pet: state.pets[index]),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class PetCard extends StatelessWidget {
  final PetModel pet;
  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pet.medias.isNotEmpty)
            SizedBox(
              height: 250,
              child: Image.network(pet.medias.first.mediaFilename, fit: BoxFit.cover, width: double.infinity),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pet.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                
                if (pet.isJsonDescription)
                  ...pet.questions.where((q) => q.hasValue || q.type == "label").map((q) {
                    if (q.type == "label") {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(q.listingDisplay ?? q.content, 
                          style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                      );
                    }
                    return Text(q.reply!, style: const TextStyle(fontSize: 16));
                  }).toList()
                else
                  Text(pet.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}