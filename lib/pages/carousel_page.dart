import 'package:flutter/material.dart';

class CarouselPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles del Mercado')),
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
              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    height: 100,
                    width: 100,
                    color: Colors.grey[300], // Placeholder for image
                    child: Image.asset(imagePaths[index], fit: BoxFit.cover),
                  ),
                  SizedBox(height: 8),
                  Text('Precio: \$${(index + 1) * 10}'),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
