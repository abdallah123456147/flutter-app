import 'package:bennasafi/services/recettes_database.dart';
import 'package:flutter/material.dart';

class RecettePage extends StatefulWidget {
  const RecettePage({super.key});

  @override
  State<RecettePage> createState() => _RecettePageState();
}

class _RecettePageState extends State<RecettePage> {
  final recetteDatabase = RecetteDatabase();
  final recetteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: recetteDatabase.stream, // fixed: use instance's stream
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final recettes = snapshot.data!;

          if (recettes.isEmpty) {
            return const Center(child: Text('No recette found'));
          }

          return ListView.builder(
            // fixed: changed curly braces to parentheses
            itemCount: recettes.length,
            itemBuilder: (context, index) {
              final recette = recettes[index];
              return ListTile(
                title: Text(recette.name),
                // subtitle: Text(ingredient.quantity),
              );
            },
          );
        },
      ),
    );
  }
}
