import 'package:flutter/material.dart';
import 'package:bennasafi/services/ingredients_database.dart';
import 'package:bennasafi/models/ingredients.dart';
import 'package:bennasafi/models/recettes.dart';
import 'package:bennasafi/services/recette_ingredient_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Composi extends StatefulWidget {
  const Composi({super.key});

  @override
  State<Composi> createState() => _ComposiState();
}

class _ComposiState extends State<Composi> {
  final IngredientDatabase _ingredientDatabase = IngredientDatabase();
  final RecetteRepository _recetteRepository = RecetteRepository(
    Supabase.instance.client,
  );
  List<Ingredients> _ingredients = [];
  Map<int, bool> _selectedIngredients = {};
  int _matchingRecettesCount = 0;

  @override
  void initState() {
    super.initState();
    _setupIngredientsStream();
  }

  void _setupIngredientsStream() {
    _ingredientDatabase.stream.listen((ingredients) {
      if (mounted) {
        setState(() {
          _ingredients = ingredients;
          _selectedIngredients = {
            for (var i = 0; i < ingredients.length; i++) i: false,
          };
        });
      }
    });
  }

  Future<void> _findMatchingRecipes() async {
    // Get selected ingredient IDs
    final selectedIngredientIds =
        _selectedIngredients.entries
            .where((entry) => entry.value)
            .map((entry) => _ingredients[entry.key].id)
            .toList();

    if (selectedIngredientIds.isEmpty) {
      setState(() {
        _matchingRecettesCount = 0;
      });
      return;
    }

    // For each selected ingredient, find all recipes that use it
    final List<List<Recettes>> allMatchingRecettes = [];
    for (final ingredientId in selectedIngredientIds) {
      final recettes = await _recetteRepository.getRecettesForIngredient(
        ingredientId,
      );
      allMatchingRecettes.add(recettes);
    }

    // Find intersection - recipes that appear in all lists (contain all selected ingredients)
    if (allMatchingRecettes.isNotEmpty) {
      Set<Recettes> intersection = allMatchingRecettes.first.toSet();
      for (int i = 1; i < allMatchingRecettes.length; i++) {
        intersection = intersection.intersection(
          allMatchingRecettes[i].toSet(),
        );
      }
      setState(() {
        _matchingRecettesCount = intersection.length;
      });
    } else {
      setState(() {
        _matchingRecettesCount = 0;
      });
    }
  }

  void _navigateToRecipesList(BuildContext context) {
    if (_matchingRecettesCount == 0) return;

    // Get selected ingredient IDs
    final selectedIngredientIds =
        _selectedIngredients.entries
            .where((entry) => entry.value)
            .map((entry) => _ingredients[entry.key].id)
            .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FutureBuilder<List<Recettes>>(
              future: _getMatchingRecettes(selectedIngredientIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Error loading recipes'));
                }
                return RecipesListScreen(recettes: snapshot.data!);
              },
            ),
      ),
    );
  }

  Future<List<Recettes>> _getMatchingRecettes(List<int> ingredientIds) async {
    if (ingredientIds.isEmpty) return [];

    // Get all recipes for the first ingredient
    final firstRecipes = await _recetteRepository.getRecettesForIngredient(
      ingredientIds[0],
    );
    if (firstRecipes.isEmpty) return [];

    // If only one ingredient selected, return all its recipes
    if (ingredientIds.length == 1) return firstRecipes;

    // For multiple ingredients, find common recipes
    Set<Recettes> matchingRecipes = firstRecipes.toSet();

    for (int i = 1; i < ingredientIds.length; i++) {
      final nextRecipes = await _recetteRepository.getRecettesForIngredient(
        ingredientIds[i],
      );
      matchingRecipes = matchingRecipes.intersection(nextRecipes.toSet());

      if (matchingRecipes.isEmpty) {
        return []; // No common recipes found
      }
    }

    return matchingRecipes.toList();
  }

  List<Widget> _buildTypeSpecificScrollContainers() {
    if (_ingredients.isEmpty) {
      return [const CircularProgressIndicator()];
    }

    final Map<String, List<Ingredients>> ingredientsByType = {};
    for (final ingredient in _ingredients) {
      final type = ingredient.type ?? 'Other';
      if (!ingredientsByType.containsKey(type)) {
        ingredientsByType[type] = [];
      }
      ingredientsByType[type]!.add(ingredient);
    }

    return ingredientsByType.entries.map((entry) {
      final ingredients = entry.value;

      return Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 0.6),
          borderRadius: BorderRadius.circular(25),
        ),
        margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  final globalIndex = _ingredients.indexOf(ingredient);
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (ingredient.image != null)
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(
                                  ingredient.image!,
                                ),
                              )
                            else
                              const CircleAvatar(
                                radius: 25,
                                child: Icon(Icons.fastfood),
                              ),
                          ],
                        ),
                        Positioned(
                          right: 1,
                          bottom: 5,
                          child: Transform.scale(
                            scale: 0.7,
                            child: Checkbox(
                              value: _selectedIngredients[globalIndex] ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedIngredients[globalIndex] = value!;
                                });
                                _findMatchingRecipes();
                              },
                              activeColor: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Color.fromARGB(255, 21, 176, 59),
                  ),
                  onPressed: () {},
                ),
                Expanded(
                  child: Center(
                    child: Image.asset('images/logo2.webp', height: 50),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Image.asset(
                      'images/cube.PNG',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Column(
                      children: [
                        Text(
                          'Composi Dbartek',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'découvrez les recettes possibles à partir de vos ingrédients disponibles',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                  ..._buildTypeSpecificScrollContainers(),
                ],
              ),
            ),
          ),

          // Fixed bottom button
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _matchingRecettesCount > 0 ? Colors.green : Colors.grey,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed:
                  _matchingRecettesCount > 0
                      ? () => _navigateToRecipesList(context)
                      : null,
              child: Text(
                '(${_matchingRecettesCount} resultat)',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipesListScreen extends StatelessWidget {
  final List<Recettes> recettes;

  const RecipesListScreen({super.key, required this.recettes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recettes correspondantes'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: recettes.length,
        itemBuilder: (context, index) {
          final recette = recettes[index];
          return ListTile(
            leading:
                recette.image != null
                    ? CircleAvatar(
                      backgroundImage: NetworkImage(recette.image!),
                    )
                    : const CircleAvatar(child: Icon(Icons.restaurant_menu)),
            title: Text(recette.name),
            onTap: () {
              // Navigate to recipe detail screen
            },
          );
        },
      ),
    );
  }
}
