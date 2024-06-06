import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:btl/Home/test.dart'; // Update this import with the actual path to your Product model file.
import 'package:btl/profile/canhan.dart';
import 'package:btl/Home/Search.dart';
import 'package:btl/Home/sosanh.dart';
import 'package:url_launcher/url_launcher.dart';

class chitietScreen extends StatefulWidget {
  final Product product;
  final String username;
  final String searchQuery; // Add _searchQuery variable

  chitietScreen({required this.product, required this.username, required this.searchQuery});



  @override
  _chitietScreenState createState() => _chitietScreenState();

}

class _chitietScreenState extends State<chitietScreen> {
  String _comment = '';
  double _rating = 0;
  String _productId = '';
  double _averageRating = 0.0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productId = widget.product.id;
    calculateAverageRating();
  }

  Future<List<Map<String, dynamic>>> fetchReviews() async {
    final response = await http.get(
      Uri.parse('https://66516a3920f4f4c44277a923.mockapi.io/api/danhgia'),
    );

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(utf8Body);
      return data.map((review) => review as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  void calculateAverageRating() async {
    final reviews = await fetchReviews();
    final productReviews = reviews.where((review) => review['IDbaiviet'] == _productId).toList();

    if (productReviews.isNotEmpty) {
      double totalRating = productReviews.fold(0, (sum, review) => sum + double.parse(review['DanhGia']));
      double averageRating = totalRating / productReviews.length;

      setState(() {
        _averageRating = averageRating;
      });

      updateAverageRatingInAPI(averageRating); // Call method to update average rating in API
    }
  }

  void updateAverageRatingInAPI(double averageRating) async {
    final Map<String, dynamic> updateData = {
      'saoTB': averageRating.toString(),
    };

    final response = await http.put(
      Uri.parse('https://660d04c73a0766e85dbf4c43.mockapi.io/api/baiviet/$_productId'), // Update the URL according to your API endpoint
      body: updateData,
    );

    if (response.statusCode == 200) {
      print('Đã cập nhật sao trung bình thành công');
    } else {
      print('Lỗi khi cập nhật sao trung bình: ${response.statusCode}');
    }
  }


  void sendReview() async {
    final Map<String, String> reviewData = {
      'BinhLuan': _comment,
      'DanhGia': _rating.toString(),
      'Username': widget.username,
      'IDbaiviet': _productId,
    };

    final response = await http.post(
      Uri.parse('https://66516a3920f4f4c44277a923.mockapi.io/api/danhgia'),
      body: reviewData,
    );

    if (response.statusCode == 201) {
      print('Đã gửi đánh giá thành công');
      calculateAverageRating(); // Recalculate the average rating after a new review is sent
      setState(() {}); // Refresh the UI to show the new review
    } else {
      print('Lỗi khi gửi đánh giá: ${response.statusCode}');
    }
  }

  void updateReview(String reviewId) async {
    final Map<String, String> updatedReviewData = {
      'BinhLuan': _comment,
      'DanhGia': _rating.toString(),
    };

    final response = await http.put(
      Uri.parse('https://66516a3920f4f4c44277a923.mockapi.io/api/danhgia/$reviewId'),
      body: updatedReviewData,
    );

    if (response.statusCode == 200) {
      print('Đã cập nhật đánh giá thành công');
      calculateAverageRating(); // Recalculate the average rating after a review is updated
      setState(() {}); // Refresh the UI to show the updated review
    } else {
      print('Lỗi khi cập nhật đánh giá: ${response.statusCode}');
    }
  }

  void deleteReview(String reviewId) async {
    final response = await http.delete(
      Uri.parse('https://66516a3920f4f4c44277a923.mockapi.io/api/danhgia/$reviewId'),
    );

    if (response.statusCode == 200) {
      print('Đã xóa đánh giá thành công');
      calculateAverageRating(); // Recalculate the average rating after a review is deleted
      setState(() {}); // Refresh the UI to remove the deleted review
    } else {
      print('Lỗi khi xóa đánh giá: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 8.0),
            Text('Thông Tin Chi Tiết'),
            Spacer(),
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    child: Text('Option 1'),
                  ),
                  PopupMenuItem(
                    child: Text('Option 2'),
                  ),
                  PopupMenuItem(
                    child: Text('Option 3'),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product.imageUrl.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  pauseAutoPlayOnTouch: true,
                  enlargeCenterPage: true,
                ),
                items: [widget.product.imageUrl].map((String url) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0), // Bo góc tròn
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // Màu đổ bóng
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3), // Độ phân tán và độ mờ
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0), // Bo góc tròn ảnh
                          child: Image.network(
                            url,
                            fit: BoxFit.cover, // Đảm bảo ảnh sẽ được hiển thị đầy đủ và không bị cắt bớt
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

            if (widget.product.imageUrl.isNotEmpty) SizedBox(height: 10.0),
            if (widget.product.imageUrl.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(1, (index) => buildIndicator(index)),
              ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8.0),
                Text(
                  widget.product.name,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo trục chính
              children: [
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center, // Để căn giữa theo chiều ngang
                  ),
                ),
              ],
            ),


            SizedBox(height: 20.0),

            Divider(),
            ElevatedButton(
              onPressed: () {
                launch(widget.product.nguongoc); // Mở liên kết trong trình duyệt
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward),
                  SizedBox(width: 8.0),
                  Text(
                    'Xem thêm',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Divider(),


            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Đánh giá sao:',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 30.0,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Bình luận của bạn',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (comment) {
                    setState(() {
                      _comment = comment;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: sendReview,
                  child: Text('Gửi đánh giá'),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              'Đánh giá và bình luận',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchReviews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Failed to load reviews');
                } else if (snapshot.hasData) {
                  final reviews = snapshot.data!;
                  final productReviews = reviews.where((review) => review['IDbaiviet'] == _productId).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (productReviews.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange),
                            SizedBox(width: 8.0),
                            /*Text(
                              'Rating trung bình: $_averageRating',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),*/
                          ],
                        ),
                      ...productReviews.map((review) {
                        return ListTile(
                          title: Text(review['Username']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RatingBarIndicator(
                                rating: double.parse(review['DanhGia']),
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 20.0,
                              ),
                              Text(review['BinhLuan']),
                            ],
                          ),
                          trailing: review['Username'] == widget.username
                              ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Hiển thị hộp thoại để sửa bình luận
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      String updatedComment = review['BinhLuan'];
                                      double updatedRating = double.parse(review['DanhGia']);
                                      return AlertDialog(
                                        title: Text('Sửa bình luận'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            RatingBar.builder(
                                              initialRating: updatedRating,
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              onRatingUpdate: (rating) {
                                                updatedRating = rating;
                                              },
                                            ),
                                            TextField(
                                              decoration: InputDecoration(
                                                labelText: 'Bình luận của bạn',
                                                border: OutlineInputBorder(),
                                              ),
                                              controller: TextEditingController(text: updatedComment),
                                              onChanged: (comment) {
                                                updatedComment = comment;
                                              },
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text('Hủy'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Cập nhật'),
                                            onPressed: () {
                                              setState(() {
                                                _comment = updatedComment;
                                                _rating = updatedRating;
                                              });
                                              updateReview(review['id']);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  // Hiển thị hộp thoại xác nhận xóa bình luận
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Xác nhận xóa'),
                                        content: Text('Bạn có chắc chắn muốn xóa bình luận này không?'),
                                        actions: [
                                          TextButton(
                                            child: Text('Hủy'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Xóa'),
                                            onPressed: () {
                                              deleteReview(review['id']);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          )
                              : null,
                        );
                      }).toList(),
                    ],
                  );
                } else {
                  return Text('No reviews yet');
                }
              },
            ),
          ],
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
  Widget buildIndicator(int index) {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
    );
  }
}

