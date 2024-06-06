import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'test.dart';
import 'package:btl/Home/sosanh.dart';
import 'package:btl/Home/Search.dart';
import 'package:btl/profile/canhan.dart';
class CompareScreen extends StatefulWidget {
  final String username;
  final String searchQuery;

  CompareScreen({required this.username,required this.searchQuery});

  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  late Future<List<Product>> _futureSearchResults;

  @override
  void initState() {
    super.initState();
    _futureSearchResults = fetchSearchResults();
  }

  Future<List<Product>> fetchSearchResults() async {
    final response = await http.get(Uri.parse('https://660d04c73a0766e85dbf4c43.mockapi.io/api/baiviet'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<Product> products = data.map((item) => Product.fromJson(item)).toList();

      final selectedItemsResponse = await http.get(Uri.parse('https://665ff1345425580055b16f30.mockapi.io/api/yeutich'));
      if (selectedItemsResponse.statusCode == 200) {
        final List<dynamic> selectedItemsData = jsonDecode(selectedItemsResponse.body);

        List<Product> filteredProducts = [];

        for (var product in products) {
          if (selectedItemsData.any((item) => item['IDbaiviet'] == product.id && item['username'] == widget.username)) {
            filteredProducts.add(product);
          }
        }

        return filteredProducts;
      } else {
        throw Exception('Failed to load selected items');
      }
    } else {
      throw Exception('Failed to load search results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('So sánh'),
      ),
      body: FutureBuilder<List<Product>>(
        future: _futureSearchResults,
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
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      // Define your logic here if you want to navigate or do something on tap
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFF0F0147), width: 2),
                            color: Colors.white, // Thêm màu nền trắng
                            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4, offset: Offset(0,2))] // Thêm shadow
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
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
            icon: Icon(Icons.favorite),
            label: 'Favorite',
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
        selectedIconTheme: IconThemeData(color: Colors.grey), // Màu biểu tượng khi mục được chọn
        selectedLabelStyle: TextStyle(color: Colors.grey), // Màu nhãn khi mục được chọn
        unselectedIconTheme: IconThemeData(color: Colors.grey), // Màu biểu tượng khi mục không được chọn
        unselectedLabelStyle: TextStyle(color: Colors.grey), // Màu nhãn khi mục không được chọn
        selectedItemColor: Colors.grey, // Màu của mục được chọn
        unselectedItemColor: Colors.grey, // Màu của mục không được chọn
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
                    searchQuery: widget.searchQuery,
                    onSearchQueryChanged: (newQuery) {},
                    username: widget.username,
                  ),
                ),
              );
              break;
            case 2:
            // Xử lý khi người dùng nhấn vào mục thứ hai
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    searchQuery: widget.searchQuery,
                    onSearchQueryChanged: (newQuery) {},
                    username: widget.username,
                  ),
                ),
              );
              break;
            case 4:
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


