import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/providers/user_provider.dart';
import 'package:orbitapp/services/firestore_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  File? _pickedImage;
  bool _isSaving = false;
  String? _error;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Populate fields once the provider data arrives
  void _init(String name) {
    if (!_initialized) {
      _initialized = true;
      _nameController.text = name;
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked == null) return;
      setState(() => _pickedImage = File(picked.path));
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      // Get UID from Firebase Auth — always available even if Firestore is slow
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final uid = firebaseUser?.uid;
      if (uid == null) throw Exception('Not signed in');

      String? newPhotoUrl;

      // Upload photo to Storage if user picked one
      if (_pickedImage != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('users/$uid/avatar.jpg');
        await storageRef.putFile(_pickedImage!);
        newPhotoUrl = await storageRef.getDownloadURL();
        // Update Firebase Auth profile — wrapped so SSL issues don't block save
        try {
          await firebaseUser?.updatePhotoURL(newPhotoUrl);
        } catch (_) {}
      }

      final newName = _nameController.text.trim();

      // Update Firebase Auth display name — wrapped so SSL issues don't block save
      try {
        await firebaseUser?.updateDisplayName(newName);
      } catch (_) {}

      // Firestore is the source of truth for the app — always update this
      final fields = <String, dynamic>{'displayName': newName};
      if (newPhotoUrl != null) fields['photoUrl'] = newPhotoUrl;
      await FirestoreService.instance.updateUser(uid, fields);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated'),
            backgroundColor: AppColors.kSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _error = 'Failed to save. Please check your connection.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    // Resolve name + email from Firestore first, fall back to Firebase Auth
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final firestoreUser = userAsync.valueOrNull;

    final fsName = firestoreUser?.displayName ?? '';
    final name = fsName.isNotEmpty ? fsName : (firebaseUser?.displayName ?? '');

    final fsEmail = firestoreUser?.email ?? '';
    final email = fsEmail.isNotEmpty ? fsEmail : (firebaseUser?.email ?? '');

    final photoUrl = firestoreUser?.photoUrl?.isNotEmpty == true
        ? firestoreUser!.photoUrl
        : firebaseUser?.photoURL;

    _init(name);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.kTextPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Profile', style: AppTextStyles.headingSmall),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.kPrimary),
                  )
                : TextButton(
                    onPressed: _save,
                    child: Text('Save',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.kPrimary)),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar picker ─────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _buildAvatar(photoUrl, name),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.kPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.kBackground, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text('Change photo',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.kPrimary)),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Name ──────────────────────────────────────────────────
              _FieldLabel('Display Name'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nameController,
                style: AppTextStyles.bodyMedium,
                textCapitalization: TextCapitalization.words,
                decoration: _fieldDecor(
                    hint: 'Your name',
                    icon: Icons.person_outline_rounded),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Name cannot be empty';
                  }
                  if (v.trim().length < 2) return 'At least 2 characters';
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Email (read-only) ─────────────────────────────────────
              _FieldLabel('Email address'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                initialValue: email,
                readOnly: true,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.kTextSecondary),
                decoration: _fieldDecor(
                  hint: 'Email',
                  icon: Icons.email_outlined,
                ).copyWith(
                  suffixIcon: const Icon(Icons.lock_outline_rounded,
                      size: 16, color: AppColors.kTextDisabled),
                ),
              ),

              // ── Error ─────────────────────────────────────────────────
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.kErrorContainer,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                        color: AppColors.kError.withValues(alpha: 0.3)),
                  ),
                  child: Text(_error!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.kError)),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // ── Save ──────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.kGradientPrimary,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isSaving ? null : _save,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text('Save changes',
                                style: AppTextStyles.labelLarge
                                    .copyWith(color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? url, String name) {
    const r = 52.0;
    if (_pickedImage != null) {
      return CircleAvatar(radius: r, backgroundImage: FileImage(_pickedImage!));
    }
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: r,
        backgroundImage: CachedNetworkImageProvider(url),
        backgroundColor: AppColors.kSurfaceVariant,
      );
    }
    final parts = name.trim().split(' ');
    final initials = parts.isEmpty || parts.first.isEmpty
        ? '?'
        : parts.length == 1
            ? parts.first[0].toUpperCase()
            : (parts.first[0] + parts.last[0]).toUpperCase();
    return CircleAvatar(
      radius: r,
      backgroundColor: AppColors.kPrimaryContainer,
      child: Text(initials,
          style:
              AppTextStyles.displayMedium.copyWith(color: AppColors.kPrimary)),
    );
  }

  InputDecoration _fieldDecor(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium
          .copyWith(color: AppColors.kTextDisabled),
      prefixIcon: Icon(icon, size: 20, color: AppColors.kTextSecondary),
      filled: true,
      fillColor: AppColors.kSurface,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide:
            const BorderSide(color: AppColors.kPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.kError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide:
            const BorderSide(color: AppColors.kError, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.labelMedium
            .copyWith(color: AppColors.kTextSecondary),
      );
}
