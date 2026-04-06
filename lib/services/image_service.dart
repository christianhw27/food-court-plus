import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ============================================================
// KONFIGURASI CLOUDINARY
// ============================================================
const _cloudName = 'dli0ekmig';
const _uploadPreset = 'foodcourtplus_preset';
// ============================================================

/// Hasil dari pilih gambar
class PickedImageResult {
  final Uint8List bytes;
  final String name;

  PickedImageResult({required this.bytes, required this.name});
}

class ImageService {
  /// Buka file picker dan minta user pilih gambar.
  /// Compatible dengan Web (Chrome/Edge), Android, iOS, Windows, MacOS.
  Future<PickedImageResult?> pickImage() async {
    try {
      debugPrint('[ImageService] Membuka dialog pilih foto...');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // WAJIB untuk web
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('[ImageService] User batal memilih foto.');
        return null;
      }

      final file = result.files.single;
      final bytes = file.bytes;

      debugPrint(
        '[ImageService] File dipilih: ${file.name} (${file.size} bytes)',
      );

      if (bytes == null || bytes.isEmpty) {
        debugPrint('[ImageService] ERROR: bytes null!');
        return null;
      }

      return PickedImageResult(bytes: bytes, name: file.name);
    } catch (e, st) {
      debugPrint('[ImageService] EXCEPTION pickImage: $e\n$st');
      rethrow;
    }
  }

  /// Upload gambar ke Cloudinary dan return URL publik.
  /// [folder]: subfolder di Cloudinary, e.g. 'stalls' atau 'foods'
  /// [fileName]: nama file/public_id unik
  Future<String> uploadImage({
    required Uint8List imageBytes,
    required String folder,
    required String fileName,
  }) async {
    debugPrint('[ImageService] Upload ke Cloudinary: $folder/$fileName...');

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] =
          folder // folder terpisah dari public_id
      ..fields['public_id'] =
          fileName // hanya nama file, tanpa slash
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: '$fileName.jpg',
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('[ImageService] Response status: ${response.statusCode}');
    debugPrint('[ImageService] Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Upload gagal (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final url = data['secure_url'] as String;

    debugPrint('[ImageService] Upload sukses! URL: $url');
    return url;
  }

  /// Hapus gambar dari Cloudinary (opsional, butuh API key untuk delete)
  /// Untuk development, bisa diabaikan.
  Future<void> deleteImage(String imageUrl) async {
    // Cloudinary delete membutuhkan signature (tidak bisa unsigned)
    // Untuk sementara dibiarkan kosong — gambar lama akan tertimpa
    // jika public_id sama, atau tetap ada jika public_id beda.
    debugPrint(
      '[ImageService] deleteImage: skip (Cloudinary unsigned tidak support delete)',
    );
  }
}
