import 'package:flutter/material.dart';

class StorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Store')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Logic for "Mis Productos"
                },
                child: Text('Mis Productos'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Logic for "Mis Compras"
                },
                child: Text('Mis Compras'),
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300], // Placeholder for image
                      child: Icon(Icons.image, size: 50),
                    ),
                    SizedBox(height: 8),
                    Text('Precio: \$${(index + 1) * 10}'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
