import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My detail',
      home: ProfileScreen(initialRating: 0),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double>? onRatingChanged;

  ProfileScreen({required this.initialRating, this.onRatingChanged});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;
  int _currentImageIndex = 0;
  final int _numImages = 4;
  double _rating = 0;
  TextEditingController _reviewController = TextEditingController();
  List<Review> _reviews = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget buildIndicator(int index) {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentImageIndex == index
            ? Color.fromRGBO(0, 0, 0, 0.9)
            : Color.fromRGBO(0, 0, 0, 0.4),
      ),
    );
  }

  double calculateAverageRating() {
    if (_reviews.isEmpty) return 0;
    double totalRating = _reviews.fold(0, (sum, review) => sum + review.rating);
    return totalRating / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                pauseAutoPlayOnTouch: true,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
              ),
              items: [
                'https://product.hstatic.net/200000348419/product/gia_iphone_13_chinh_hang_483a1bd798784ccab1ff30507063c15b_master.png',
                'https://shopdunk.com/images/thumbs/0021587_iphone-15-pro-max_1600.png',
                'https://product.hstatic.net/200000348419/product/gia_iphone_13_chinh_hang_483a1bd798784ccab1ff30507063c15b_master.png',
                'https://shopdunk.com/images/thumbs/0021587_iphone-15-pro-max_1600.png',
              ].map((String url) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_numImages, (index) => buildIndicator(index)),
            ),
            SizedBox(height: 20.0),
            Divider(),
            Row(
              children: [
                Icon(Icons.rate_review, color: Colors.blue),
                SizedBox(width: 8.0),
                Text(
                  'Đánh giá và nhận xét',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Text(
              'Đánh giá của bạn:',
              style: TextStyle(fontSize: 16.0),
            ),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_rating == index + 1) {
                        _rating -= 0.5;
                      } else {
                        _rating = index + 1;
                      }
                      widget.onRatingChanged?.call(_rating);
                    });
                    widget.onRatingChanged?.call(_rating);
                  },
                );
              }),
            ),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Viết nhận xét của bạn',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _reviews.add(Review(rating: _rating, comment: _reviewController.text));
                  _rating = 0;
                  _reviewController.clear();
                });
              },
              child: Text('Gửi'),
            ),
            SizedBox(height: 20.0),
            Divider(),
            Row(
              children: [
                Icon(Icons.comment, color: Colors.blue),
                SizedBox(width: 8.0),
                Text(
                  'Tất cả đánh giá',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Text(
              'Trung bình số sao: ${calculateAverageRating().toStringAsFixed(1)}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Column(
              children: _reviews.map((review) {
                return ListTile(
                  leading: Icon(Icons.star, color: Colors.yellow),
                  title: Text('Rating: ${review.rating}'),
                  subtitle: Text(review.comment),
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}

class Review {
  final double rating;
  final String comment;

  Review({required this.rating, required this.comment});
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String description;

  ProjectCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          // Handle tap event
        },
      ),
    );
  }
}
