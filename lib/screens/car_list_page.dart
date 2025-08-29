import 'package:flutter/material.dart';
import '../services/car_service.dart';
import '../models/car.dart';
import '../screens/show_car.dart';
import 'add_edit_car_page.dart';

// تم تحويل الكلاس إلى StatefulWidget
class CarsListPageContent extends StatefulWidget {
  const CarsListPageContent({super.key});

  @override
  State<CarsListPageContent> createState() => _CarsListPageContentState();
}

class _CarsListPageContentState extends State<CarsListPageContent> {
  final CarService _carService = CarService();
  final TextEditingController _searchController = TextEditingController();
  List<Car> _allCars = [];
  List<Car> _filteredCars = [];

  @override
  void initState() {
    super.initState();
    // يستمع إلى التغييرات في حقل البحث
    _searchController.addListener(_filterCars);
  }

  @override
  void dispose() {
    // تنظيف المتحكم عند إغلاق الصفحة
    _searchController.dispose();
    super.dispose();
  }

  void _filterCars() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCars = _allCars.where((car) {
        return car.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // حقل البحث
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by car name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),

          // قائمة السيارات
          Expanded(
            child: Stack(
              children: [
                StreamBuilder<Result<List<Car>>>(
                  stream: _carService.getCars(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: Text("No cars found"));
                    }

                    final result = snapshot.data!;

                    if (result.hasError) {
                      return Center(child: Text("❌ Error: ${result.error}"));
                    }

                    final cars = result.data ?? [];

                    if (cars.isEmpty) {
                      return const Center(child: Text("No cars found"));
                    }
                    _allCars = cars;
                    if (_filteredCars.isEmpty &&
                        _searchController.text.isEmpty) {
                      _filteredCars = _allCars;
                    }

                    if (_filteredCars.isEmpty) {
                      return const Center(
                        child: Text("No matching cars found."),
                      );
                    }

                    return ListView.builder(
                      itemCount: _filteredCars.length,
                      itemBuilder: (context, index) {
                        final car = _filteredCars[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          child: ListTile(
                            leading:
                                car.imageUrl != null && car.imageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      car.imageUrl!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) =>
                                          const Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.directions_car,
                                    size: 40,
                                    color: Colors.grey,
                                  ),

                            title: Text(car.name),
                            subtitle: Text("${car.status}\n${car.model}"),
                            isThreeLine: true,

                            // هنا حدث الضغط
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ShowCar(car: car),
                                ),
                              );
                            },

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AddEditCarPage(car: car),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Confirm Delete"),
                                        content: Text(
                                          "Delete car ${car.name}?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await _carService.deleteCar(car.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEditCarPage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Result<T> {
  final T? data;
  final String? error;

  Result({this.data, this.error});

  bool get hasError => error != null;
}
