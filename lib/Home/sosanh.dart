import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'test.dart';
import 'package:btl/detail/chitiet.dart';
import 'Compare.dart';
import 'package:btl/Home/Search.dart';
import 'package:btl/profile/canhan.dart';
class soanh extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchQueryChanged;
  final String username;

  soanh({
    required this.searchQuery,
    required this.onSearchQueryChanged,
    required this.username,
  });

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<soanh> {
  String _searchQuery = '';
  List<bool> _selectedList = [];

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.searchQuery;
  }

  Future<List<Product>> fetchSearchResults() async {
    final response = await http.get(Uri.parse('https://660d04c73a0766e85dbf4c43.mockapi.io/api/baiviet'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List<Product> products = data.map((item) => Product.fromJson(item)).toList();

      List<Product> filteredProducts = products.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      _selectedList = List<bool>.filled(filteredProducts.length, false);

      return filteredProducts;
    } else {
      throw Exception('Failed to load search results');
    }
  }

  Future<void> _updateSelection(bool selected, String productId, String username) async {
    try {
      final response = await http.get(Uri.parse('https://66516a3920f4f4c44277a923.mockapi.io/api/chonbai'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        List<Map<String, dynamic>> selectedProducts = data.cast<Map<String, dynamic>>()
            .where((item) => item['IDbaiviet'].toString() == productId && item['username'] == username)
            .toList();

        if (selectedProducts.isNotEmpty) {
          String itemId = selectedProducts[0]['id'];
          final deleteResponse = await http.delete(
            Uri.parse('https://66516a3920f4f4c44277a923.mockapi.io/api/chonbai/$itemId'),
          );

          if (deleteResponse.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã bỏ chọn')),
            );
            print('Product with ID $productId deleted successfully.');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete product with ID $productId.')),
            );
            print('Failed to delete product with ID $productId.');
          }
        } else {
          final postResponse = await http.post(
            Uri.parse('https://66516a3920f4f4c44277a923.mockapi.io/api/chonbai'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'chon': selected ? 1 : 0,
              'IDbaiviet': productId,
              'username': username,
            }),
          );

          if (postResponse.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã chọn')),
            );
            print('Product with ID $productId added successfully.');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add product with ID $productId.')),
            );
            print('Failed to add product with ID $productId.');
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch selected products from API.')),
        );
        print('Failed to fetch selected products from API.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product with ID $productId: $error')),
      );
      print('Error updating product with ID $productId: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              widget.onSearchQueryChanged(value);
            });
          },
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value;
              widget.onSearchQueryChanged(value);
            });
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.black),
            hintText: 'Search tech products',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompareScreen(username: widget.username,searchQuery: _searchQuery,),
                ),
              );
            },
            icon: Icon(Icons.compare),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: fetchSearchResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products available'));
          } else {
            List<Product> products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Adjust padding
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => chitietScreen(product: product, username: widget.username,searchQuery: widget.searchQuery,),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF0F0147), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        product.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_selectedList[index]) {
                                  _selectedList[index] = false;
                                  _updateSelection(false, product.id, widget.username);
                                } else {
                                  _selectedList[index] = true;
                                  _updateSelection(true, product.id, widget.username);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                              child: _selectedList[index]
                                  ? Icon(Icons.check_circle, color: Colors.blue)
                                  : Icon(Icons.circle_outlined, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare),
            label: 'Compare',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        showSelectedLabels: true, // Hiển thị nhãn cho các mục được chọn
        showUnselectedLabels: true, // Hiển thị nhãn cho các mục không được chọn
        selectedIconTheme: IconThemeData(color: Color(0xFF0F0147)), // Màu biểu tượng khi mục được chọn
        selectedLabelStyle: TextStyle(color: Color(0xFF0F0147)), // Màu nhãn khi mục được chọn
        unselectedIconTheme: IconThemeData(color: Color(0xFF0F0147)), // Màu biểu tượng khi mục không được chọn
        unselectedLabelStyle: TextStyle(color: Color(0xFF0F0147)), // Màu nhãn khi mục không được chọn
        selectedItemColor: Color(0xFF0F0147), // Màu của mục được chọn
        unselectedItemColor: Color(0xFF0F0147), // Màu của mục không được chọn
        onTap: (int index) {
          // Xử lý khi người dùng nhấn vào mỗi mục trong BottomNavigationBar
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(username: widget.username),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => soanh(
                    searchQuery: _searchQuery,
                    onSearchQueryChanged: (newQuery) {},
                    username: widget.username,
                  ),
                ),
              );
              break;

            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchQuery: _searchQuery,
                    onSearchQueryChanged: (newQuery) {},
                    username: widget.username,
                  ),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile1(username: widget.username),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}

