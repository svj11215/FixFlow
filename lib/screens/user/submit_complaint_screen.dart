import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/image_upload_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/image_picker_widget.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _adminIdController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;
  bool _isSuccess = false;

  // Motivation quotes
  final List<Map<String, String>> motivationQuotes = [
    {"quote": "The secret of getting ahead is getting started.", "author": "Mark Twain"},
    {"quote": "It always seems impossible until it's done.", "author": "Nelson Mandela"},
    {"quote": "Don't watch the clock; do what it does. Keep going.", "author": "Sam Levenson"},
    {"quote": "Act as if what you do makes a difference. It does.", "author": "William James"},
    {"quote": "Success is not final, failure is not fatal.", "author": "Winston Churchill"},
    {"quote": "Believe you can and you're halfway there.", "author": "Theodore Roosevelt"},
  ];

  late final PageController _pageController;
  int _currentQuoteIndex = 0;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startQuoteTimer();
  }

  void _startQuoteTimer() {
    _quoteTimer?.cancel();
    _quoteTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _pageController.hasClients) {
        final nextPage = (_currentQuoteIndex + 1) % motivationQuotes.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _nextQuote() {
    if (_pageController.hasClients) {
      final nextPage = (_currentQuoteIndex + 1) % motivationQuotes.length;
      _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
    _startQuoteTimer();
  }

  void _prevQuote() {
    if (_pageController.hasClients) {
      final prevPage = (_currentQuoteIndex - 1 + motivationQuotes.length) % motivationQuotes.length;
      _pageController.animateToPage(prevPage, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
    _startQuoteTimer();
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _adminIdController.dispose();
    super.dispose();
  }

  Widget _buildQuoteCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Large decorative quote glyph
          Positioned(
            top: 12,
            left: 16,
            child: Text(
              '\u201C',
              style: GoogleFonts.merriweather(
                fontSize: 48,
                color: Colors.white24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Navigation arrows
          Positioned(
            top: 12,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                  onPressed: _prevQuote,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white, size: 24),
                  onPressed: _nextQuote,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // PageView for quotes
          Padding(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 40),
            child: PageView.builder(
              controller: _pageController,
              itemCount: motivationQuotes.length,
              onPageChanged: (index) {
                setState(() => _currentQuoteIndex = index);
              },
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final quote = motivationQuotes[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '"${quote["quote"]!}"',
                      style: GoogleFonts.merriweather(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '— ${quote["author"]!}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Dot indicators
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                motivationQuotes.length,
                (index) {
                  final isActive = _currentQuoteIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20.0 : 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submit a Complaint',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fill in the details below to report an issue on campus.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        maxLength: 100,
                        decoration: _inputDecoration('Complaint Title', Icons.title),
                        validator: Validators.validateTitle,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLength: 500,
                        maxLines: 4,
                        decoration: _inputDecoration('Detailed Description', Icons.description),
                        validator: Validators.validateDescription,
                      ),
                      const SizedBox(height: 16),

                      // Category
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: _inputDecoration('Category', Icons.category_outlined),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                        items: AppCategories.categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppCategories.categoryColor(cat),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(cat, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCategory = value),
                        validator: Validators.validateCategory,
                      ),
                      const SizedBox(height: 16),

                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: _inputDecoration('Location (e.g., Room 101, Lib)', Icons.location_on_outlined),
                        validator: Validators.validateLocation,
                      ),
                      const SizedBox(height: 16),

                      // Admin ID
                      TextFormField(
                        controller: _adminIdController,
                        decoration: _inputDecoration('Admin ID (6 digits)', Icons.badge).copyWith(
                          suffixIcon: Tooltip(
                            message: 'Enter the 6-digit ID of the admin responsible for this area.',
                            child: Icon(Icons.info_outline, color: AppColors.textMuted, size: 20),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: Validators.validateAdminId,
                      ),
                      const SizedBox(height: 16),

                      // Image Picker
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Consumer<ImageUploadProvider>(
                          builder: (context, imageProvider, _) {
                            return ImagePickerWidget(
                              imageBytes: imageProvider.selectedImageBytes,
                              isUploading: imageProvider.isUploading,
                              onPick: () => imageProvider.pickImage(),
                              onClear: () => imageProvider.clearImage(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isSuccess
                                ? [AppColors.secondary, AppColors.secondary]
                                : [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (_isSuccess ? AppColors.secondary : const Color(0xFF1565C0)).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting || _isSuccess ? null : _submitComplaint,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                  )
                                : _isSuccess
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.check_circle, color: Colors.white, size: 24),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Submitted Successfully!',
                                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Submit Complaint',
                                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                          ),
                                        ],
                                      ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ]
                        .animate(interval: 50.ms)
                        .fade(duration: 300.ms)
                        .slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOut),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'DAILY MOTIVATION',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                _buildQuoteCard(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF1565C0), size: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF0F4FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AppAuthProvider>();
      final imageProvider = context.read<ImageUploadProvider>();
      final complaintProvider = context.read<ComplaintProvider>();

      String imageUrl = '';
      if (imageProvider.hasImage) {
        final uploadedUrl = await imageProvider.uploadToCloudinary();
        imageUrl = uploadedUrl ?? '';
      }

      final success = await complaintProvider.submitComplaint(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        location: _locationController.text.trim(),
        adminId: _adminIdController.text.trim(),
        userId: authProvider.currentUser!.uid,
        userName: authProvider.userModel?.name ??
            authProvider.currentUser!.displayName ??
            'User',
        imageUrl: imageUrl,
      );

      if (mounted) {
        if (success) {
          setState(() {
            _isSuccess = true;
            _isSubmitting = false;
          });
          
          imageProvider.clearImage();
          
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            _clearForm();
            setState(() => _isSuccess = false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  complaintProvider.error ?? 'Failed to submit complaint'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          setState(() => _isSubmitting = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _adminIdController.clear();
    setState(() => _selectedCategory = null);
    _formKey.currentState?.reset();
  }
}
