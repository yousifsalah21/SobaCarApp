import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/car_service.dart';
import '../models/car.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class AddEditCarPage extends StatefulWidget {
  final Car? car;

  const AddEditCarPage({super.key, this.car});

  @override
  State<AddEditCarPage> createState() => _AddEditCarPageState();
}

class _AddEditCarPageState extends State<AddEditCarPage> {
  final _formKey = GlobalKey<FormState>();
  final _carService = CarService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _modelController;

  String _status = "new"; // القيمة الافتراضية
  String _fuelType = "gasoline"; // القيمة الافتراضية

  // 👇 متغيرات خاصة بالصورة
  Uint8List? _selectedImageBytes; // للويب/الديسكتوب
  XFile? _selectedImageFile; // للموبايل

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.car != null ? widget.car!.name : "",
    );
    _descriptionController = TextEditingController(
      text: widget.car != null ? widget.car!.description : "",
    );
    _priceController = TextEditingController(
      text: widget.car != null ? widget.car!.price.toString() : "",
    );
    _modelController = TextEditingController(
      text: widget.car != null ? widget.car!.model.toString() : "",
    );
    _status = widget.car != null ? widget.car!.status : "new";
    _fuelType = widget.car != null ? widget.car!.fuelType : "gasoline";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _saveCar() async {
    if (_formKey.currentState!.validate()) {
      // ✨ أولاً ارفع الصورة لو موجودة
      String? imageUrl;
      if (_selectedImageBytes != null || _selectedImageFile != null) {
        imageUrl = await _uploadImage();
      }

      final car = Car(
        id: widget.car?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        status: _status,
        model: int.tryParse(_modelController.text.trim()) ?? 0,
        fuelType: _fuelType,
        imageUrl:
            imageUrl ??
            widget.car?.imageUrl, // لو ما في صورة جديدة، خلي القديمة
      );

      if (widget.car == null) {
        await _carService.createCar(car, context);
      } else {
        await _carService.updateCar(car.id!, car.toMap());
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// 📌 دالة اختيار الصورة (موبايل + ويب)
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        // في الويب نقرأ الصورة كـ Bytes
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageFile = null; // نلغي أي ملف قديم
        });
      } else {
        // في الموبايل نخزن الملف مباشرة
        setState(() {
          _selectedImageFile = image;
          _selectedImageBytes = null; // نلغي أي bytes قديمة
        });
      }
    }
  }

  /// 📌 Widget لعرض الصورة المختارة أو القديمة
  Widget _buildImagePreview() {
    if (_selectedImageBytes != null) {
      return Image.memory(_selectedImageBytes!, height: 150, fit: BoxFit.cover);
    } else if (_selectedImageFile != null) {
      return Image.file(
        File(_selectedImageFile!.path),
        height: 150,
        fit: BoxFit.cover,
      );
    } else if (widget.car != null && widget.car!.imageUrl != null) {
      // ✨ عرض الصورة القديمة من Supabase
      return Image.network(
        widget.car!.imageUrl!,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 100, color: Colors.red),
      );
    } else {
      return const Icon(Icons.image, size: 100, color: Colors.grey);
    }
  }

  Future<String?> _uploadImage() async {
    final supabase = Supabase.instance.client;
    final bucket = supabase.storage.from('cars');

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (kIsWeb && _selectedImageBytes != null) {
        await bucket.uploadBinary(
          fileName,
          _selectedImageBytes!,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
      } else if (_selectedImageFile != null) {
        await bucket.upload(
          fileName,
          File(_selectedImageFile!.path),
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
      } else {
        return null; // ما في صورة
      }

      // نجيب رابط عام
      final publicUrl = bucket.getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  /////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.car == null ? "Add car" : "Edit car")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter name" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter description" : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter price" : null,
              ),
              const SizedBox(height: 10),
              // Dropdown للحالة  
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: "Status"),
                items: const [
                  DropdownMenuItem(value: "new", child: Text("New")),
                  DropdownMenuItem(value: "used", child: Text("Used")),
                  DropdownMenuItem(value: "crashed", child: Text("crashed"))
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: "Model"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter model" : null,
              ),
              const SizedBox(height: 10),
              // Dropdown لنوع الوقود
              DropdownButtonFormField<String>(
                value: _fuelType,
                decoration: const InputDecoration(labelText: "Fuel Type"),
                items: const [
                  DropdownMenuItem(value: "gasoline", child: Text("Gasoline")),
                  DropdownMenuItem(value: "diesel", child: Text("Diesel")),
                  DropdownMenuItem(value: "electric", child: Text("Electric")),
                ],
                onChanged: (value) {
                  setState(() {
                    _fuelType = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // ✅ Container قابل للنقر أو Drag & Drop
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: _buildImagePreview()),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveCar,
                child: Text(widget.car == null ? "Add" : "Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
