import 'package:flutter/material.dart';

class Themes extends StatelessWidget {
  const Themes({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            // color: const Color.fromARGB(255, 255, 255, 255),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Color.fromARGB(255, 21, 176, 59),
                  ),
                  onPressed: () {},
                ),
                // Expanded(
                //   child: Center(
                //     child: Image.asset('images/logo2.webp', height: 50),
                //   ),
                // ),
                IconButton(
                  icon: const Icon(
                    Icons.login,
                    color: Color.fromARGB(255, 21, 176, 59),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Footer with icons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('images/logo2.webp', width: 60),
                    Text(
                      'Acceuil',
                      style: TextStyle(
                        fontSize: 8,
                        color: Color.fromARGB(255, 21, 176, 59),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.search,
                        color: Color.fromARGB(255, 21, 176, 59),
                        size: 25,
                      ),
                      Text(
                        'Recherche',
                        style: TextStyle(
                          fontSize: 8,
                          color: Color.fromARGB(255, 21, 176, 59),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.favorite_border,
                        color: Color.fromARGB(255, 21, 176, 59),
                        size: 25,
                      ),
                      Text(
                        'Favoris',
                        style: TextStyle(
                          fontSize: 8,
                          color: Color.fromARGB(255, 21, 176, 59),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
