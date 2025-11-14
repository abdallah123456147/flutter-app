import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennasafi/models/ingredients.dart';
import 'package:bennasafi/services/ingredients_database.dart';

class IngredientsPage extends StatelessWidget {
  const IngredientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ingredientDB = IngredientDatabase();

    return Scaffold(
      appBar: AppBar(title: const Text("Ingredients"), centerTitle: true),
      body: StreamBuilder<List<Ingredients>>(
        stream: ingredientDB.stream,
        builder: (context, snapshot) {
          // 🔄 Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error state
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // ✅ Empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No ingredients found."));
          }

          // ✅ Data state
          final ingredients = snapshot.data!;

          return ListView.builder(
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(ingredient.image),
                  ),
                  title: Text(
                    ingredient.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(ingredient.type),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
