import 'package:flutter/material.dart';
import 'package:bennasafi/services/recettes_database.dart';
import 'package:bennasafi/models/recettes.dart';
import 'package:bennasafi/screens/recette_details.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Recettes> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await RecetteDatabase.searchRecettes(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _hasSearched = true;
      });
      debugPrint('Search error: $e');
    }
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007A33)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recherche',
          style: TextStyle(
            color: Color(0xFF007A33),
            fontFamily: 'Cocon',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        // color: const Color(0xFFBDDE8F),
        child: Column(
          children: [
            // Search bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une recette...',
                  hintStyle: TextStyle(
                    fontFamily: 'Cocon',
                    color: Colors.grey[600],
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF15B03B),
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Color(0xFF15B03B),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _hasSearched = false;
                              });
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Color(0xFF15B03B)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(
                      color: Color(0xFF15B03B),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                style: const TextStyle(fontFamily: 'Cocon', fontSize: 16),
                onChanged: (value) {
                  setState(() {});
                  if (value.length >= 1) {
                    _performSearch(value);
                  } else if (value.isEmpty) {
                    setState(() {
                      _searchResults = [];
                      _hasSearched = false;
                    });
                  }
                },
                onSubmitted: _performSearch,
              ),
            ),

            // Search results
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return _buildLoadingState();
    }

    if (!_hasSearched) {
      return _buildInitialState();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return _buildResultsList();
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/search.png', width: 80, height: 80),
          const SizedBox(height: 20),
          Text(
            'Recherchez vos recettes préférées',
            style: TextStyle(
              fontFamily: 'Cocon',
              fontSize: 18,
              color: Color(0xFF4A8B5C),
            ),
          ),
          const SizedBox(height: 10),
          // Text(
          //   'Tapez au moins 2 caractères pour commencer',
          //   style: TextStyle(
          //     fontFamily: 'Cocon',
          //     fontSize: 14,
          //     color: Colors.grey[600],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer(
          gradient: const LinearGradient(
            colors: [Color(0xFFEBEBF4), Color(0xFFF4F4F4), Color(0xFFEBEBF4)],
            stops: [0.1, 0.3, 0.4],
            begin: Alignment(-1.0, -0.3),
            end: Alignment(1.0, 0.3),
            tileMode: TileMode.clamp,
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/search.png', width: 80, height: 80),
          const SizedBox(height: 20),
          Text(
            'Aucune recette trouvée',
            style: TextStyle(
              fontFamily: 'Cocon',
              fontSize: 18,
              color: Color(0xFF4A8B5C),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Essayez avec d\'autres mots-clés',
            style: TextStyle(
              fontFamily: 'Cocon',
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final recipe = _searchResults[index];
        return GestureDetector(
          onTap: () => _navigateToRecipeDetails(recipe),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Recipe image
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    child:
                        recipe.image.isNotEmpty
                            ? Image.network(
                              recipe.image,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 30),
                                );
                              },
                            )
                            : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 30),
                            ),
                  ),
                ),

                // Recipe info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: const TextStyle(
                            fontFamily: 'Cocon',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A8B5C),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (recipe.soustype.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB400).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              recipe.soustype,
                              style: const TextStyle(
                                fontFamily: 'Cocon',
                                fontSize: 10,
                                color: Color(0xFFFFB400),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        const SizedBox(height: 8),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (recipe.preparation.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF15B03B,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.timer,
                                        size: 12,
                                        color: Color(0xFF15B03B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Préparation: ${recipe.preparation}min',
                                        style: const TextStyle(
                                          fontFamily: 'Cocon',
                                          fontSize: 10,
                                          color: Color(0xFF15B03B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(width: 10),
                              const SizedBox(height: 10),
                              if (recipe.cuisson.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFFB400,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department,
                                        size: 12,
                                        color: Color(0xFFFFB400),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Cuisson: ${recipe.cuisson}min',
                                        style: const TextStyle(
                                          fontFamily: 'Cocon',
                                          fontSize: 10,
                                          color: Color(0xFFFFB400),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Arrow icon
                const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF15B03B),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
