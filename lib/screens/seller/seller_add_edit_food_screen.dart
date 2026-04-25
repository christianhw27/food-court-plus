import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/food_model.dart';
import '../../services/stall_service.dart';
import '../../services/image_service.dart';
import '../../core/app_notification.dart';

class SellerAddEditFoodScreen extends StatefulWidget {
  final String stallId;
  final FoodModel? food;

  const SellerAddEditFoodScreen({super.key, required this.stallId, required this.food});

  @override
  State<SellerAddEditFoodScreen> createState() => _SellerAddEditFoodScreenState();
}

class _SellerAddEditFoodScreenState extends State<SellerAddEditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stallService = StallService();
  final _imageService = ImageService();

  String _selectedCategory = 'Makanan Berat';
  bool _isAvailable = true;
  bool _isLoading = false;
  Uint8List? _pickedImageBytes;
  String? _existingImageUrl;

  final List<String> _categories = [
    'Makanan Berat', 'Minuman', 'Cemilan', 'Makanan Ringan', 'Kopi & Minuman Panas'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.food != null) {
      final f = widget.food!;
      _nameController.text = f.name;
      _descController.text = f.description;
      _priceController.text = f.price.toStringAsFixed(0);
      _selectedCategory = f.category.isEmpty ? _categories[0] : f.category;
      _isAvailable = f.isAvailable;
      _existingImageUrl = f.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await _imageService.pickImage();
      if (result != null && mounted) {
        setState(() => _pickedImageBytes = result.bytes);
        AppNotification.showSuccess(context, 'Foto "${result.name}" berhasil dipilih ✅');
      } else if (mounted) {
        AppNotification.showSuccess(context, 'Tidak ada foto yang dipilih.');
      }
    } catch (e) {
      if (mounted) {
        AppNotification.showSuccess(context, 'Gagal memilih foto: $e');
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final price = double.tryParse(_priceController.text.replaceAll(',', '').replaceAll('.', '')) ?? 0;
      String? imageUrl = _existingImageUrl;

      if (widget.food == null) {
        // TAMBAH BARU: simpan dulu tanpa foto, lalu upload foto dengan ID baru
        final newFood = FoodModel(
          id: '',
          stallId: widget.stallId,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: price,
          category: _selectedCategory,
          isAvailable: _isAvailable,
          imageUrl: null,
        );
        final newFoodId = await _stallService.addFood(newFood);

        // Upload foto lalu update dokumen dengan imageUrl
        if (_pickedImageBytes != null) {
          imageUrl = await _imageService.uploadImage(
            imageBytes: _pickedImageBytes!,
            folder: 'foods',
            fileName: newFoodId,
          );
          await _stallService.updateFood(newFoodId, {'imageUrl': imageUrl});
        }

        if (mounted) {
          AppNotification.showSuccess(context, 'Menu berhasil ditambahkan! 🎉');
          Navigator.pop(context);
        }
      } else {
        // UPDATE: upload foto baru jika ada
        if (_pickedImageBytes != null) {
          imageUrl = await _imageService.uploadImage(
            imageBytes: _pickedImageBytes!,
            folder: 'foods',
            fileName: widget.food!.id,
          );
        }
        await _stallService.updateFood(widget.food!.id, {
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'price': price,
          'category': _selectedCategory,
          'isAvailable': _isAvailable,
          'imageUrl': imageUrl,
        });
        if (mounted) {
          AppNotification.showSuccess(context, 'Menu berhasil diperbarui!');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        AppNotification.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.food == null;

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
          isNew ? 'Tambah Menu' : 'Edit Menu',
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
              // --- FOTO MENU ---
              _buildImagePicker(),
              const SizedBox(height: 28),

              _buildLabel('Nama Menu'),
              const SizedBox(height: 8),
              _buildField(
                controller: _nameController,
                hint: 'Contoh: Ayam Geprek Pedas',
                icon: Icons.fastfood_outlined,
                validator: (v) => v!.isEmpty ? 'Nama menu tidak boleh kosong' : null,
              ),
              const SizedBox(height: 18),

              _buildLabel('Deskripsi'),
              const SizedBox(height: 8),
              _buildField(
                controller: _descController,
                hint: 'Deskripsikan menu kamu...',
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 18),

              _buildLabel('Harga (Rp)'),
              const SizedBox(height: 8),
              _buildField(
                controller: _priceController,
                hint: 'Contoh: 15000',
                icon: Icons.attach_money_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Harga tidak boleh kosong';
                  if (double.tryParse(v) == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              _buildLabel('Kategori'),
              const SizedBox(height: 8),
              Container(
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
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Toggle tersedia
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.grey),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Tersedia untuk dibeli',
                          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500)),
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: (v) => setState(() => _isAvailable = v),
                      activeTrackColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
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
                          isNew ? 'Tambah Menu' : 'Simpan Perubahan',
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
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasImage ? Colors.transparent : Colors.grey.shade300,
            width: hasImage ? 0 : 2,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_pickedImageBytes != null)
                Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
              else if (_existingImageUrl != null)
                Image.network(
                  _existingImageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryColor));
                  },
                  errorBuilder: (_, __, ___) => _photoPlaceholder(),
                )
              else
                _photoPlaceholder(),

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

  Widget _photoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade400, size: 48),
        const SizedBox(height: 10),
        Text('Tambah Foto Menu',
            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500, fontSize: 15)),
        const SizedBox(height: 4),
        Text('Tap untuk pilih dari galeri',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
      ],
    );
  }

  Widget _buildLabel(String text) =>
      Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark));

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
}
