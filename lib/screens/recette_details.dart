import 'dart:io';

import 'package:bennasafi/screens/firstpage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:bennasafi/models/recettes.dart';
import 'package:bennasafi/services/recettes_database.dart';
import 'package:bennasafi/services/auth_service.dart';
import 'package:bennasafi/screens/login_page.dart';
import 'package:bennasafi/screens/favoris_page.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:bennasafi/models/comments.dart';
import 'package:bennasafi/services/comment_database.dart';
import 'package:intl/intl.dart';
import 'package:bennasafi/services/rating_database.dart';
import 'package:bennasafi/screens/profil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennasafi/models/recette_photo.dart';
import 'package:bennasafi/services/recettephoto_database.dart';
import 'package:bennasafi/screens/composi.dart';
import 'package:bennasafi/screens/search_screen.dart';

class RecetteDetailsPage extends StatefulWidget {
  final Recettes recette;

  const RecetteDetailsPage({super.key, required this.recette});

  @override
  State<RecetteDetailsPage> createState() => _RecetteDetailsPageState();
}

class _RecetteDetailsPageState extends State<RecetteDetailsPage> {
  final RecetteDatabase _recetteDb = RecetteDatabase();
  final ImagePicker _imagePicker = ImagePicker();
  late Recettes _recette;
  late int _nbre;
  List<Recettes> _relatedRecettes = [];
  final TextEditingController _commentTextController = TextEditingController();
  final CommentDatabase _commentController = CommentDatabase();
  int _myRating = 0;
  final RatingDatabase _ratingDb = RatingDatabase();
  List<Comments> _comments = [];
  bool _isFavorite = false;
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    _recette = widget.recette;
    _nbre = _recette.nbre;
    _fetchRelations();
    _fetchComments();
    _loadMyRating();
    _initFavoriteState();
  }

  // ---------------------- UI BUILD ----------------------
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
                  Scaffold.of(context).openDrawer();
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset('images/menu.png', width: 20, height: 20),
                ),
              ),
        ),
        actions: [_buildAccountButton()],
      ),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28, weight: 200),
              onPressed: () => Navigator.of(context).pop(),
            ),
            leadingWidth: 40,
            titleSpacing: 0,
            title: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                _recette.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFB400),
                  fontFamily: 'Cocon',
                ),
              ),
            ),
            centerTitle: false,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildCountRating(), _buildCountComment()],
              ),
            ),
          ),

          _buildHeader(),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoCards(),
                  const SizedBox(height: 24),
                  _buildIngredientsSection(),
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),
                  _buildRecettePhotosSlideshow(),
                  const SizedBox(height: 20),
                  _buildCommentSection(),
                  const SizedBox(height: 20),
                  _buildFeedbackSection(),
                  const SizedBox(height: 20),
                  _buildFavoriteButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  // ---------------------- RECIPE PHOTOS ----------------------
  final RecettePhotoService _photoService = RecettePhotoService();

  Future<List<RecettePhoto>> _fetchRecettePhotos() async {
    return await _photoService.fetchPhotos(_recette.id);
  }

  Widget _buildRecettePhotosSlideshow() {
    return FutureBuilder<List<RecettePhoto>>(
      future: _fetchRecettePhotos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final photos = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Slideshow',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007A33),
              ),
            ),
            const SizedBox(height: 12),
            CarouselSlider.builder(
              options: CarouselOptions(
                height: 100,
                viewportFraction: photos.length >= 4 ? 0.35 : 0.35,
                autoPlay: photos.length > 1,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                enableInfiniteScroll: photos.length >= 4,
                padEnds: photos.length >= 4,
                scrollDirection: Axis.horizontal,
                pauseAutoPlayOnTouch: true,
                clipBehavior: Clip.none,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index, realIndex) {
                final photo = photos[index];
                return GestureDetector(
                  onTap: () {
                    _showImageZoomDialog(photo.imageUrl);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        photo.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.error_outline,
                              color: Colors.grey,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ---------------------- IMAGE ZOOM DIALOG ----------------------
  void _showImageZoomDialog(String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    initialScale: PhotoViewComputedScale.contained,
                    heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildCommentSection() {
    if (_isLoadingComments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_comments.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Commentaires',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF007A33),
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildUserRatingBadge(comment.userId),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.20,
                          height: MediaQuery.of(context).size.width * 0.20,
                          child: ClipOval(
                            child:
                                (comment.user?.photo != null &&
                                        comment.user!.photo!.isNotEmpty)
                                    ? Image.network(
                                      comment.user!.photo!,
                                      fit: BoxFit.cover,
                                    )
                                    : (comment.user?.gender == 'Femme'
                                        ? Image.asset(
                                          'assets/images/girl.png',
                                          fit: BoxFit.cover,
                                        )
                                        : Image.asset(
                                          'assets/images/avatar.png',
                                          fit: BoxFit.cover,
                                        )),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment.user?.name ?? 'inconnu',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF007A33),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    comment.createdAt != null
                                        ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(comment.createdAt!.toLocal())
                                        : '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comment.comment ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (index < _comments.length - 1)
                      Container(
                        margin: const EdgeInsets.only(top: 12.0),
                        height: 1,
                        color: Colors.grey[300],
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }
  }

  // ---------------------- HEADER ----------------------
  Widget _buildCountRating() {
    return Row(
      children: [
        ...List.generate(5, (index) {
          bool isFilled = index < _myRating;
          return Icon(
            isFilled ? Icons.star : Icons.star_border,
            size: 20,
            color: const Color(0xFFFFB400),
          );
        }),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildCountComment() {
    return Row(
      children: [
        Image.asset('images/comment.png', width: 20, height: 20),
        const SizedBox(width: 4),
        Text(
          '${_comments.length} commentaires',
          style: const TextStyle(fontSize: 16, color: Color(0xFF007A33)),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Image.network(
        _recette.image,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'images/logo2.webp',
            height: 300,
            fit: BoxFit.contain,
          );
        },
      ),
    );
  }

  // ---------------------- FEEDBACK ----------------------
  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 158, 161, 154),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Text(
            'Donnez-nous votre avis!',
            style: TextStyle(fontSize: 22, fontFamily: 'Cocon'),
          ),
          const SizedBox(height: 10),
          _buildStarRating(),
          const SizedBox(height: 20),
          _buildPhotoSection(),
          const SizedBox(height: 20),
          _buildCommentInputSection(),
        ],
      ),
    );
  }

  // ---------------------- FAVORITE BUTTON ----------------------
  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _isFavorite ? Colors.red : const Color(0xFF7FB636),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
              style: TextStyle(
                fontSize: 20,
                color: _isFavorite ? Colors.red : const Color(0xFF7FB636),
              ),
            ),
            const SizedBox(width: 12),
            Image.asset(
              'images/coeur.png',
              height: 24,
              width: 24,
              color: _isFavorite ? Colors.red : const Color(0xFF7FB636),
            ),
          ],
        ),
      ),
    );
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

  // ---------------------- PHOTO PICKER ----------------------
  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: DottedBorder(
        color: const Color(0xFFFFB400),
        strokeWidth: 2,
        borderType: BorderType.RRect,
        radius: const Radius.circular(30),
        dashPattern: const [3, 3],
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ajouter votre photo',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cocon',
                  color: Color(0xFFFFB400),
                ),
              ),
              const SizedBox(width: 12),
              Image.asset('images/camera.png', height: 24, width: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------- COMMENT INPUT ----------------------
  Widget _buildCommentInputSection() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Ajouter un commentaire'),
                content: TextField(
                  controller: _commentTextController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Écrivez votre commentaire ici...',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _submitComment();
                    },
                    child: const Text('Envoyer'),
                  ),
                ],
              ),
        );
      },
      child: DottedBorder(
        color: const Color.fromARGB(255, 100, 101, 99),
        strokeWidth: 2,
        borderType: BorderType.RRect,
        radius: const Radius.circular(30),
        dashPattern: const [3, 3],
        child: Container(
          padding: const EdgeInsets.all(12),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ajouter votre commentaire',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cocon',
                  color: Colors.black,
                ),
              ),
            ],
          ),
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
                    fontSize: 8,
                    color: Color(0xFF15B03B),
                    fontFamily: 'Cocon',
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
              fontSize: 8,
              color: Color(0xFF15B03B),
              fontFamily: 'Cocon',
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------- DATA METHODS ----------------------
  Future<void> _fetchRelations() async {
    try {
      final enriched = await _recetteDb.fetchById(_recette.id);
      if (!mounted) return;
      if (enriched != null) {
        setState(() {
          _recette = enriched;
        });
      }

      if (_recette.soustype.isNotEmpty) {
        final related = await _recetteDb.fetchBySubtype(_recette.soustype);
        if (!mounted) return;
        setState(() {
          _relatedRecettes = related.where((r) => r.id != _recette.id).toList();
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _fetchComments() async {
    if (mounted) {
      setState(() => _isLoadingComments = true);
    }

    try {
      final comments = await _commentController.fetchCommentsByRecette(
        _recette.id,
      );
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      print('Error fetching comments: $e');
      if (mounted) {
        setState(() => _isLoadingComments = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des commentaires: $e'),
          ),
        );
      }
    }
  }

  Future<void> _loadMyRating() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (!authService.isLoggedIn) return;
      final user = authService.currentUser;
      if (user == null) return;
      final value = await _ratingDb.getUserRating(
        user.id.toString(),
        _recette.id,
      );
      if (!mounted) return;
      setState(() {
        _myRating = value ?? 0;
      });
    } catch (_) {
      // ignore errors silently
    }
  }

  Future<void> _submitRating(int value) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isLoggedIn) return _showLoginDialog();
    final user = authService.currentUser;
    if (user == null) return;
    try {
      await _ratingDb.upsertRating(user.id.toString(), _recette.id, value);
      if (!mounted) return;
      setState(() {
        _myRating = value;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Merci pour votre note!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'enregistrement de la note: $e'),
        ),
      );
    }
  }

  Future<void> _initFavoriteState() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (!authService.isLoggedIn) return;
      final favorited = await authService.isFavorite(_recette.id);
      if (!mounted) return;
      setState(() => _isFavorite = favorited);
    } catch (_) {
      // ignore
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = _myRating >= starIndex;
        return GestureDetector(
          onTap: () => _submitRating(starIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              size: 36,
              color: const Color(0xFFFFB400),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUserRatingBadge(String? userId) {
    if (userId == null || userId.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<int?>(
      future: _ratingDb.getUserRating(userId, _recette.id),
      builder: (context, snapshot) {
        final value = snapshot.data ?? 0;
        if (value <= 0) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final filled = i < value;
            return Icon(
              filled ? Icons.star : Icons.star_border,
              size: 14,
              color: const Color(0xFFFFB400),
            );
          }),
        );
      },
    );
  }

  // ---------------------- LOGIC METHODS ----------------------
  void increment() => setState(() => _nbre++);
  void decrement() => setState(() => _nbre = _nbre > 1 ? _nbre - 1 : 1);

  Future<void> _pickImage() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isLoggedIn) return _showLoginDialog();

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        final supabase = Supabase.instance.client;

        final fileName =
            '${authService.currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'recette_photos/recette_${_recette.id}/$fileName';

        await supabase.storage
            .from('images')
            .upload(filePath, File(image.path));

        final imageUrl = supabase.storage.from('images').getPublicUrl(filePath);

        await supabase.from('recette_photos').insert({
          'recette_id': _recette.id,
          'user_id': authService.currentUser!.id,
          'image_url': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo ajoutée avec succès!')),
        );

        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement de la photo: $e')),
      );
    }
  }

  Future<void> _submitComment() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isLoggedIn) return _showLoginDialog();

    final user = authService.currentUser;
    if (user == null) return;

    final text = _commentTextController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez écrire un commentaire')),
      );
      return;
    }

    final comment = Comments(
      comment: text,
      userId: user.id,
      recetteId: _recette.id,
    );

    try {
      await _commentController.insertComment(comment);
      _commentTextController.clear();

      await _fetchComments();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commentaire ajouté avec succès!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du commentaire: $e')),
      );
    }
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

  String _niveauLabel() {
    final list = _recette.niveau;
    if (list == null || list.isEmpty) return '-';
    return list.first.name;
  }

  Widget? _niveauImage() {
    final list = _recette.niveau;
    if (list == null || list.isEmpty) return null;
    final url = list.first.image;
    if (url.isEmpty) return null;
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
    if (isNetwork) {
      return Image.network(url, fit: BoxFit.contain, width: 10, height: 10);
    } else {
      return Image.asset(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      );
    }
  }

  Widget _buildIngredientsSection() {
    final ingredients = _recette.ingredients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Ingrédients',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007A33),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: decrement,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F2E6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(17),
                      bottomLeft: Radius.circular(17),
                    ),
                  ),
                  child: const Text(
                    '-',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF007A33),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3),
              Container(
                padding: const EdgeInsets.all(6),
                color: const Color(0xFFE6F2E6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _nbre.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF007A33),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Image.asset('images/icon.png', width: 20),
                  ],
                ),
              ),
              SizedBox(width: 3),
              GestureDetector(
                onTap: increment,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F2E6),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(17),
                      bottomRight: Radius.circular(17),
                    ),
                  ),
                  child: const Text(
                    '+',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF007A33),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (ingredients != null && ingredients.isNotEmpty)
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ingredients.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              final qty = _recette.getScaledIngredientQuantity(
                ingredient.id,
                _nbre,
              );
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color.fromARGB(255, 197, 202, 199),
                        width: 1,
                      ),
                    ),
                    child: Image.network(
                      ingredient.image,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          qty.isNotEmpty ? qty : '-',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    ingredient.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Aucun ingrédient spécifié',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF7FB636), width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text(
                'Commencer la recette',
                style: TextStyle(fontSize: 20, color: Color(0xFF7FB636)),
              ),
              const SizedBox(width: 12),
              Image.asset('images/prep.png', height: 24, width: 24),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Préparation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF007A33),
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _recette.description.isNotEmpty
                ? Html(
                  data: _recette.description,
                  style: {
                    "ol": Style(
                      fontSize: FontSize(16),
                      color: Colors.black87,
                      lineHeight: LineHeight.number(1.4),
                    ),
                    "li": Style(margin: Margins.only(bottom: 6)),
                  },
                )
                : const Text(
                  'Aucune description disponible',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    final niveauLabel = _niveauLabel();
    final niveauImage = _niveauImage();
    return Row(
      children: [
        Expanded(
          child: Container(
            child: Column(
              children: [
                const Text(
                  'Préparation',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF007A33),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset('images/preparation.png', width: 40),
                const SizedBox(height: 8),
                Text(
                  '${_recette.preparation}min',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007A33),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Container(
            child: Column(
              children: [
                const Text(
                  'Cuisson',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF007A33),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Image.asset('images/cuisson.png', width: 46),
                const SizedBox(height: 8),
                Text(
                  '${_recette.cuisson}min',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007A33),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Container(
            child: Column(
              children: [
                const Text(
                  'Difficulté',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF007A33),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (niveauImage != null) ...[
                  SizedBox(width: 80, height: 60, child: niveauImage),
                ],
                Text(
                  niveauLabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007A33),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
