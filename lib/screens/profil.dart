import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/comments.dart';
import '../models/recettes.dart';
import 'package:bennasafi/services/comment_database.dart';
import 'package:bennasafi/services/recettes_database.dart';
import 'package:bennasafi/services/auth_service.dart';
import 'package:bennasafi/screens/login_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bennasafi/services/notification_service.dart';

class ProfilePage extends StatefulWidget {
  final Users user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Users _currentUser;
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _commentController = TextEditingController();
  final _imagePicker = ImagePicker();
  List<Comments> _userComments = [];
  Map<int, Recettes> _recipeDetails = {};
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _nameController.text = _currentUser.name;
    _emailController.text = _currentUser.email;
    _loadUserComments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    // _genderController.dispose();
    super.dispose();
  }

  Future<void> _loadUserComments() async {
    if (_currentUser.id == null) return;

    setState(() => _isLoading = true);
    try {
      final commentDb = CommentDatabase();
      final comments = await commentDb.getCommentsByUserId(_currentUser.id!);
      final recipeDb = RecetteDatabase();
      final Map<int, Recettes> recipeDetails = {};

      for (final comment in comments) {
        if (comment.recetteId != null &&
            !recipeDetails.containsKey(comment.recetteId)) {
          try {
            final recipe = await recipeDb.fetchById(comment.recetteId!);
            if (recipe != null) {
              recipeDetails[comment.recetteId!] = recipe;
            }
          } catch (e) {
            print('Error fetching recipe ${comment.recetteId}: $e');
          }
        }
      }

      setState(() {
        _userComments = comments;
        _recipeDetails = recipeDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        NotificationService.showError(
          'Erreur lors du chargement des commentaires: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mon Profile',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontFamily: 'Cocon'),
        ),

        backgroundColor: const Color(0xFF007A33),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===== Avatar =====
            _buildAvatarSection(),
            const SizedBox(height: 16),

            // ===== Name & Email =====
            if (_isEditing) _buildEditForm() else _buildUserInfo(),

            const SizedBox(height: 24),
            // ===== My Recipes =====
            const SizedBox(height: 24),
            // ===== Comments =====
            _buildSectionTitle('Mes Commentaires'),
            const SizedBox(height: 24),
            _buildCommentsSection(),

            const SizedBox(height: 24),

            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // ===== Avatar Section =====
  Widget _buildAvatarSection() {
    Widget getDefaultImage() {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green, width: 4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Image.asset(
            _currentUser.gender == 'Femme'
                ? 'assets/images/girl.png'
                : 'assets/images/avatar.png',
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final String? avatarUrl =
        _currentUser.photo != null &&
                _currentUser.photo!.isNotEmpty &&
                _currentUser.photo!.startsWith('http') &&
                !_currentUser.photo!.contains('/images/avatar.jpg') &&
                !_currentUser.photo!.contains('/images/girl.png')
            ? _currentUser.photo!
            : null;

    return Stack(
      alignment: Alignment.bottomRight,

      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.green[100],
          child:
              avatarUrl != null
                  ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF007A33),
                                ),
                              ),
                            ),
                          ),
                      errorWidget: (context, url, error) {
                        debugPrint('Error loading avatar: $error');
                        return Container(
                          width: 120,
                          height: 120,
                          color: Colors.green[100],
                          child: ClipOval(child: getDefaultImage()),
                        );
                      },
                    ),
                  )
                  : getDefaultImage(),
        ),

        if (_isUploadingImage)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),

        if (_isEditing)
          GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green[700],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () {
              setState(() {
                _isEditing = true;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green[700],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.edit, size: 20, color: Colors.white),
            ),
          ),
      ],
    );
  }

  // ===== User Info Display =====
  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          _currentUser.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF007A33),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _currentUser.email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          'Je suis : ${_currentUser.gender}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        if (_currentUser.createdAt != null)
          Text(
            'Membre depuis: ${_currentUser.createdAt!.day}/${_currentUser.createdAt!.month}/${_currentUser.createdAt!.year}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
      ],
    );
  }

  // ===== Edit Form =====
  Widget _buildEditForm() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nom',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
        ),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Sauvegarder',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _nameController.text = _currentUser.name;
                    _emailController.text = _currentUser.email;
                    _commentController.text = _currentUser.comment ?? '';
                  });
                },
                child: const Text('Annuler'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== Statistics Section =====
  // Widget _buildStatisticsSection() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //     children: [
  //       _buildStatCard(
  //         'Recettes',
  //         _currentUser.photoRecette != null &&
  //                 _currentUser.photoRecette!.isNotEmpty
  //             ? '1'
  //             : '0',
  //         Icons.restaurant_menu,
  //       ),
  //       _buildStatCard(
  //         'Favoris',
  //         '0',
  //         Icons.favorite,
  //       ), // This will be updated when we get favorites count
  //       _buildStatCard(
  //         'Commentaires',
  //         '${_userComments.length}',
  //         Icons.comment,
  //       ),
  //     ],
  //   );
  // }

  // ===== Comments Section =====
  Widget _buildCommentsSection() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007A33)),
        ),
      );
    }

    if (_userComments.isEmpty) {
      return const Text(
        'Aucun commentaire pour le moment',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children:
          _userComments
              .take(3)
              .map((comment) => _buildCommentCard(comment))
              .toList(),
    );
  }

  Widget _buildCommentCard(Comments comment) {
    final recipe =
        comment.recetteId != null ? _recipeDetails[comment.recetteId] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Recipe image
              if (recipe != null) ...[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(recipe.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // Recipe name and actions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe?.name ?? 'Recette #${comment.recetteId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF007A33),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons - Only show if current user owns the comment
              if (_isCommentOwner(comment))
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF007A33),
                      ),
                      onPressed: () => _editComment(comment),
                      tooltip: 'Modifier',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteComment(comment),
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.comment ?? '', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (comment.createdAt != null)
                Text(
                  '${comment.createdAt!.day}/${comment.createdAt!.month}/${comment.createdAt!.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              if (recipe != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recipe.type,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF007A33),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Action Buttons =====
  Widget _buildActionButtons() {
    return Column(
      children: [
        // SizedBox(
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== Helper Methods =====
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF007A33),
        ),
      ),
    );
  }

  // ===== Action Methods =====
  Future<void> _pickProfileImage() async {
    try {
      // Show source selection dialog
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Choisir la source'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Galerie'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Caméra'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ],
              ),
            ),
      );

      if (source == null) return;

      setState(() => _isUploadingImage = true);

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        try {
          final authService = Provider.of<AuthService>(context, listen: false);
          final success = await authService.uploadProfilePhoto(image.path);

          if (success) {
            // Refresh user data from auth service (it should be updated already)
            final updatedUser = authService.currentUser;
            setState(() {
              if (updatedUser != null) {
                _currentUser = updatedUser;
              }
            });

            if (mounted) {
              NotificationService.showSuccess(
                'Photo de profil mise à jour avec succès!',
              );
            }
          } else {
            if (mounted) {
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              final errorMessage =
                  authService.lastError ??
                  'Erreur lors de la mise à jour de la photo';
              NotificationService.showError(errorMessage);
            }
          }
        } catch (e) {
          debugPrint('Error uploading image: $e');
          if (mounted) {
            NotificationService.showError(
              'Erreur lors du téléchargement de l\'image: $e',
            );
          }
        }
      }

      setState(() => _isUploadingImage = false);
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        NotificationService.showError(
          'Erreur lors de la sélection de l\'image: $e',
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      NotificationService.showWarning(
        'Veuillez remplir tous les champs obligatoires',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update user profile through auth service
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (success) {
        // Get updated user from auth service
        final updatedUser = authService.currentUser;
        setState(() {
          if (updatedUser != null) {
            _currentUser = updatedUser;
          } else {
            // Fallback: update local state
            _currentUser = _currentUser.copyWith(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
            );
          }
          _isEditing = false;
        });

        if (mounted) {
          NotificationService.showSuccess('Profil mis à jour avec succès!');
        }
      } else {
        if (mounted) {
          final errorMessage =
              authService.lastError ??
              'Erreur lors de la mise à jour du profil';
          NotificationService.showError(errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showError('Erreur lors de la mise à jour: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isCommentOwner(Comments comment) {
    // Convert both IDs to comparable format
    final currentUserId = int.tryParse(_currentUser.id ?? '');
    return currentUserId != null && comment.userId == currentUserId;
  }

  Future<void> _editComment(Comments comment) async {
    if (!_isCommentOwner(comment)) {
      NotificationService.showError(
        'Vous ne pouvez éditer que vos propres commentaires',
      );
      return;
    }

    final controller = TextEditingController(text: comment.comment ?? '');

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: const [
                Icon(Icons.edit, color: Color(0xFF007A33), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Modifier le commentaire',
                    style: TextStyle(
                      color: Color(0xFF007A33),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    minLines: 2,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Votre commentaire...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF007A33),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF007A33),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF007A33),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) {
                    NotificationService.showWarning(
                      'Le commentaire ne peut pas être vide',
                    );
                    return;
                  }
                  try {
                    final commentDb = CommentDatabase();
                    await commentDb.updateComment(
                      comment.id!,
                      controller.text.trim(),
                    );
                    if (mounted) {
                      _loadUserComments();
                      Navigator.pop(context);
                      NotificationService.showSuccess(
                        'Commentaire modifié avec succès!',
                      );
                    }
                  } catch (e) {
                    NotificationService.showError(
                      'Erreur lors de la modification: ${e.toString()}',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A33),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sauvegarder',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteComment(Comments comment) async {
    if (!_isCommentOwner(comment)) {
      NotificationService.showError(
        'Vous ne pouvez supprimer que vos propres commentaires',
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Supprimer le commentaire',
                    style: const TextStyle(
                      color: Color(0xFF007A33),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer ce commentaire? Cette action est irréversible.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final commentDb = CommentDatabase();
                    await commentDb.deleteComment(comment.id!);
                    if (mounted) {
                      _loadUserComments();
                      Navigator.pop(context);
                      NotificationService.showSuccess(
                        'Commentaire supprimé avec succès!',
                      );
                    }
                  } catch (e) {
                    NotificationService.showError(
                      'Erreur lors de la suppression: ${e.toString()}',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _logout() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                const Icon(Icons.logout, color: Color(0xFF007A33), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Se déconnecter',
                    style: const TextStyle(
                      color: Color(0xFF007A33),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Êtes-vous sûr de vouloir vous déconnecter?',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final authService = Provider.of<AuthService>(
                      context,
                      listen: false,
                    );
                    debugPrint('🔓 Logging out from server...');
                    await authService.logoutFromServer();
                    debugPrint('🔓 Clearing local auth state...');
                    authService.logout();
                    if (mounted) {
                      debugPrint('🔓 Navigating back to Firstpage...');
                      // Use popUntil to go back to the main home page instead of creating a new LoginPage
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      NotificationService.showSuccess(
                        'Déconnecté avec succès!',
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      debugPrint('❌ Logout error: $e');
                      NotificationService.showError(
                        'Erreur lors de la déconnexion: ${e.toString()}',
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
