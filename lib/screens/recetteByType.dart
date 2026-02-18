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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class RecetteByType extends StatefulWidget {
  const RecetteByType({super.key});

  @override
  State<RecetteByType> createState() => _RecetteByTypeState();
}

class _RecetteByTypeState extends State<RecetteByType> {
  final RecetteDatabase _recetteDatabase = RecetteDatabase();
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTypeIndex = 0;
  int? _selectedSousTypeIndex; // Nullable: no sous-type selected initially
  List<String> _types = [];
  List<Recettes> _allRecipes = [];
  final PageController _pageController = PageController();
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
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final recipes = await _recetteDatabase.fetchAll();
      if (!mounted) return;
      final types = recipes.map((r) => r.type).toSet().toList();
      setState(() {
        _allRecipes = recipes;
        _types = types;
        if (_types.isNotEmpty && _selectedTypeIndex >= _types.length) {
          _selectedTypeIndex = 0;
        }
        _selectedSousTypeIndex = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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

  // Build loading shimmer skeleton
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Colors.white,
            title: Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 20.0,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Container(color: Colors.white)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 120,
                                height: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: 6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(body: Center(child: Text(_errorMessage!)));
    }

    return Scaffold(
      drawer: Drawer(
        elevation: 15,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                children: [
                  _buildAnimatedTile(
                    context,
                    icon: Icons.home,
                    title: "Accueil",
                    page: Firstpage(),
                  ),
                  _buildAnimatedTile(
                    context,
                    icon: Icons.menu_book,
                    title: "Toutes les recettes",
                    page: RecetteByType(),
                  ),
                  _buildAnimatedTile(
                    context,
                    icon: Icons.kitchen,
                    title: "Composi Dbartek",
                    page: const Composi(),
                  ),
                ],
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
          if (_types.isEmpty)
            const SizedBox(height: 50)
          else
            Column(
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
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _pageController.jumpToPage(
                                  index + _types.length,
                                );
                              });
                            } else if (index >= _types.length * 2) {
                              // Near the end - jump to middle section
                              WidgetsBinding.instance.addPostFrameCallback((_) {
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
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Text(
                                            type,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Color(0xFFFFB400),
                                              fontFamily: 'Cocon',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Text(
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
            ),

          SizedBox(height: 30),

          // Recipes grid for selected type and sous-type (if any)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Builder(
                builder: (context) {
                  // Show loading shimmer while data is loading
                  if (_isLoading) {
                    return _buildLoadingShimmer();
                  }

                  final recipes = _allRecipes;
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
                              r.soustype.toLowerCase() ==
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
                                    child: CachedNetworkImage(
                                      imageUrl: recipe.image,
                                      fit: BoxFit.cover,
                                      memCacheWidth: 600,
                                      memCacheHeight: 600,
                                      placeholder:
                                          (context, url) => Container(
                                            color: Colors.grey.shade200,
                                          ),
                                      errorWidget:
                                          (context, url, error) => Image.asset(
                                            'images/logo2.webp',
                                            fit: BoxFit.contain,
                                          ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    height: 4,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Mon Compte',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF007A33),
                      fontFamily: 'Cocon',
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Menu Items
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007A33).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF007A33),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Mon Profil',
                    style: TextStyle(
                      fontFamily: 'Cocon',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF007A33),
                  ),
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
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007A33).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFF007A33),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Mes Favoris',
                    style: TextStyle(
                      fontFamily: 'Cocon',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF007A33),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FavorisPage()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Déconnexion',
                    style: TextStyle(
                      fontFamily: 'Cocon',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.red,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Provider.of<AuthService>(context, listen: false).logout();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildAnimatedTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(-30 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF007A33).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF007A33), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cocon',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF007A33),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: Colors.transparent,
        hoverColor: const Color(0xFF007A33).withOpacity(0.08),
        splashColor: const Color(0xFF007A33).withOpacity(0.12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 450),
              pageBuilder: (_, __, ___) => page,
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
            ),
          );
        },
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
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
