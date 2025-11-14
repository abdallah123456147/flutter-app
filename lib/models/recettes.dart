import 'package:bennasafi/models/ingredients.dart';
import 'package:bennasafi/models/niveau.dart';
import 'package:bennasafi/models/pays.dart';
import 'package:bennasafi/models/recette_ingredient.dart';

class Recettes {
  final int id;
  final String name;
  final String description;
  final String type;
  final String soustype;
  final String preparation;
  final String cuisson;
  final int nbre;
  final String image;
  final List<Ingredients>? ingredients;
  final List<Pays>? pays;
  final List<Niveau>? niveau;
  final List<RecetteIngredient>? recetteIngredients;

  Recettes({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.soustype,
    required this.preparation,
    required this.cuisson,
    required this.nbre,
    required this.image,
    this.ingredients,
    this.pays,
    this.niveau,
    this.recetteIngredients,
  });

  factory Recettes.fromMap(Map<String, dynamic> map) {
    print('Parsing recipe: ${map['name']}');

    // Parse recette_ingredients with ingredients
    List<Ingredients>? ingredients = [];
    List<RecetteIngredient>? recetteIngredients = [];

    if (map['recette_ingredients'] != null &&
        map['recette_ingredients'] is List) {
      final recetteIngList = (map['recette_ingredients'] as List);
      print('Found ${recetteIngList.length} recipe ingredients');

      for (var item in recetteIngList) {
        try {
          // Parse the ingredient
          if (item['ingredients'] != null) {
            final ingredient = Ingredients.fromMap(item['ingredients']);
            ingredients.add(ingredient);

            // Parse the recipe-ingredient relationship
            final recetteIng = RecetteIngredient.fromMap({
              'id': item['id'],
              'recette_id': map['id'],
              'ingredient_id': item['ingredients']['id'],
              'quantity': item['quantity'] ?? '',
              'unit': item['unit'] ?? '',
            });
            recetteIngredients.add(recetteIng);
          }
        } catch (e) {
          print('Error parsing ingredient: $e');
        }
      }
    }

    // Parse niveau (supports both List and single Map from Supabase)
    List<Niveau>? niveau = [];
    if (map['niveau'] != null) {
      try {
        if (map['niveau'] is List) {
          final niveauList = (map['niveau'] as List);
          print('Found ${niveauList.length} niveau items');
          for (var item in niveauList) {
            niveau.add(Niveau.fromMap(item as Map<String, dynamic>));
          }
        } else if (map['niveau'] is Map) {
          print('Found single niveau object');
          final single = Map<String, dynamic>.from(map['niveau'] as Map);
          niveau.add(Niveau.fromMap(single));
        }
      } catch (e) {
        print('Error parsing niveau: $e');
      }
    }

    // Parse pays
    List<Pays>? pays = [];
    if (map['pays'] != null && map['pays'] is List) {
      final paysList = (map['pays'] as List);
      print('Found ${paysList.length} pays items');

      for (var item in paysList) {
        try {
          pays.add(Pays.fromMap(item));
        } catch (e) {
          print('Error parsing pays: $e');
        }
      }
    }

    return Recettes(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? '',
      soustype: map['soustype'] as String? ?? '',
      preparation: map['preparation'] as String? ?? '',
      cuisson: map['cuisson'] as String? ?? '',
      nbre: map['nbre'] as int? ?? 0,
      image: map['image'] as String? ?? '',
      ingredients: ingredients.isNotEmpty ? ingredients : null,
      pays: pays.isNotEmpty ? pays : null,
      niveau: niveau.isNotEmpty ? niveau : null,
      recetteIngredients:
          recetteIngredients.isNotEmpty ? recetteIngredients : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'soustype': soustype,
      'preparation': preparation,
      'cuisson': cuisson,
      'nbre': nbre,
      'image': image,
      'ingredients':
          ingredients?.map((ingredient) => ingredient.toMap()).toList(),
      'pays': pays?.map((pays) => pays.toMap()).toList(),
      'niveau': niveau?.map((niveau) => niveau.toMap()).toList(),
      'recetteIngredients':
          recetteIngredients?.map((ri) => ri.toMap()).toList(),
    };
  }

  // Helper method to get ingredient with quantity
  String getIngredientQuantity(int ingredientId) {
    if (recetteIngredients == null) return '';

    final recetteIngredient = recetteIngredients!.firstWhere(
      (ri) => ri.ingredientId == ingredientId,
      orElse:
          () => RecetteIngredient(
            id: 0,
            recetteId: id,
            ingredientId: ingredientId,
            quantity: '',
            unit: '',
          ),
    );

    return '${recetteIngredient.quantity} ${recetteIngredient.unit}'.trim();
  }

  // Parse a quantity string like "75", "0.5", "1/2", or "1 1/2" to double
  double? _parseQuantityToDouble(String raw) {
    if (raw.isEmpty) return null;
    final normalized = raw.trim().replaceAll(',', '.');

    // Handle mixed numbers like "1 1/2"
    if (normalized.contains(' ')) {
      final parts = normalized.split(RegExp(r"\s+"));
      double total = 0.0;
      for (final part in parts) {
        final v = _parseQuantityToDouble(part);
        if (v != null) total += v;
      }
      return total;
    }

    // Handle simple fraction like "1/2"
    if (normalized.contains('/')) {
      final fr = normalized.split('/');
      if (fr.length == 2) {
        final nume = double.tryParse(fr[0]);
        final deno = double.tryParse(fr[1]);
        if (nume != null && deno != null && deno != 0) {
          return nume / deno;
        }
      }
    }

    // Fallback to plain number
    return double.tryParse(normalized);
  }

  String _formatQuantity(double value) {
    // Use up to 2 decimals, trim trailing zeros
    String s = value.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r"\.0+$"), '');
      s = s.replaceAllMapped(RegExp(r"\.(\d*?)0+$"), (m) => '.${m.group(1)}');
      if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    }
    return s;
  }

  // Helper that returns scaled quantity with unit for current servings (nbre)
  String getScaledIngredientQuantity(int ingredientId, int currentNbre) {
    if (recetteIngredients == null) return '';

    final recetteIngredient = recetteIngredients!.firstWhere(
      (ri) => ri.ingredientId == ingredientId,
      orElse:
          () => RecetteIngredient(
            id: 0,
            recetteId: id,
            ingredientId: ingredientId,
            quantity: '',
            unit: '',
          ),
    );

    final baseQuantity = _parseQuantityToDouble(recetteIngredient.quantity);
    if (baseQuantity == null || nbre == 0) {
      return '${recetteIngredient.quantity} ${recetteIngredient.unit}'.trim();
    }

    final factor = currentNbre / nbre;
    final scaled = baseQuantity * factor;
    final display = _formatQuantity(scaled);
    return '$display ${recetteIngredient.unit}'.trim();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recettes && other.id == this.id;
  }

  @override
  int get hashCode => id.hashCode;
}
