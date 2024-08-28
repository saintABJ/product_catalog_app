import 'package:flutter/material.dart';
import 'package:product_catalog_app/providers/product_provider.dart';
import 'package:product_catalog_app/screens/add_edit_product_screen.dart';
import 'package:product_catalog_app/screens/home_screen.dart';
import 'package:product_catalog_app/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => ProductProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Product Catalog',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
        routes: {
          '/product-detail': (ctx) => const ProductDetailScreen(),
          '/add-product': (ctx) => const AddEditProductScreen(),
        },
      ),
    );
  }
}
