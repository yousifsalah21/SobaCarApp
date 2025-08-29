class Car {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String status;
  final int model;
  final String fuelType;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Car({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
    required this.model,
    required this.fuelType,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Car.fromSupabase(Map<String, dynamic> data) {
    return Car(
      id: data['id'] as int?,
      name: data['name'] as String,
      description: data['description'] as String,
      price: (data['price'] as num).toDouble(),
      status: data['status'] as String,
      model: data['model'] as int,
      fuelType: data['fuelType'] as String,
      imageUrl: data['imageUrl'] as String?,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'status': status,
      'model': model,
      'fuelType': fuelType,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Car copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? status,
    int? model,
    String? fuelType,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Car(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      status: status ?? this.status,
      model: model ?? this.model,
      fuelType: fuelType ?? this.fuelType,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
