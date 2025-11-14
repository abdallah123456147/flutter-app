import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddIngredientsScreen extends StatefulWidget {
  final String recetteId;

  const AddIngredientsScreen({Key? key, required this.recetteId})
    : super(key: key);

  @override
  _AddIngredientsScreenState createState() => _AddIngredientsScreenState();
}

class _AddIngredientsScreenState extends State<AddIngredientsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _allIngredients = [];
  List<Map<String, dynamic>> _selectedIngredients = [];
  final Map<String, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchAllIngredients();
  }

  Future<void> _fetchAllIngredients() async {
    final response = await supabase.from('ingredient').select();
    setState(() {
      _allIngredients = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  void dispose() {
    _quantityControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Ingredients')),
      body: Column(
        children: [
          // Search bar could be added here
          Expanded(
            child: ListView.builder(
              itemCount: _allIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = _allIngredients[index];
                final isSelected = _selectedIngredients.any(
                  (item) => item['id'] == ingredient['id'],
                );

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedIngredients.add(ingredient);
                        _quantityControllers[ingredient['id']] =
                            TextEditingController();
                      } else {
                        _selectedIngredients.removeWhere(
                          (item) => item['id'] == ingredient['id'],
                        );
                        _quantityControllers[ingredient['id']]?.dispose();
                        _quantityControllers.remove(ingredient['id']);
                      }
                    });
                  },
                  title: Text(ingredient['nameIngredient']),
                  secondary:
                      ingredient['imageIngredient'] != null
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              ingredient['imageIngredient'],
                            ),
                          )
                          : const CircleAvatar(child: Icon(Icons.fastfood)),
                  subtitle:
                      isSelected
                          ? TextField(
                            controller: _quantityControllers[ingredient['id']],
                            decoration: const InputDecoration(
                              hintText: 'Quantity (e.g., 2 cups)',
                              border: UnderlineInputBorder(),
                            ),
                          )
                          : null,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveIngredients,
              child: const Text('Save Ingredients'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveIngredients() async {
    try {
      final List<Map<String, dynamic>> insertData = [];

      for (final ingredient in _selectedIngredients) {
        insertData.add({
          'recette_id': widget.recetteId,
          'ingredient_id': ingredient['id'],
          'quantity': _quantityControllers[ingredient['id']]?.text,
        });
      }

      await supabase.from('recette_ingredient').insert(insertData);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving ingredients: $e')));
    }
  }
}
