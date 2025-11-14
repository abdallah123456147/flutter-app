import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_ingredients_screen.dart';

class RecetteScreen extends StatefulWidget {
  final String recetteId;

  const RecetteScreen({Key? key, required this.recetteId}) : super(key: key);

  @override
  _RecetteScreenState createState() => _RecetteScreenState();
}

class _RecetteScreenState extends State<RecetteScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<Map<String, dynamic>> _recetteData;

  @override
  void initState() {
    super.initState();
    _recetteData = _fetchRecetteData();
  }

  Future<Map<String, dynamic>> _fetchRecetteData() async {
    // Fetch recipe details
    final recetteResponse =
        await supabase
            .from('recette')
            .select()
            .eq('id', widget.recetteId)
            .single();

    // Fetch associated ingredients
    final ingredientsResponse = await supabase
        .from('recette_ingredient')
        .select('''
          ingredient:ingredient_id (id, nameIngredient, imageIngredient), 
          quantity
        ''')
        .eq('recette_id', widget.recetteId);

    return {'recette': recetteResponse, 'ingredients': ingredientsResponse};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _recetteData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final recette = snapshot.data!['recette'];
          final ingredients = snapshot.data!['ingredients'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Image
                if (recette['imageRecette'] != null)
                  Center(
                    child: Image.network(
                      recette['imageRecette'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),

                // Recipe Name
                Text(
                  recette['nameRecette'],
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),

                // Ingredients Section
                Text(
                  'Ingredients',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),

                // Ingredients List
                ...ingredients.map<Widget>((ingredient) {
                  return ListTile(
                    leading:
                        ingredient['ingredient']['imageIngredient'] != null
                            ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                ingredient['ingredient']['imageIngredient'],
                              ),
                            )
                            : const CircleAvatar(child: Icon(Icons.fastfood)),
                    title: Text(ingredient['ingredient']['nameIngredient']),
                    subtitle:
                        ingredient['quantity'] != null
                            ? Text(ingredient['quantity'])
                            : null,
                  );
                }).toList(),

                // Add Ingredient Button
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _navigateToAddIngredients(context),
                    child: const Text('Add Ingredients'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToAddIngredients(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddIngredientsScreen(recetteId: widget.recetteId),
      ),
    ).then(
      (_) => setState(() {
        _recetteData = _fetchRecetteData();
      }),
    );
  }
}
