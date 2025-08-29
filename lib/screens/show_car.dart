import 'package:flutter/material.dart';
import '../models/car.dart';

class ShowCar extends StatelessWidget {
  final Car car;

  const ShowCar({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(car.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة السيارة
            Center(
              child: car.imageUrl != null && car.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        car.imageUrl!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.directions_car,
                      size: 150, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Text("Name: ${car.name}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Model: ${car.model}"),
            Text("Status: ${car.status}"),
            Text("Price: ${car.price}"),
            Text("Fuel Type: ${car.fuelType}"),
            const SizedBox(height: 10),
            Text("Description: ${car.description}"),
          ],
        ),
      ),
    );
  }
}
