import 'package:bennasafi/screens/composi.dart';
import 'package:bennasafi/screens/firstpage.dart';
import 'package:bennasafi/screens/recetteByType.dart';
import 'package:bennasafi/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:bennasafi/services/auth_service.dart';
import 'package:bennasafi/screens/login_page.dart';
import 'package:bennasafi/screens/favoris_page.dart';
import 'package:provider/provider.dart';
import 'package:bennasafi/screens/profil.dart';

class PageTheme extends StatefulWidget {
  const PageTheme({super.key});

  @override
  State<PageTheme> createState() => __BennaSafiSecondPageState();
}

class __BennaSafiSecondPageState extends State<PageTheme> {
  // int _selectedIndex = 0;

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
                    MaterialPageRoute(builder: (_) => PageTheme()),
                  ),
            ),
            ListTile(
              leading: Icon(Icons.restaurant_menu, color: Color(0xFFFFB400)),
              title: Text(
                'Recette du jour',
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
        actions: [_buildAccountButton()],
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Container(
            color: const Color(0xFFE6F2E6),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 50,

                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    // Logo on top
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Center(
                        child: Image.asset('images/hot.png', width: 115),
                      ),
                    ),
                  ],
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Add this
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("images/back-theme.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Add this
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
                                  offset: const Offset(0, 5),
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
                                                color: const Color(0xFF7FB636),
                                                fontSize: 24,
                                                fontWeight: FontWeight.w100,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'par thème',
                                              style: TextStyle(
                                                fontFamily: 'Cocon',
                                                color: const Color(0xFF7FB636),
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
                                      minimumSize: Size(0, 0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Entrée',
                                          style: TextStyle(
                                            color: const Color(0xFF005A24),
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
                                      minimumSize: Size(0, 0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Plat',
                                          style: TextStyle(
                                            color: const Color(0xFF005A24),
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
                                      minimumSize: Size(0, 0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Dessert',
                                          style: TextStyle(
                                            color: const Color(0xFF005A24),
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
                      // Recipes by Style
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("images/back-theme.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Add this
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => RecetteByType(),
                                  //   ),
                                  // );
                                },
                                child: Transform.translate(
                                  offset: const Offset(0, 10),
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Recettes ',
                                          style: const TextStyle(
                                            fontFamily: 'Cocon',
                                            color: Color(0xFF7FB636),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w100,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'par style',
                                          style: const TextStyle(
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
                                  TextButton(
                                    onPressed: () {
                                      // Your action
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Lef lef',
                                          style: TextStyle(
                                            color: const Color(0xFF005A24),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Container(
                                          height: 1,
                                          width: 43,
                                          color: const Color(0xFF005A24),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  TextButton(
                                    onPressed: () {
                                      // Your action
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Omek sannefa',
                                          style: TextStyle(
                                            color: const Color(0xFF005A24),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Container(
                                          height: 1,
                                          width: 80,
                                          color: const Color(0xFF005A24),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  TextButton(
                                    onPressed: () {
                                      // Your action
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '3alamiya',
                                          style: TextStyle(
                                            color: const Color(0xFF005A24),
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
                                ],
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: Image.asset('images/healthy.png', width: 60),
                      ), // Center this image
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("images/back-theme.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Add this
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.translate(
                                offset: const Offset(0, 10),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Recettes ',
                                        style: TextStyle(
                                          fontFamily: 'Cocon',
                                          color: const Color(0xFF7FB636),
                                          fontSize: 24,
                                          fontWeight: FontWeight.w100,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Healthy',
                                        style: TextStyle(
                                          fontFamily: 'Cocon',
                                          color: const Color(0xFF7FB636),
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
                                  TextButton(
                                    onPressed: () {
                                      // Your action
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Entrée',
                                          style: TextStyle(
                                            color: const Color(0xFF005A24),
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
                                  TextButton(
                                    onPressed: () {
                                      // Your action
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Plat',
                                          style: TextStyle(
                                            color: const Color(0xFF005A24),
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
                                  TextButton(
                                    onPressed: () {
                                      // Your action
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Dessert',
                                          style: TextStyle(
                                            color: const Color(0xFF005A24),
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
                      // Composi Dbartek
                      Center(
                        child: Image.asset('images/composi.png', width: 60),
                      ), // Center this image
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("images/back-theme.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Add this
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.translate(
                                offset: const Offset(0, 10),
                                child: GestureDetector(
                                  onTap: () {
                                    // 👉 Add your action here
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Composi(),
                                      ),
                                    );
                                    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => NextPage()));
                                  },
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Composi ',
                                          style: const TextStyle(
                                            fontFamily: 'Cocon',
                                            color: Color(0xFF7FB636),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w100,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Dbartek',
                                          style: const TextStyle(
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
                                      minimumSize: Size(0, 0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 220,
                                          child: Text(
                                            'Des idées recettes à partir de vos ingrédients disponibles',
                                            style: TextStyle(
                                              color: const Color(0xFF005A24),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
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
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ),
      //footer
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
                  MaterialPageRoute(builder: (_) => PageTheme()),
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
}
