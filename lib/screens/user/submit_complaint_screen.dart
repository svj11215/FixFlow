import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Quotes data
  static const List<Map<String, String>> _quotes = [
    {
      "text": "Done is better than perfect.",
      "author": "— Mark Zuckerberg"
    },
    {
      "text": "Your complaint drives real change.",
      "author": "— FixFlow"
    },
    {
      "text": "Speak up. Be heard. Get results.",
      "author": "— FixFlow"
    },
    {
      "text": "Small reports lead to big improvements.",
      "author": "— FixFlow"
    },
    {
      "text": "Silence fixes nothing. Reporting does.",
      "author": "— FixFlow"
    },
    {
      "text": "Every issue reported is progress made.",
      "author": "— FixFlow"
    },
  ];

  int _currentQuoteIndex = 0;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _startQuoteTimer();
  }

  void _startQuoteTimer() {
    _quoteTimer?.cancel();
    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
        });
      }
    });
  }

  void _nextQuote() {
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
    });
    _startQuoteTimer(); // Reset timer on manual interaction
  }

  void _prevQuote() {
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex - 1 + _quotes.length) % _quotes.length;
    });
    _startQuoteTimer();
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _adminIdController.dispose();
    super.dispose();
  }

  Widget _buildQuoteCard(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      height: isMobile ? 130.0 : 120.0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.format_quote_rounded, color: Colors.white54, size: 28),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white70),
                    onPressed: _prevQuote,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white70),
                    onPressed: _nextQuote,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Column(
                key: ValueKey<int>(_currentQuoteIndex),
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '"${_quotes[_currentQuoteIndex]["text"]!}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(width: 20, height: 2, color: Colors.white54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _quotes[_currentQuoteIndex]["author"]!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _quotes.length,
              (index) {
                final isActive = _currentQuoteIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: isActive ? 16.0 : 6.0,
                  height: 6.0,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              },
            ),
          )
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Submit a Complaint',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Fill in the details below to report an issue on campus.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    _buildDecoratedField(
                      child: TextFormField(
                        controller: _titleController,
                        maxLength: 100,
                        decoration: _inputDecoration('Complaint Title', Icons.title),
                        validator: Validators.validateTitle,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildDecoratedField(
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLength: 500,
                        maxLines: 4,
                        decoration: _inputDecoration('Detailed Description', Icons.description),
                        validator: Validators.validateDescription,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category
                    _buildDecoratedField(
                      child: DropdownButtonFormField<String>(
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
                                Text(cat, style: const TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCategory = value),
                        validator: Validators.validateCategory,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location
                    _buildDecoratedField(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: _inputDecoration('Location (e.g., Room 101, Lib)', Icons.location_on_outlined),
                        validator: Validators.validateLocation,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Admin ID
                    _buildDecoratedField(
                      child: TextFormField(
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
                    ),
                    const SizedBox(height: 24),

                    // Image Picker - wrapped in card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                    const SizedBox(height: 32),

                    // Submit Button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isSuccess 
                              ? [AppColors.secondary, AppColors.secondary]
                              : [AppColors.gradientStart, AppColors.gradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_isSuccess ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.3),
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
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.white, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          'Submitted Successfully!',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ],
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Submit Complaint',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
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
              const Text(
                'DAILY MOTIVATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8), // AppColors.textSecondary ish
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
    );
  }

  Widget _buildDecoratedField({required Widget child}) {
    // Focus glow handler could be added via FocusNode but to keep it simple and declarative,
    // we use premium borders in _inputDecoration and a subtle persistent shadow.
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
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
