import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'package:uuid/uuid.dart';

class AddEditProductScreen extends StatefulWidget {
  const AddEditProductScreen({super.key});

  @override
  AddEditProductScreenState createState() => AddEditProductScreenState();
}

class AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  final _imagePicker = ImagePicker();
  File? _pickedImage;
  final _imageUrlController = TextEditingController();
  String? _base64Image;
  var _editedProduct = Product(
    id: '',
    name: '',
    description: '',
    price: 0,
    category: '',
    imageUrl: '',
  );

  static const categories = <String>[
    'Gadgets',
    'Food',
    'Fashion',
    'Home',
    'Books',
    'Other'
  ];
  final List<DropdownMenuItem<String>> _categories = categories
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value,
              style: const TextStyle(
                  //  color: Colors.red,
                  )),
        ),
      )
      .toList();

  String? selectedItem;

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String?;
      //  final product = ModalRoute.of(context)!.settings.arguments as Product?;
      if (productId != null) {
        _editedProduct = Provider.of<ProductProvider>(context, listen: false)
            .findById(productId);
      }
      /*if (product != null && _base64Image == null) {
        _base64Image = product.imageUrl;
      }
      if (_base64Image != null && _base64Image!.isNotEmpty) {
        final bytes = base64Decode(_base64Image!);
        setState(() {
          _pickedImage = File.fromRawPath(bytes);
        });
      }*/
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      // Convert the image file to base64 string
      final bytes = await _pickedImage!.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id != '') {
      await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      _editedProduct = Product(
        id: _uuid.v4(),
        name: _editedProduct.name,
        description: _editedProduct.description,
        price: _editedProduct.price,
        category: _editedProduct.category,
        imageUrl: _base64Image!,
      );
      await Provider.of<ProductProvider>(context, listen: false)
          .addProduct(_editedProduct);
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editedProduct.id == '' ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink.withOpacity(0.8),
              Colors.red.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _editedProduct.name,
                        decoration:
                            const InputDecoration(labelText: 'Product Name'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            name: value!,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            category: _editedProduct.category,
                            imageUrl: _base64Image ?? _editedProduct.imageUrl,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _editedProduct.price.toString(),
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a price.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number.';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a number greater than zero.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            name: _editedProduct.name,
                            description: _editedProduct.description,
                            price: double.parse(value!),
                            category: _editedProduct.category,
                            imageUrl: _base64Image ?? _editedProduct.imageUrl,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _editedProduct.description,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a description.';
                          }
                          if (value.length < 10) {
                            return 'Should be at least 10 characters long.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            name: _editedProduct.name,
                            description: value!,
                            price: _editedProduct.price,
                            category: _editedProduct.category,
                            imageUrl: _base64Image ?? _editedProduct.imageUrl,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField(
                        value: selectedItem,
                        hint: const Text(
                          'Category',
                          style: TextStyle(color: Colors.black45),
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(5.0), // Rounded corners
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please select a category.';
                          }
                          return null;
                        },
                        items: _categories,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedItem = newValue;
                            if (kDebugMode) {
                              print(selectedItem);
                            }
                          });
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            name: _editedProduct.name,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            category: value!,
                            imageUrl: _base64Image ?? _editedProduct.imageUrl,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _pickedImage != null
                                ? Image.file(
                                    _pickedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : _imageUrlController.text.isEmpty
                                    ? const Center(child: Text('Upload Image'))
                                    : Image.memory(
                                        _base64Image as Uint8List,
                                        fit: BoxFit.cover,
                                      ),
                          ),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration:
                                  const InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              onSaved: (value) {
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  name: _editedProduct.name,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imageUrl: value!,
                                  category: _editedProduct.category,
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.image),
                            onPressed: _pickImage,
                          ),
                        ],
                      ),
                      // Additional fields like category, image upload, etc.
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
