import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bennasafi/services/auth_service.dart';
import 'package:bennasafi/services/recettes_database.dart';
import 'package:bennasafi/models/recettes.dart';
import 'package:bennasafi/screens/recette_details.dart'; // Import your details page
import 'package:bennasafi/services/favorites_database.dart';
import 'package:bennasafi/services/notification_service.dart';

class FavorisPage extends StatefulWidget {
  const FavorisPage({super.key});

  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  List<int> _favorisIds = [];
  late RecetteDatabase _recetteDb;
  late FavoritesDatabase _favoritesDb;
  List<Recettes> _recipes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _recetteDb = RecetteDatabase();
    _favoritesDb = FavoritesDatabase();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isLoggedIn) {
      setState(() {
        _favorisIds = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final favs = await _favoritesDb.getUserFavorites();
      _favorisIds = favs.map((f) => f.recetteId).toList();
      await _loadRecipes();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recipes = await _getFavoriteRecipes(_favorisIds, _recetteDb);
      if (mounted) {
        setState(() {
          _recipes = recipes.whereType<Recettes>().toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFromFavorites(int recipeId) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Store the removed recipe for potential undo
    final removedRecipe = _recipes.firstWhere(
      (recipe) => recipe.id == recipeId,
    );

    // Remove from UI immediately
    setState(() {
      _recipes.removeWhere((recipe) => recipe.id == recipeId);
    });

    try {
      // Remove from backend
      await authService.removeFromFavorites(recipeId);

      // Update local favorites list
      _favorisIds.remove(recipeId);

      if (mounted) {
        NotificationService.showError('Retiré des favoris');
        // Show undo option through a different approach or just confirmation
      }
    } catch (e) {
      // If backend removal fails, revert UI
      if (mounted) {
        setState(() {
          _recipes.add(removedRecipe);
          _favorisIds.add(recipeId);
        });
        NotificationService.showError('Erreur lors de la suppression');
      }
    }
  }

  void _navigateToRecipeDetails(Recettes recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                RecetteDetailsPage(recette: recipe), // Use your actual class
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        backgroundColor: const Color(0xFF007A33),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show empty state if no favorites IDs or all recipes have been removed
    if (_favorisIds.isEmpty || _recipes.isEmpty) {
      return _buildEmptyState();
    }

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState(_error!);
    }

    return _buildRecipesList();
  }

  Widget _buildRecipesList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _recipes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        return _FavoriteRecipeCard(
          recipe: recipe,
          onRemove: () => _removeFromFavorites(recipe.id),
          onTap: () => _navigateToRecipeDetails(recipe),
        );
      },
    );
  }

  // No longer needed: favorites are loaded from favoris table

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucun favori pour le moment',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007A33)),
          ),
          SizedBox(height: 16),
          Text('Chargement de vos favoris...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRecipes,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Future<List<Recettes?>> _getFavoriteRecipes(
    List<int> favorisIds,
    RecetteDatabase recetteDatabase,
  ) async {
    final List<Recettes?> recipes = [];
    for (final id in favorisIds) {
      try {
        final recipe = await recetteDatabase.fetchById(id);
        recipes.add(recipe);
      } catch (e) {
        debugPrint('Error fetching recipe $id: $e');
        recipes.add(null);
      }
    }
    return recipes;
  }
}

class _FavoriteRecipeCard extends StatelessWidget {
  final Recettes recipe;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _FavoriteRecipeCard({
    required this.recipe,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildRecipeImage(recipe.image),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildRecipeMetadata(),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: onRemove,
                tooltip: 'Retirer des favoris',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeMetadata() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (recipe.preparation.isNotEmpty)
          _buildMetadataChip(Icons.timer, '${recipe.preparation}min'),
        if (recipe.cuisson.isNotEmpty)
          _buildMetadataChip(Icons.restaurant, '${recipe.cuisson}min'),
        if (recipe.pays != null && recipe.pays!.isNotEmpty)
          _buildMetadataChip(Icons.public, recipe.pays!.first.name),
      ],
    );
  }

  Widget _buildMetadataChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.orange[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeImage(String imageUrl) {
    final hasImage = imageUrl.isNotEmpty;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: hasImage ? null : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        image:
            hasImage
                ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )
                : null,
      ),
      child:
          hasImage
              ? null
              : const Icon(Icons.restaurant_menu, color: Colors.grey, size: 32),
    );
  }
}
