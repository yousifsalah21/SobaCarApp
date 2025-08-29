import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car.dart';
import '../screens/car_list_page.dart';

final supabase = Supabase.instance.client;

class CarService {
  final String tableName = 'cars';

  Future<void> createCar(Car car, BuildContext context) async {
    try {
      final data = car.toMap();
      await supabase.from(tableName).insert(data);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Car saved succesfuly✅"))
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CarsListPageContent()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌saving car failed: $e"))
        );
      }
    }
  }

  Stream<Result<List<Car>>> getCars() {
    return supabase.from(tableName).stream(primaryKey: ['id']).map((records) {
      try {
        final cars = records
            .map((record) => Car.fromSupabase(record))
            .toList();
        return Result(data: cars);
      } catch (e) {
        return Result(error: e.toString());
      }
    });
  }

  Future<void> updateCar(int id, Map<String, dynamic> data) async {
    await supabase.from(tableName).update(data).eq('id', id);
  }

  Future<void> deleteCar(int id) async {
    await supabase.from(tableName).delete().eq('id', id);
  }
}
