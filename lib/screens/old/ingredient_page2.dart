import 'package:bennasafi/services/ingredients_database.dart';
import 'package:flutter/material.dart';

class IngredientPage extends StatefulWidget {
  const IngredientPage({super.key});

  @override
  State<IngredientPage> createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  final ingredientDatabase = IngredientDatabase();
  final ingredientController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: ingredientDatabase.stream, // fixed: use instance's stream
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ingredients = snapshot.data!;

          if (ingredients.isEmpty) {
            return const Center(child: Text('No ingredients found'));
          }

          return ListView.builder(
            // fixed: changed curly braces to parentheses
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              return ListTile(
                subtitle: Text(ingredient.type),
                title: Text(ingredient.name),

                leading:
                    (ingredient.image) != null
                        ? CircleAvatar(
                          backgroundImage: NetworkImage(ingredient.image!),
                          radius: 24,
                        )
                        : const CircleAvatar(
                          child: Icon(Icons.fastfood),
                          radius: 24,
                        ),
              );
            },
          );
        },
      ),
    );
  }
}
