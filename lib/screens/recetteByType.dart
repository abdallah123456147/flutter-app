import 'package:bennasafi/screens/firstpage.dart';
import 'package:bennasafi/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:bennasafi/models/recettes.dart';
import 'package:bennasafi/services/recettes_database.dart';
import 'package:bennasafi/screens/recette_details.dart';
import 'package:bennasafi/services/auth_service.dart';
import 'package:bennasafi/screens/login_page.dart';
import 'package:provider/provider.dart';
import 'package:bennasafi/screens/favoris_page.dart';
import 'package:bennasafi/screens/profil.dart';
import 'package:bennasafi/screens/composi.dart';

class RecetteByType extends StatefulWidget {
  const RecetteByType({super.key});

  @override
  State<RecetteByType> createState() => _RecetteByTypeState();
}

class _RecetteByTypeState extends State<RecetteByType> {
  final RecetteDatabase _recetteDatabase = RecetteDatabase();
  final RecetteDatabase _recetteDb = RecetteDatabase();
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTypeIndex = 0;
  int? _selectedSousTypeIndex; // Nullable: no sous-type selected initially
  List<String> _types = [];
  final PageController _pageController = PageController();
  bool _isFavorite = false;
  late Recettes _recette;
  // Sous-types (categories)
  final List<String> _sousTypes = ['Entrée', 'Plat', 'Dessert'];

  // Map type names to their display information
  final Map<String, Map<String, String>> _typeInfo = {
    'Recettes Lef Lef': {
      'text': 'Recettes faciles et rapides',
      'image': 'images/leflef.png',
    },
    'Omek Sannefa': {
      'text': 'Le goût du bon vieux temps',
      'image': 'images/sanefa.png',
    },
    'Benna 3alamiya': {
      'text': 'Voyage culinaire à travers le monde',
      'image': 'images/benna.png',
    },
    'Kool Healthy': {
      'text': 'Faites plaisir à votre santé', // Replace with actual text
      'image': 'images/kool.png',
    },
  };

  @override
  void initState() {
    super.initState();

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    }
  }

  void _goToPreviousType() {
    if (_types.isEmpty) return;

    int newIndex = _selectedTypeIndex - 1;
    if (newIndex < 0) newIndex = _types.length - 1;

    setState(() {
      _selectedTypeIndex = newIndex;
      _selectedSousTypeIndex = null;
    });

    _pageController.animateToPage(
      newIndex + _types.length,
      duration: const Duration(milliseconds: 10),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextType() {
    if (_types.isEmpty) return;

    int newIndex = _selectedTypeIndex + 1;
    if (newIndex >= _types.length) newIndex = 0;

    setState(() {
      _selectedTypeIndex = newIndex;
      _selectedSousTypeIndex = null;
    });

    // Navigate to the middle section position
    _pageController.animateToPage(
      newIndex + _types.length,
      duration: const Duration(milliseconds: 10),
      curve: Curves.easeInOut,
    );
  }

  void _selectSousType(int index) {
    setState(() {
      // If clicking the same sous-type again, deselect it (show all)
      if (_selectedSousTypeIndex == index) {
        _selectedSousTypeIndex = null;
      } else {
        _selectedSousTypeIndex = index;
      }
    });
  }

  // Navigate to recipe details page
  void _navigateToRecipeDetails(Recettes recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecetteDetailsPage(recette: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(body: Center(child: Text(_errorMessage!)));
    }

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
          // Type selector with arrows and image
          StreamBuilder<List<Recettes>>(
            stream: _recetteDatabase.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final recipes = snapshot.data!;
              final types = recipes.map((r) => r.type).toSet().toList();

              if (_types.length != types.length) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _types = types;
                    if (_selectedTypeIndex >= _types.length) {
                      _selectedTypeIndex = 0;
                    }
                  });
                });
              }

              if (_types.isEmpty) {
                return const SizedBox(height: 50);
              }

              return Column(
                children: [
                  SizedBox(
                    height: 100,

                    child: Row(
                      children: [
                        // Left arrow
                        IconButton(
                          onPressed: _goToPreviousType,
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF007A33),
                            size: 15,
                          ),
                        ),

                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount:
                                _types.length *
                                3, // Create multiple copies for infinite effect
                            onPageChanged: (index) {
                              if (_types.isEmpty) return;

                              // Calculate the actual index in the original list
                              final actualIndex = index % _types.length;

                              // If we're near the edges, jump to the middle section for seamless looping
                              if (index < _types.length) {
                                // Near the beginning - jump to middle section
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  _pageController.jumpToPage(
                                    index + _types.length,
                                  );
                                });
                              } else if (index >= _types.length * 2) {
                                // Near the end - jump to middle section
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  _pageController.jumpToPage(
                                    index - _types.length,
                                  );
                                });
                              }

                              setState(() {
                                _selectedTypeIndex = actualIndex;
                                _selectedSousTypeIndex = null;
                              });
                            },
                            itemBuilder: (context, index) {
                              final actualIndex = index % _types.length;
                              final type = _types[actualIndex];
                              final data =
                                  _typeInfo[type] ??
                                  {'text': type, 'image': 'images/logo2.webp'};

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: ClipRRect(
                                        child: Image.asset(
                                          data['image']!,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            type,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Color(0xFFFFB400),
                                              fontFamily: 'Cocon',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            data['text']!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF007A33),
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Right arrow
                        IconButton(
                          onPressed: _goToNextType,
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF007A33),
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sous-type selector (Entrée, Plat, Dessert)
                  SizedBox(
                    height: 30,

                    // margin: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_sousTypes.length, (index) {
                        final isSelected = index == _selectedSousTypeIndex;
                        return GestureDetector(
                          onTap: () => _selectSousType(index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFF007A33)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF007A33),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _sousTypes[index],
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : const Color(0xFF007A33),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 30),

          // Recipes grid for selected type and sous-type (if any)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: StreamBuilder<List<Recettes>>(
                stream: _recetteDatabase.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final recipes = snapshot.data!;
                  if (_types.isEmpty || _selectedTypeIndex >= _types.length) {
                    return const Center(child: Text('No recette found'));
                  }

                  final selectedType = _types[_selectedTypeIndex];

                  // Filter recipes
                  List<Recettes> filteredRecipes;

                  if (_selectedSousTypeIndex != null) {
                    // Filter by both type and sous-type
                    final selectedSousType =
                        _sousTypes[_selectedSousTypeIndex!];
                    filteredRecipes =
                        recipes.where((r) {
                          final matchesType = r.type == selectedType;
                          // Adjust this line based on your Recettes model field name
                          final matchesSousType =
                              r.soustype?.toLowerCase() ==
                              selectedSousType.toLowerCase();
                          return matchesType && matchesSousType;
                        }).toList();
                  } else {
                    // Show all recipes for the selected type (no sous-type filter)
                    filteredRecipes =
                        recipes.where((r) => r.type == selectedType).toList();
                  }

                  if (filteredRecipes.isEmpty) {
                    String message;
                    if (_selectedSousTypeIndex != null) {
                      final selectedSousType =
                          _sousTypes[_selectedSousTypeIndex!];
                      message =
                          'No recette found for $selectedType - $selectedSousType';
                    } else {
                      message = 'No recette found for $selectedType';
                    }
                    return Center(
                      child: Text(message, textAlign: TextAlign.center),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    itemCount: filteredRecipes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 20.0,
                          childAspectRatio: 0.9,
                        ),
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return GestureDetector(
                        onTap: () => _navigateToRecipeDetails(recipe),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [],
                          ),
                          child: ClipRRect(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Recipe Image
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.network(
                                      recipe.image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Image.asset(
                                          'images/logo2.webp',
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                // Recipe Name
                                Container(
                                  color: Colors.white,
                                  child: Text(
                                    recipe.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF007A33),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // Footer with icons
      // Footer navigation bar
      bottomNavigationBar: _buildFooter(),
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
                color: Color(0xFF007A33),
                fontFamily: 'Cocon',
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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

  void _toggleFavorite() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isLoggedIn) return _showLoginDialog();

    try {
      if (_isFavorite) {
        await authService.removeFromFavorites(_recette.id);
      } else {
        await authService.addToFavorites(_recette.id);
      }
      setState(() => _isFavorite = !_isFavorite);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour des favoris'),
        ),
      );
    }
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
