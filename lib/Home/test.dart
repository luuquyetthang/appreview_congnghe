import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert'; // To parse JSON
import 'package:http/http.dart' as http;
import 'package:btl/detail/chitiet.dart';
import 'package:btl/profile/canhan.dart';
import 'Search.dart';
import 'sosanh.dart';

class Home extends StatelessWidget {
  final String username;

  Home({required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: TechReviewScreen(username: username), // Truyền tên người dùng vào TechReviewScreen
    );
  }
}

class TechReviewScreen extends StatefulWidget {
  final String username; // Tham số để nhận tên người dùng

  TechReviewScreen({required this.username}); // Constructor để nhận tên người dùng

  @override
  _TechReviewScreenState createState() => _TechReviewScreenState();
}

class _TechReviewScreenState extends State<TechReviewScreen> {
  String _searchQuery = '';
  int _selectedChipIndex = -1;
  List<String> searchHistory = [];
  List<String> _chipLabels = ['All', 'Smartphones', 'Laptops', 'Accessories'];

  Future<void> _updateSelection(bool selected, String productId, String username) async {
    try {
      final response = await http.get(Uri.parse('https://665ff1345425580055b16f30.mockapi.io/api/yeutich'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
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
              SnackBar(content: Text('Đã bỏ thích')),
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
              SnackBar(content: Text('Đã thích')),
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
        backgroundColor: Color(0xFF0F0147),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.home, color:Colors.grey[200]),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.grey[200]),
            onPressed: () {},
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${widget.username} 👋',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    searchHistory.add(value);
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Color(0xFF0F0147)),
                  hintText: 'Search tech products',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_chipLabels.length, (index) {
                    return Row(
                      children: [
                        ChoiceChip(
                          label: Text(
                            _chipLabels[index],
                            style: TextStyle(
                              fontWeight: _selectedChipIndex == index ? FontWeight.bold : FontWeight.normal, // In đậm khi được chọn
                            ),
                          ),
                          selected: _selectedChipIndex == index,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedChipIndex = selected ? index : -1;
                            });
                          },
                        ),
                        SizedBox(width: 8), // Khoảng cách ở đây
                      ],
                    );
                  }),
                ),

              ),

              SizedBox(height: 16),
              Container(
                height: 200,
                child: FutureBuilder<List<Product>>(
                  future: fetchTechProducts(), // Fetch data from mock API
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No products available'));
                    } else {
                      List<Product> products = snapshot.data!;
                      List<Product> filteredProducts = products.where((product) {
                        bool matchesSearchQuery = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
                        bool matchesCategory = _selectedChipIndex == -1 || _chipLabels[_selectedChipIndex] == 'All' || product.Them == _chipLabels[_selectedChipIndex];
                        return matchesSearchQuery && matchesCategory;
                      }).toList();
                      List<Product> loopedProducts = List.from(filteredProducts)..addAll(filteredProducts);

                      // Create a PageController to control the scrolling
                      PageController controller = PageController();

                      // Function to scroll to the next item
                      void nextPage() {
                        if (controller.page! < loopedProducts.length - 1) {
                          controller.nextPage(duration: Duration(seconds: 1), curve: Curves.ease);
                        } else {
                          controller.jumpToPage(0); // Jump back to the first page
                        }
                      }

                      // Start scrolling loop
                      Timer.periodic(Duration(seconds: 3), (timer) {
                        nextPage();
                      });

                      return GestureDetector(
                        onHorizontalDragEnd: (details) {
                          // Calculate the direction of the swipe
                          if (details.primaryVelocity! < 0) {
                            // Swipe left
                            nextPage();
                          } else if (details.primaryVelocity! > 0) {
                            // Swipe right
                            if (controller.page! > 0) {
                              controller.previousPage(duration: Duration(seconds: 1), curve: Curves.ease);
                            } else {
                              controller.jumpToPage(loopedProducts.length - 1); // Jump to the last page
                            }
                          }
                        },
                        child: PageView.builder(
                          controller: controller,
                          itemCount: loopedProducts.length,
                          itemBuilder: (context, index) {
                            // Calculate the actual index based on the loopedProducts list
                            int actualIndex = index % filteredProducts.length;
                            return TechProductCard(
                              id: loopedProducts[index].id,
                              Them: loopedProducts[index].Them,
                              imageUrl: loopedProducts[index].imageUrl,
                              name: loopedProducts[index].name,
                              description: loopedProducts[index].description,
                              username: widget.username,
                              saoTB: loopedProducts[index].saoTB,
                              searchQuery: _searchQuery,
                              nguongoc: loopedProducts[index].nguongoc,
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently Reviewed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('See All'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              FutureBuilder<List<Product>>(
                future: fetchTechProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No products available'));
                  } else {
                    List<Product> products = snapshot.data!;
                    List<Product> filteredProducts = products.where((product) {
                      bool matchesSearchQuery = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
                      bool matchesCategory = _selectedChipIndex == -1 || _chipLabels[_selectedChipIndex] == 'All' || product.Them == _chipLabels[_selectedChipIndex];
                      return matchesSearchQuery && matchesCategory;
                    }).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: filteredProducts.map((product) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => chitietScreen(product: product, username: widget.username,searchQuery: _searchQuery,),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Material(
                                elevation: 4, // Độ nổi của box
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5), // Màu của bóng đổ
                                        spreadRadius: 3, // Bán kính mà bóng đổ lan ra
                                        blurRadius: 7, // Độ mờ của bóng đổ
                                        offset: Offset(0, 3), // Độ dịch chuyển của bóng đổ
                                      ),
                                    ],
                                    border: Border.all(color: Color(0xFF0F0147), width: 2), // Add border
                                    color: Colors.white, // Màu nền của box
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 110,
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
                                                  fontSize: 18,
                                                  color: Color(0xFF0F0147), // Màu chữ
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                product.description,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF0F0147), // Màu chữ
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8),
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: Colors.yellow), // Màu viền

                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      product.saoTB,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.yellow, // Màu chữ
                                                      ),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors.yellow, // Màu chữ
                                                      size: 18,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
            ],
          ),
        ),
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

class TechProductCard extends StatelessWidget {
  final String username;
  final String imageUrl;
  final String name;
  final String description;
  final String id;
  final String Them;
  final String saoTB;
  final String searchQuery;
  final String nguongoc;

  TechProductCard({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.username,
    required this.id,
    required this.Them,
    required this.saoTB,
    required this.searchQuery,
    required this.nguongoc
  });

  @override
  Widget build(BuildContext context) {
    void navigateToProfileScreen(BuildContext context, String searchQuery) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => chitietScreen(
            product: Product(
              id: id,
              imageUrl: imageUrl,
              name: name,
              description: description,
              Them: Them,
              saoTB: saoTB,
              nguongoc: nguongoc
            ),
            searchQuery: searchQuery,
            username: username,
          ),
        ),
      );
    }


    double getStarRating(String rating) {
      try {
        return double.parse(rating);
      } catch (e) {
        return 0; // Mặc định là 0 nếu chuyển đổi thất bại
      }
    }

    return GestureDetector(
      onTap: () {
        navigateToProfileScreen(context, searchQuery);

      },
      child: imageUrl.isNotEmpty
          ? Container(
        width: 160,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: 160,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          saoTB,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        SizedBox(width: 4),
                        Row(
                          children: List.generate(
                            5,
                                (index) {
                              IconData iconData;
                              Color iconColor;
                              if (index < getStarRating(saoTB).floor()) {
                                // Full star
                                iconData = Icons.star;
                                iconColor = Colors.yellow;
                              } else if (index < getStarRating(saoTB)) {
                                // Half star
                                iconData = Icons.star_half;
                                iconColor = Colors.yellow;
                              } else {
                                // Empty star
                                iconData = Icons.star_border;
                                iconColor = Colors.grey;
                              }
                              return Icon(
                                iconData,
                                color: iconColor,
                                size: 16,
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      )
          : Container(),
    );
  }
}

// Data model for the product
class Product {
  final String imageUrl;
  final String name;
  final String description;
  final String id;
  final String Them;
  final String saoTB;
  final String nguongoc;

  Product({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.id,
    required this.Them,
    required this.saoTB,
    required this.nguongoc,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      imageUrl: json['Anh'] ?? '',
      name: json['Ten'] ?? 'Unknown',
      description: json['NoiDung'] ?? '',
      id: json['id'] ?? '',
      Them: json['Them'] ?? '',
      saoTB:json['saoTB'] ?? '',
      nguongoc: json['nguongoc']?? '',
    );
  }
}

Future<List<Product>> fetchTechProducts() async {
  final response = await http.get(Uri.parse('https://660d04c73a0766e85dbf4c43.mockapi.io/api/baiviet'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((item) => Product.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load tech products');
  }
}



