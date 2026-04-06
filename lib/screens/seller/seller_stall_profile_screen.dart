import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/stall_model.dart';
import '../../services/stall_service.dart';
import '../../services/image_service.dart';

class SellerStallProfileScreen extends StatefulWidget {
  final StallModel? stall;
  final String ownerUid;

  const SellerStallProfileScreen({super.key, required this.stall, required this.ownerUid});

  @override
  State<SellerStallProfileScreen> createState() => _SellerStallProfileScreenState();
}

class _SellerStallProfileScreenState extends State<SellerStallProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _stallService = StallService();
  final _imageService = ImageService();

  String _selectedCategory = 'Makanan Berat';
  bool _isLoading = false;
  Uint8List? _pickedImageBytes; // Bytes gambar baru yang dipilih user
  String? _existingImageUrl;    // URL gambar lama dari Firestore

  final List<String> _categories = [
    'Makanan Berat', 'Minuman', 'Cemilan', 'Makanan Ringan', 'Kopi & Minuman Panas'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.stall != null) {
      final s = widget.stall!;
      _nameController.text = s.name;
      _descController.text = s.description;
      _locationController.text = s.location;
      _selectedCategory = s.category.isEmpty ? _categories[0] : s.category;
      _existingImageUrl = s.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await _imageService.pickImage();
      if (result != null && mounted) {
        setState(() => _pickedImageBytes = result.bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto "${result.name}" berhasil dipilih ✅'), backgroundColor: Colors.green),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada foto yang dipilih.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? imageUrl = _existingImageUrl;

      if (widget.stall == null) {
        // BARU: Buat stan dulu, lalu upload foto dengan ID yang didapat
        final newStall = await _stallService.createStall(
          ownerUid: widget.ownerUid,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          category: _selectedCategory,
          location: _locationController.text.trim(),
        );

        if (_pickedImageBytes != null) {
          imageUrl = await _imageService.uploadImage(
            imageBytes: _pickedImageBytes!,
            folder: 'stalls',
            fileName: newStall.id,
          );
          await _stallService.updateStall(newStall.id, {'imageUrl': imageUrl});
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stan berhasil didaftarkan! 🎉'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        // UPDATE: upload foto baru jika ada, lalu simpan semua data
        if (_pickedImageBytes != null) {
          imageUrl = await _imageService.uploadImage(
            imageBytes: _pickedImageBytes!,
            folder: 'stalls',
            fileName: widget.stall!.id,
          );
        }
        await _stallService.updateStall(widget.stall!.id, {
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'category': _selectedCategory,
          'location': _locationController.text.trim(),
          'imageUrl': imageUrl,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil stan berhasil diperbarui!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.stall == null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isNew ? 'Daftarkan Stan' : 'Edit Profil Stan',
          style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FOTO STAN ---
              _buildImagePicker(),
              const SizedBox(height: 28),

              _buildSectionLabel('Nama Stan'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'Contoh: Warung Mas Rusdi',
                icon: Icons.store_outlined,
                validator: (v) => v!.isEmpty ? 'Nama stan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Deskripsi'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descController,
                hint: 'Ceritakan sedikit tentang stanmu...',
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Lokasi Stan'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _locationController,
                hint: 'Contoh: Blok A No. 3',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Kategori Utama'),
              const SizedBox(height: 8),
              _buildCategoryDropdown(),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          isNew ? 'Daftarkan Stan' : 'Simpan Perubahan',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasImage = _pickedImageBytes != null || _existingImageUrl != null;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasImage ? Colors.transparent : Colors.grey.shade300,
            width: 2,
            style: hasImage ? BorderStyle.none : BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gambar
              if (_pickedImageBytes != null)
                Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
              else if (_existingImageUrl != null)
                Image.network(
                  _existingImageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryColor));
                  },
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                )
              else
                _buildImagePlaceholder(),

              // Overlay "Ganti Foto" di atas foto yang sudah ada
              if (hasImage)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Ganti Foto', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade400, size: 40),
        const SizedBox(height: 10),
        Text('Tambah Foto Stan',
            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('Tap untuk pilih dari galeri',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionLabel(String label) =>
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppTheme.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
          onChanged: (value) => setState(() => _selectedCategory = value!),
          items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
        ),
      ),
    );
  }
}
