import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../services/cloudinary_service.dart';

class ImageUploadProvider extends ChangeNotifier {
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Uint8List? _selectedImageBytes;
  bool _isUploading = false;
  String? _error;

  Uint8List? get selectedImageBytes => _selectedImageBytes;
  bool get isUploading => _isUploading;
  String? get error => _error;
  bool get hasImage => _selectedImageBytes != null;

  Future<void> pickImage() async {
    try {
      _error = null;
      final imageBytes = await ImagePickerWeb.getImageAsBytes();
      if (imageBytes != null) {
        _selectedImageBytes = imageBytes;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String?> uploadToCloudinary() async {
    if (_selectedImageBytes == null) return null;

    try {
      _isUploading = true;
      _error = null;
      notifyListeners();

      final url = await _cloudinaryService.uploadImage(_selectedImageBytes!);

      _isUploading = false;
      notifyListeners();
      return url;
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }

  void clearImage() {
    _selectedImageBytes = null;
    _error = null;
    notifyListeners();
  }
}
