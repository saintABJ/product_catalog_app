import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:product_catalog_app/models/product.dart';

class ProductItem extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;
  final Product product;

  const ProductItem(this.id, this.name, this.imageUrl, this.product, {super.key});

  @override
  Widget build(BuildContext context) {

    final imageBytes = base64Decode(product.imageUrl);

    return GridTile(
      footer: GridTileBar(
        backgroundColor: Colors.black87,
        title: Text(
          name,
          textAlign: TextAlign.center,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/product-detail',
            arguments: id,
          );
        },
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
