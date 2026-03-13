import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class CloudinaryService {
  Future<String?> uploadImage(Uint8List imageBytes) async {
    try {
      final uri = Uri.parse(CloudinaryConfig.uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'complaint_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final jsonData = json.decode(responseData.body);
        return jsonData['secure_url'];
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }
}
