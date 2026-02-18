import 'package:flutter/material.dart';
import 'package:bennasafi/services/recettes_database.dart';
import 'package:bennasafi/models/recettes.dart';
import 'package:bennasafi/screens/recette_details.dart';
import 'package:shimmer/shimmer.dart';
import 'package:bennasafi/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:bennasafi/screens/login_page.dart';
import 'package:bennasafi/screens/favoris_page.dart';
import 'package:bennasafi/screens/profil.dart';
import 'package:bennasafi/screens/composi.dart';
import 'package:bennasafi/screens/search_screen.dart';
import 'package:bennasafi/screens/recetteByType.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Firstpage extends StatefulWidget {
  const Firstpage({super.key});

  @override
  State<Firstpage> createState() => _BennaSafiHomePageState();
}

// ✅ Custom shimmer gradient
const _shimmerGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 255, 255, 255),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [0.1, 0.3, 0.4],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

class _BennaSafiHomePageState extends State<Firstpage> {
  List<Recettes> _plats = [];
  List<Recettes> _desserts = [];
  Recettes? _recetteDuJour;
  Recettes? _ideeGouter;
  DateTime? _lastUpdate;

  // Carousel sections
  List<Recettes> _lefLefRecettes = [];
  List<Recettes> _omekSannefaRecettes = [];
  List<Recettes> _koolHealthyRecettes = [];
  List<Recettes> _benna3alamiyaRecettes = [];
  List<Recettes> _topRecettes = [];
  List<Recettes> _recommendedRecettes = [];
  List<Recettes> _bestRecettes = [];
  bool _isLoadingCarousels = true;

  // Error handling
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRecettes();
  }

  Future<void> _fetchRecettes() async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = '';
        _isLoadingCarousels = true;
      });

      final sections = await RecetteDatabase().fetchSections(
        limit: 6,
        allLimit: 36,
      );

      final plats = sections['plats'] ?? [];
      final desserts = sections['desserts'] ?? [];
      final allRecipes = sections['all'] ?? [...plats, ...desserts];

      setState(() {
        _plats = plats;
        _desserts = desserts;
        _lefLefRecettes = _getRandomRecipes(sections['lef_lef'] ?? [], 5);
        _omekSannefaRecettes = _getRandomRecipes(
          sections['omek_sannefa'] ?? [],
          5,
        );
        _koolHealthyRecettes = _getRandomRecipes(
          sections['kool_healthy'] ?? [],
          5,
        );
        _benna3alamiyaRecettes = _getRandomRecipes(
          sections['benna_3alamiya'] ?? [],
          5,
        );
        _topRecettes = _getRandomRecipes(allRecipes, 6);
        _recommendedRecettes = _getRandomRecipes(allRecipes, 6);
        _bestRecettes = _getRandomRecipes(allRecipes, 5);
        _isLoadingCarousels = false;
      });

      _updateFeaturedRecipes();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erreur lors du chargement des recettes';
        _isLoadingCarousels = false;
      });
      debugPrint('❌ Error in _fetchRecettes: $e');
    }
  }

  List<Recettes> _getRandomRecipes(List<Recettes> recipes, int count) {
    if (recipes.isEmpty) return [];
    if (recipes.length <= count) return recipes;

    // Shuffle and take first 'count' items
    final shuffled = List<Recettes>.from(recipes);
    shuffled.shuffle();
    return shuffled.take(count).toList();
  }

  void _updateFeaturedRecipes() {
    final now = DateTime.now();

    // Check if we need to update (first time or 24 hours passed)
    if (_lastUpdate == null || now.difference(_lastUpdate!).inHours >= 24) {
      setState(() {
        // Select random Plat for "Recette du jour"
        if (_plats.isNotEmpty) {
          _recetteDuJour = _plats[_getRandomIndex(_plats.length)];
        }

        // Select random Dessert for "Idée goûter"
        if (_desserts.isNotEmpty) {
          _ideeGouter = _desserts[_getRandomIndex(_desserts.length)];
        }

        _lastUpdate = now;
      });
    }
  }

  int _getRandomIndex(int max) {
    // Use the current day to get a "random" but consistent index for 24 hours
    final now = DateTime.now();
    return (now.day + now.month + now.year) % max;
  }

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
    debugPrint(
      '🏠 Firstpage.build called, isLoadingCarousels: $_isLoadingCarousels, hasError: $_hasError',
    );
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
            const SizedBox(height: (50)),

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
          Consumer<AuthService>(
            builder: (context, authService, _) {
              return _buildAccountButton(authService);
            },
          ),
        ],
      ),

      body: Container(
        // color: const Color(0xFFBDDE8F),
        // 0xFFBDDE8F
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 70,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  // Logo on top
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    child: Center(
                      child: Image.asset('images/logo2.webp', width: 160),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Expanded(
                child: Container(
                  // color: const Color(0xFFBDDE8F),
                  child: ListView(
                    padding: const EdgeInsets.all(1.0),
                    children: [
                      // Recommended Section with different design
                      _buildTopRecettesSection(
                        title: 'Vous aimez peut-être',
                        recipes: _recommendedRecettes,
                        isLoading: _isLoadingCarousels,
                      ),
                      const SizedBox(height: 14),
                      // Top Recettes Section with different design
                      _buildCarouselSection(
                        title: 'TOP Recettes',
                        recipes: _bestRecettes,
                        isLoading: _isLoadingCarousels,
                      ),
                      const SizedBox(height: 24),
                      // _buildRecommendedSection(
                      //   title: 'TOP Recettes',
                      //   recipes: _topRecettes,
                      //   isLoading: _isLoadingCarousels,
                      // ),
                      // const SizedBox(height: 2)
                      _buildCarouselSection(
                        title: 'Benna Zemniya',
                        recipes: _omekSannefaRecettes,
                        isLoading: _isLoadingCarousels,
                      ),
                      const SizedBox(height: 24),
                      // Carousel Sections
                      _buildCarouselSection(
                        title: 'Benna Lef Lef',
                        recipes: _lefLefRecettes,
                        isLoading: _isLoadingCarousels,
                      ),
                      const SizedBox(height: 24),

                      _buildCarouselSection(
                        title: 'Benna Healthy',
                        recipes: _koolHealthyRecettes,
                        isLoading: _isLoadingCarousels,
                      ),
                      const SizedBox(height: 24),

                      _buildCarouselSection(
                        title: 'Benna 3alamiya',
                        recipes: _benna3alamiyaRecettes,
                        isLoading: _isLoadingCarousels,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Footer navigation bar
      bottomNavigationBar: _buildFooter(),
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

  // Helper method to build styled titles with first word light and second word bold
  Widget _buildStyledTitle(String title, Color color) {
    final words = title.split(' ');

    if (words.length < 2) {
      // If there's only one word, just return it bold
      return Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'Cocon',
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
    }

    // First word with light weight, rest with bold
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: words[0],
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Cocon',
              fontWeight: FontWeight.w200,
              color: color,
            ),
          ),
          TextSpan(
            text: ' ${words.sublist(1).join(' ')}',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Cocon',
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselSection({
    required String title,
    required List<Recettes> recipes,
    required bool isLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: _buildStyledTitle(title, const Color(0xFF7FB636)),
        ),
        const SizedBox(height: 7),

        // Carousel
        if (isLoading)
          _buildShimmerCarousel()
        else if (recipes.isEmpty)
          _buildEmptyCarousel()
        else
          CarouselSlider.builder(
            itemCount: recipes.length,
            options: CarouselOptions(
              height: 250,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.easeInOutCubic,
              pauseAutoPlayOnTouch: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.95,
            ),
            itemBuilder: (context, index, realIndex) {
              final recipe = recipes[index];
              return _buildCarouselCard(recipe);
            },
          ),
      ],
    );
  }

  Widget _buildCarouselCard(Recettes recipe) {
    return GestureDetector(
      onTap: () => _navigateToRecipeDetails(recipe),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Recipe Image
              recipe.image.isNotEmpty
                  ? CachedNetworkImage(
                    imageUrl: recipe.image,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Shimmer(
                          gradient: _shimmerGradient,
                          child: Container(
                            color: Colors.grey[300],
                            width: double.infinity,
                            height: 250,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                  )
                  : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),

              // Recipe Name
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Cocon',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCarousel() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Shimmer(
            gradient: _shimmerGradient,
            child: Container(
              width: 280,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCarousel() {
    return Container(
      height: 220,
      alignment: Alignment.center,
      child: const Text(
        'Aucune recette disponible',
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Cocon',
          color: Color(0xFF7FB636),
        ),
      ),
    );
  }

  // Top Recettes Section with Grid-style Compact Design
  Widget _buildTopRecettesSection({
    required String title,
    required List<Recettes> recipes,
    required bool isLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: _buildStyledTitle(title, const Color(0xFF7FB636)),
        ),
        const SizedBox(height: 7),

        // Carousel with compact design
        if (isLoading)
          _buildShimmerCarousel()
        else if (recipes.isEmpty)
          _buildEmptyCarousel()
        else
          CarouselSlider.builder(
            itemCount: recipes.length,
            options: CarouselOptions(
              height: 175,
              enlargeCenterPage: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 600),
              autoPlayCurve: Curves.fastOutSlowIn,
              pauseAutoPlayOnTouch: true,
              viewportFraction: 0.45,
              aspectRatio: 16 / 9,
            ),
            itemBuilder: (context, index, realIndex) {
              final recipe = recipes[index];
              return _buildTopRecetteCard(recipe);
            },
          ),
      ],
    );
  }

  Widget _buildTopRecetteCard(Recettes recipe) {
    return GestureDetector(
      onTap: () => _navigateToRecipeDetails(recipe),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),

        // No BoxDecoration anymore
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with border only
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), // border only image
              ),
              clipBehavior: Clip.hardEdge, // keeps radius applied
              child:
                  recipe.image.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: recipe.image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Shimmer(
                              gradient: _shimmerGradient,
                              child: Container(
                                color: Colors.grey[200],
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                      )
                      : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
            ),

            // Recipe Name
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                recipe.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Cocon',
                  fontWeight: FontWeight.w100,
                  color: Color(0xFF007A33),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recommended Section with Vertical Card Design
  // Widget _buildRecommendedSection({
  //   required String title,
  //   required List<Recettes> recipes,
  //   required bool isLoading,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       // Section Title
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 14.0),
  //         child: _buildStyledTitle(title, const Color(0xFF7FB636)),
  //       ),
  //       const SizedBox(height: 5),

  //       // Carousel with vertical card design
  //       if (isLoading)
  //         _buildShimmerCarousel()
  //       else if (recipes.isEmpty)
  //         _buildEmptyCarousel()
  //       else
  //         CarouselSlider.builder(
  //           itemCount: recipes.length,
  //           options: CarouselOptions(
  //             height: 300,
  //             enlargeCenterPage: true,
  //             autoPlay: true,
  //             autoPlayInterval: const Duration(seconds: 6),
  //             autoPlayAnimationDuration: const Duration(milliseconds: 1000),
  //             autoPlayCurve: Curves.easeInOutQuart,
  //             pauseAutoPlayOnTouch: true,
  //             viewportFraction: 0.95,
  //           ),
  //           itemBuilder: (context, index, realIndex) {
  //             final recipe = recipes[index];
  //             return _buildRecommendedCard(recipe, 1.0);
  //           },
  //         ),
  //     ],
  //   );
  // }

  // Widget _buildRecommendedCard(Recettes recipe, double animationValue) {
  //   return AnimatedOpacity(
  //     duration: const Duration(milliseconds: 400),
  //     opacity: animationValue,
  //     child: AnimatedScale(
  //       scale: animationValue,
  //       duration: const Duration(milliseconds: 400),
  //       curve: Curves.easeOut,
  //       child: GestureDetector(
  //         onTap: () => _navigateToRecipeDetails(recipe),
  //         child: Container(
  //           margin: const EdgeInsets.symmetric(horizontal: 4.0),

  //           // ❌ Removed BoxDecoration (no border, no shadow)
  //           // decoration: BoxDecoration(...),  <-- removed
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // IMAGE WITH ROUNDED BORDER ONLY
  //               ClipRRect(
  //                 borderRadius: const BorderRadius.all(Radius.circular(8)),
  //                 child:
  //                     recipe.image.isNotEmpty
  //                         ? Image.network(
  //                           recipe.image,
  //                           width: double.infinity,
  //                           height: 250,
  //                           fit: BoxFit.cover,
  //                           errorBuilder: (context, error, stackTrace) {
  //                             return Container(
  //                               height: 180,
  //                               color: Colors.grey[200],
  //                               child: const Icon(
  //                                 Icons.image,
  //                                 size: 50,
  //                                 color: Colors.grey,
  //                               ),
  //                             );
  //                           },
  //                         )
  //                         : Container(
  //                           height: 180,
  //                           color: Colors.grey[200],
  //                           child: const Icon(
  //                             Icons.image,
  //                             size: 50,
  //                             color: Colors.grey,
  //                           ),
  //                         ),
  //               ),

  //               // TEXT AREA
  //               Padding(
  //                 padding: const EdgeInsets.all(2.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       recipe.name,
  //                       style: const TextStyle(
  //                         fontSize: 14,
  //                         fontFamily: 'Cocon',
  //                         fontWeight: FontWeight.w100,
  //                         color: Color(0xFF007A33),
  //                       ),
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAccountButton(AuthService authService) {
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

  // ---------------------- FOOTER ----------------------
  Widget _buildFooter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            // onTap:
            //     () => Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => Firstpage()),
            //     ),
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
}
