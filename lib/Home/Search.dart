import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'test.dart';
import 'package:btl/detail/chitiet.dart';
import 'package:btl/profile/canhan.dart';
import 'package:btl/Home/sosanh.dart';

class SearchScreen extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchQueryChanged;
  final String username; // Thêm biến username vào đây

  SearchScreen({required this.searchQuery, required this.onSearchQueryChanged, required this.username}); // Cập nhật constructor để nhận giá trị username

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';

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

      return filteredProducts;
    } else {
      throw Exception('Failed to load search results');
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
            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: products.map((product) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => chitietScreen(product: product, username: widget.username,searchQuery: widget.searchQuery,),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF0F0147), width: 2),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      product.description,
                                      style: TextStyle(fontSize: 14),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
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
