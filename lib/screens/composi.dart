import 'package:bennasafi/screens/firstpage.dart';
import 'package:bennasafi/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:bennasafi/services/ingredients_database.dart';
import 'package:bennasafi/models/ingredients.dart';
import 'package:bennasafi/models/recettes.dart';
import 'package:bennasafi/services/recette_ingredient_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennasafi/screens/recette_details.dart';
import 'package:shimmer/shimmer.dart';
import 'package:bennasafi/services/auth_service.dart';
import 'package:bennasafi/screens/login_page.dart';
import 'package:provider/provider.dart';
import 'package:bennasafi/screens/favoris_page.dart';
import 'package:bennasafi/screens/profil.dart';

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
  final Map<String, ScrollController> _scrollControllers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupIngredientsStream();
  }

  @override
  void dispose() {
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setupIngredientsStream() {
    _ingredientDatabase.stream.listen((ingredients) {
      if (mounted) {
        setState(() {
          _ingredients = ingredients;
          _selectedIngredients = {
            for (var i = 0; i < ingredients.length; i++) i: false,
          };
          _isLoading = false;
        });
      }
    });
  }

  void _scrollLeft(String type) {
    final controller = _scrollControllers[type];
    if (controller != null) {
      controller.animateTo(
        controller.offset - 150,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollRight(String type) {
    final controller = _scrollControllers[type];
    if (controller != null) {
      controller.animateTo(
        controller.offset + 150,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _findMatchingRecipes() async {
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

    final List<List<Recettes>> allMatchingRecettes = [];
    for (final ingredientId in selectedIngredientIds) {
      final recettes = await _recetteRepository.getRecettesForIngredient(
        ingredientId,
      );
      allMatchingRecettes.add(recettes);
    }

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
                  return const ShimmerRecipesListScreen();
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

    final firstRecipes = await _recetteRepository.getRecettesForIngredient(
      ingredientIds[0],
    );

    // Debug: Print what we're getting
    print('First recipes count: ${firstRecipes.length}');
    for (var recipe in firstRecipes) {
      print(
        'Recipe: id=${recipe.id}, name=${recipe.name}, image="${recipe.image}"',
      );
    }

    if (firstRecipes.isEmpty) return [];

    if (ingredientIds.length == 1) return firstRecipes;

    Set<Recettes> matchingRecipes = firstRecipes.toSet();

    for (int i = 1; i < ingredientIds.length; i++) {
      final nextRecipes = await _recetteRepository.getRecettesForIngredient(
        ingredientIds[i],
      );

      // Debug for subsequent recipes
      print(
        'Next recipes for ingredient ${ingredientIds[i]}: ${nextRecipes.length}',
      );
      for (var recipe in nextRecipes) {
        print(
          'Recipe: id=${recipe.id}, name=${recipe.name}, image="${recipe.image}"',
        );
      }

      matchingRecipes = matchingRecipes.intersection(nextRecipes.toSet());

      if (matchingRecipes.isEmpty) {
        return [];
      }
    }

    final result = matchingRecipes.toList();
    print('Final matching recipes: ${result.length}');
    for (var recipe in result) {
      print(
        'Final Recipe: id=${recipe.id}, name=${recipe.name}, image="${recipe.image}"',
      );
    }

    return result;
  }

  // *******************
  // *******************
  List<Widget> _buildTypeSpecificScrollContainers() {
    if (_isLoading) {
      return _buildShimmerScrollContainers();
    }

    if (_ingredients.isEmpty) {
      return [const CircularProgressIndicator()];
    }

    final Map<String, List<Ingredients>> ingredientsByType = {};

    for (int i = 0; i < _ingredients.length; i++) {
      final ingredient = _ingredients[i];
      final type = ingredient.type;

      if (!ingredientsByType.containsKey(type)) {
        ingredientsByType[type] = [];
      }

      ingredientsByType[type]!.add(ingredient);
    }

    return ingredientsByType.entries.map((entry) {
      final type = entry.key;
      final ingredients = entry.value;

      if (!_scrollControllers.containsKey(type)) {
        _scrollControllers[type] = ScrollController();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 8),
            // title type
            // child: Text(
            //   type,
            //   style: const TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black87,
            //   ),
            // ),
          ),
          Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 0.6),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListView.builder(
                    controller: _scrollControllers[type],
                    scrollDirection: Axis.horizontal,
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      final globalIndex = _ingredients.indexWhere(
                        (ing) => ing.id == ingredient.id,
                      );

                      return Container(
                        width: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ingredient.image.isNotEmpty
                                    ? Image.network(
                                      ingredient.image,
                                      width: 50, // adjust size as needed
                                      height: 50, // adjust size as needed
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(Icons.fastfood, size: 50),
                                const SizedBox(height: 2),
                                // Text(
                                //   ingredient.name,
                                //   style: const TextStyle(fontSize: 12),
                                //   overflow: TextOverflow.ellipsis,
                                // ),
                              ],
                            ),
                            Positioned(
                              right: 1,
                              bottom: -2,
                              child: Transform.scale(
                                scale: 0.7,
                                child: Checkbox(
                                  value:
                                      _selectedIngredients[globalIndex] ??
                                      false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _selectedIngredients[globalIndex] =
                                          value!;
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
                // Left scroll button
                Positioned(
                  left: -8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.green,
                        size: 15,
                      ),
                      iconSize: 20,
                      padding: const EdgeInsets.all(4),
                      onPressed: () => _scrollLeft(type),
                    ),
                  ),
                ),
                // Right scroll button
                Positioned(
                  right: -10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.green,
                        size: 15,
                      ),
                      iconSize: 20,
                      padding: const EdgeInsets.all(4),
                      onPressed: () => _scrollRight(type),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> _buildShimmerScrollContainers() {
    return List.generate(4, (index) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(left: 15, bottom: 8)),
          Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 0.6),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Left scroll button shimmer
                Positioned(
                  left: -8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                // Right scroll button shimmer
                Positioned(
                  right: -10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // ---------------------- ACCOUNT BUTTON ----------------------
  Widget _buildAccountButton() {
    final authService = Provider.of<AuthService>(context);
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: InkWell(
        onTap: () {
          if (authService.isLoggedIn) {
            _showUserMenu();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/compt.png', width: 30, height: 30),
            Text(
              authService.isLoggedIn ? 'Mon Compte' : 'Se connecter',
              style: const TextStyle(
                fontFamily: 'Cocon',
                color: Color(0xFF007A33),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Mon Profil'),
                onTap: () {
                  Navigator.pop(context);
                  final authService = Provider.of<AuthService>(
                    context,
                    listen: false,
                  );
                  if (authService.currentUser != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProfilePage(user: authService.currentUser!),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Mes Favoris'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FavorisPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Déconnexion'),
                onTap: () {
                  Navigator.pop(context);
                  Provider.of<AuthService>(context, listen: false).logout();
                },
              ),
            ],
          ),
    );
  }

  Widget _buildShimmerHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Container(width: 200, height: 40, color: Colors.white),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 33),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFFFB400),
              ), // header background
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white, // white text for contrast
                  fontFamily: 'Cocon',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Color(0xFFFFB400), // yellow-gold icon
              ),
              title: Text(
                'Accueil',
                style: TextStyle(
                  fontFamily: 'Cocon',
                  color: Color(0xFF007A33), // dark text for readability
                ),
              ),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Firstpage()),
                  ),
            ),
            // ListTile(
            //   leading: Icon(Icons.restaurant_menu, color: Color(0xFFFFB400)),
            //   title: Text(
            //     'Recette du jour',
            //     style: TextStyle(fontFamily: 'Cocon', color: Color(0xFF007A33)),
            //   ),
            //   onTap:
            //       () => Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (_) => Firstpage()),
            //       ),
            // ),
            ListTile(
              leading: Icon(Icons.kitchen, color: Color(0xFFFFB400)),
              title: Text(
                'Composi Dbartek',
                style: TextStyle(fontFamily: 'Cocon', color: Color(0xFF007A33)),
              ),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Composi()),
                  ),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(
          builder:
              (context) => InkWell(
                onTap: () {
                  Scaffold.of(context).openDrawer(); // ✅ Opens the menu
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset('images/menu.png', width: 20, height: 20),
                ),
              ),
        ),
        actions: [
          _buildAccountButton(), // Keep your existing account button
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_isLoading)
                    _buildShimmerHeader()
                  else
                    _buildActualHeader(),
                  ..._buildTypeSpecificScrollContainers(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child:
                _isLoading
                    ? Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _matchingRecettesCount > 0
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : Colors.grey,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed:
                          _matchingRecettesCount > 0
                              ? () => _navigateToRecipesList(context)
                              : null,
                      child: Text(
                        '$_matchingRecettesCount Résultat${_matchingRecettesCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Cocon',
                          color: Color(0xFFFFB400),
                        ),
                      ),
                    ),
          ),
        ],
      ),
      // Footer navigation bar
      bottomNavigationBar: _buildFooter(),
    );
  }

  // ---------------------- FOOTER ----------------------
  Widget _buildFooter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Firstpage()),
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('images/logo2.webp', width: 50),
                const SizedBox(height: 2),
                const Text(
                  'Acceuil',
                  style: TextStyle(
                    fontFamily: 'Cocon',
                    fontSize: 8,
                    color: Color(0xFF15B03B),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('images/search.png', width: 18, height: 18),
                const SizedBox(height: 6),
                const Text(
                  'Recherche',
                  style: TextStyle(
                    fontSize: 8,
                    color: Color(0xFF15B03B),
                    fontFamily: 'Cocon',
                  ),
                ),
              ],
            ),
          ),
          _buildFavoritesFooterButton(),
        ],
      ),
    );
  }

  Widget _buildFavoritesFooterButton() {
    return InkWell(
      onTap: () {
        final authService = Provider.of<AuthService>(context, listen: false);
        if (authService.isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FavorisPage()),
          );
        } else {
          _showLoginDialog();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('images/favoris.png', width: 20, height: 20),
          const SizedBox(height: 4),
          const Text(
            'Favoris',
            style: TextStyle(
              fontFamily: 'Cocon',
              fontSize: 8,
              color: Color(0xFF15B03B),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Connexion requise'),
            content: const Text(
              'Veuillez vous connecter pour effectuer cette action.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
                child: const Text('Se connecter'),
              ),
            ],
          ),
    );
  }

  Widget _buildActualHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Image.asset(
            'images/composi.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Composi ',
                      style: TextStyle(
                        fontFamily: 'Cocon',
                        color: Color(0xFF7FB636),
                        fontSize: 34,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                    TextSpan(
                      text: 'Dbartek',
                      style: TextStyle(
                        fontFamily: 'Cocon',
                        color: Color(0xFF7FB636),
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              const Text(
                'découvrez les recettes possibles à partir de vos ingrédients disponibles',
                style: TextStyle(
                  color: Color(0xFF7FB636),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 33),
            ],
          ),
        ),
      ],
    );
  }
}

class ShimmerRecipesListScreen extends StatelessWidget {
  const ShimmerRecipesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Liste des recettes'),
      //   backgroundColor: Colors.green,
      // ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: GridView.builder(
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 5.0,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 10,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 6.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 100,
                            height: 10,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class RecipesListScreen extends StatelessWidget {
  final List<Recettes> recettes;

  const RecipesListScreen({super.key, required this.recettes});

  @override
  Widget build(BuildContext context) {
    // Debug in the UI
    print('Building RecipesListScreen with ${recettes.length} recipes');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des recettes',
          style: TextStyle(color: Colors.white, fontFamily: 'Cocon'),
        ),
        backgroundColor: Colors.green,
      ),
      body:
          recettes.isEmpty
              ? const Center(
                child: Text(
                  'Aucune recette trouvée',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
                child: GridView.builder(
                  itemCount: recettes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 5.0,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final recette = recettes[index];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    RecetteDetailsPage(recette: recette),
                          ),
                        );
                      },

                      // child: ClipRRect(
                      // borderRadius: BorderRadius.circular(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ IMAGE
                          Expanded(
                            flex: 10,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.grey[200],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                recette.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'images/logo2.webp',
                                    fit: BoxFit.contain,
                                  );
                                },
                              ),
                            ),
                          ),

                          // ✅ SPACING + NAME
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 6.0,
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  recette.name.isNotEmpty
                                      ? recette.name
                                      : 'Nom non disponible',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF007A33),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // ),
                    );
                  },
                ),
              ),
    );
  }
}
