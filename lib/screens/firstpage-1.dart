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

class Firstpage extends StatefulWidget {
  const Firstpage({super.key});

  @override
  State<Firstpage> createState() => _BennaSafiHomePageState();
}

// ✅ Custom shimmer gradient
const _shimmerGradient = LinearGradient(
  colors: [Color(0xFFEBEBF4), Color(0xFFF4F4F4), Color(0xFFEBEBF4)],
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

  @override
  void initState() {
    super.initState();
    _fetchRecettes();
  }

  Future<void> _fetchRecettes() async {
    // Fetch both types of recipes
    final plats = await RecetteDatabase.getRecettesBySousType('Entrée');
    final desserts = await RecetteDatabase.getRecettesBySousType('Dessert');

    setState(() {
      _plats = plats;
      _desserts = desserts;
    });

    _updateFeaturedRecipes();
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
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFFFB400)),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cocon',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Color(0xFFFFB400)),
              title: Text(
                'Accueil',
                style: TextStyle(fontFamily: 'Cocon', color: Color(0xFF007A33)),
              ),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Firstpage()),
                  ),
            ),

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

      body: Container(
        color: const Color(0xFFBDDE8F),
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
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Image.asset('images/logo2.webp', width: 180),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Container(
                  color: const Color(0xFFBDDE8F),
                  child: ListView(
                    padding: const EdgeInsets.all(22.0),
                    children: [
                      // Recette du jour (Plat)
                      if (_recetteDuJour != null)
                        GestureDetector(
                          onTap:
                              () => _navigateToRecipeDetails(_recetteDuJour!),
                          child: RecipeCard(
                            title: 'Recette du jour',
                            subtitle: _recetteDuJour!.name,
                            imageUrl: _recetteDuJour!.image,
                          ),
                        )
                      else
                        Shimmer(
                          gradient: _shimmerGradient,
                          child: const RecipeCard(
                            title: 'Recette du jour',
                            subtitle: 'Chargement...',
                            imageUrl: '',
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Idée goûter (Dessert)
                      if (_ideeGouter != null)
                        GestureDetector(
                          onTap: () => _navigateToRecipeDetails(_ideeGouter!),
                          child: RecipeCard(
                            title: 'Idée goûter',
                            subtitle: _ideeGouter!.name,
                            imageUrl: _ideeGouter!.image,
                          ),
                        )
                      else
                        Shimmer(
                          gradient: _shimmerGradient,
                          child: const RecipeCard(
                            title: 'Recette du jour',
                            subtitle: 'Chargement...',
                            imageUrl: '',
                          ),
                        ),
                      const SizedBox(height: 16),
                      _buildSuiteSection(context),
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

  Widget _buildSuiteSection(BuildContext context) {
    return Center(
      child: Container(
        color: const Color(0xFFBDDE8F),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===== Header (hot) =====
            Stack(
              children: [
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Container(
                //     height: 50,
                //     color: const Color.fromARGB(255, 255, 255, 255),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Center(
                    child: Image.asset('images/hot.png', width: 115),
                  ),
                ),
              ],
            ),

            // ===== Recettes par thème =====
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/back-theme.png"),
                  fit: BoxFit.contain,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecetteByType(),
                          ),
                        );
                      },
                      child: Transform.translate(
                        offset: const Offset(0, 15),
                        child: Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Recettes ',
                                    style: TextStyle(
                                      fontFamily: 'Cocon',
                                      color: Color(0xFF7FB636),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'par thème',
                                    style: TextStyle(
                                      fontFamily: 'Cocon',
                                      color: Color(0xFF7FB636),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Entrée
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecetteByType(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Entrée',
                                style: TextStyle(
                                  color: Color(0xFF005A24),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                height: 1,
                                width: 42,
                                color: const Color(0xFF005A24),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Plat
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecetteByType(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Plat',
                                style: TextStyle(
                                  color: Color(0xFF005A24),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                height: 1,
                                width: 25,
                                color: const Color(0xFF005A24),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Dessert
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecetteByType(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            // padding: EdgeBox.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Dessert',
                                style: TextStyle(
                                  color: Color(0xFF005A24),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                height: 1,
                                width: 50,
                                color: const Color(0xFF005A24),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ===== Recettes par style =====
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/back-theme.png"),
                  fit: BoxFit.contain,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 15),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Recettes ',
                              style: TextStyle(
                                fontFamily: 'Cocon',
                                color: Color(0xFF7FB636),
                                fontSize: 24,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                            TextSpan(
                              text: 'par style',
                              style: TextStyle(
                                fontFamily: 'Cocon',
                                color: Color(0xFF7FB636),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lef lef
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecetteByType(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Lef lef',
                                style: TextStyle(
                                  color: Color(0xFF005A24),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                height: 1,
                                width: 40,
                                color: const Color(0xFF005A24),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Omek sannefa
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecetteByType(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Omek sannefa',
                                style: TextStyle(
                                  color: Color(0xFF005A24),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                height: 1,
                                width: 90,
                                color: const Color(0xFF005A24),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 3alamiya
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecetteByType(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '3alamiya',
                                style: TextStyle(
                                  color: Color(0xFF005A24),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                height: 1,
                                width: 60,
                                color: const Color(0xFF005A24),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // ===== Healthy =====
            Center(child: Image.asset('images/healthy.png', width: 60)),
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/back-theme.png"),
                  fit: BoxFit.contain,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 15),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Recettes ',
                              style: TextStyle(
                                fontFamily: 'Cocon',
                                color: Color(0xFF7FB636),
                                fontSize: 24,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                            TextSpan(
                              text: 'Healthy',
                              style: TextStyle(
                                fontFamily: 'Cocon',
                                color: Color(0xFF7FB636),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Entrée
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecetteByType(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Entrée',
                                style: TextStyle(
                                  color: Color(0xFF005A24),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                height: 1,
                                width: 42,
                                color: const Color(0xFF005A24),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Plat
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecetteByType(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Plat',
                                style: TextStyle(
                                  color: Color(0xFF005A24),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                height: 1,
                                width: 25,
                                color: const Color(0xFF005A24),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Dessert
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecetteByType(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Dessert',
                                style: TextStyle(
                                  color: Color(0xFF005A24),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                height: 1,
                                width: 50,
                                color: const Color(0xFF005A24),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // ===== Composi Dbartek =====
            Center(child: Image.asset('images/composi.png', width: 60)),
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/back-theme.png"),
                  fit: BoxFit.contain,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 15),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Composi()),
                          );
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Composi ',
                                style: TextStyle(
                                  fontFamily: 'Cocon',
                                  color: Color(0xFF7FB636),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                              TextSpan(
                                text: 'Dbartek',
                                style: TextStyle(
                                  fontFamily: 'Cocon',
                                  color: Color(0xFF7FB636),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Composi(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 220,
                                child: Text(
                                  'Des idées recettes à partir de vos ingrédients disponibles',
                                  style: TextStyle(
                                    color: Color(0xFF005A24),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 3),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            // const SizedBox(height: 10),
          ],
        ),
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

// Recipe card widget
class RecipeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;

  const RecipeCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Cocon',
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A8B5C),
              ),
            ),
          ),
          ClipRRect(
            // borderRadius: const BorderRadius.only(
            //   bottomLeft: Radius.circular(40),
            //   bottomRight: Radius.circular(40),
            // ),
            child:
                imageUrl.isNotEmpty
                    ? Image.network(
                      imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 50),
                        );
                      },
                    )
                    : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Image non disponible',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
          ),
          if (subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 10.0),
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A8B5C),
                  fontFamily: 'Cocon',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
