import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildCarousel('Comida', [
                  'assets/food1.jpg',
                  'assets/food2.jpg',
                  'assets/food3.jpg',
                ]),
                _buildCarousel('Bebidas', [
                  'assets/drink1.jpg',
                  'assets/drink2.jpg',
                  'assets/drink3.jpg',
                ]),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Implementar lógica para listar
                },
                child: Text('Listar'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implementar lógica para reservar
                },
                child: Text('Reservar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(String title, List<String> imagePaths) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(imagePaths[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
