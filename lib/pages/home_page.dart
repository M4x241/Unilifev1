import 'package:flutter/material.dart';
import 'package:unilife/pages/carousel_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CarouselPage()),
            );
          },
          child: Image.asset(
            'assets/images/market_image.jpg',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anuncios TICS',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Bienvenidos a la sección de anuncios TICS. Aquí encontrarás información importante y actualizada.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
