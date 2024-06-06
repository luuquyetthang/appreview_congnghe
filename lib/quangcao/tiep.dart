import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:btl/dkdn/fromdn.dart';

class TravelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Review Công Nghệ',
      theme: ThemeData(
        primaryColor: Color(0xFF0F0147),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto', // Font family example
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Color(0xFF0F0147)),
          bodyText1: TextStyle(fontSize: 16.0, color: Color(0xFF0F0147)),
        ),
      ),
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final CarouselController _carouselController = CarouselController();
  int _currentIndex = 0;

  final List<OnboardingModel> onboardingData = [
    OnboardingModel(
      image: 'assets/kho/images.jpg',
      title: "Khám phá Công Nghệ mới nhất",
      description: 'Cập nhật với những thiết bị Công Nghệ mới nhất và sáng tạo nhất trên thị trường.',
    ),
    OnboardingModel(
      image: 'assets/kho/logo.jpg',
      title: 'Đánh giá và Kiến thức chuyên môn',
      description: 'Nhận đánh giá sâu sắc và những hiểu biết chuyên sâu về các xu hướng Công Nghệ mới nhất.',
    ),
    OnboardingModel(
      image: 'assets/kho/thang.jpg',
      title: "Tham gia Cộng Đồng Công Nghệ",
      description: 'Kết nối với những người yêu Công Nghệ khác và chia sẻ suy nghĩ và đánh giá của bạn.',
    ),
  ];

  void onNextPage(int currentIndex, BuildContext context) {
    if (currentIndex < onboardingData.length - 1) {
      _carouselController.nextPage();
      setState(() {
        _currentIndex = currentIndex + 1;
      });
    } else {
      // Navigate to login page when reaching the last page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginForm()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CarouselSlider(
            items: onboardingData
                .map((item) => OnboardingPage(
              model: item,
              currentIndex: _currentIndex,
              totalItems: onboardingData.length,
              onNextPage: () => onNextPage(_currentIndex, context),
            ))
                .toList(),
            carouselController: _carouselController,
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          Positioned(
            top: 80.0,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: onboardingData
                  .asMap()
                  .entries
                  .map(
                    (entry) => GestureDetector(
                  onTap: () => _carouselController.animateToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key ? Color(0xFF0F0147) : Colors.grey,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingModel model;
  final int currentIndex;
  final int totalItems;
  final VoidCallback onNextPage;

  OnboardingPage(
      {required this.model, required this.currentIndex, required this.totalItems, required this.onNextPage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(model.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.title,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    model.description,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 20.0), // Adjust spacing as needed
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onNextPage,
                      child: Text(currentIndex < totalItems - 1 ? 'Next' : 'Get Started'),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF0F0147),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // Skip button action, e.g., navigate to the main app
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginForm()),
                        );
                      },
                      child: Text('Skip', style: TextStyle(color: Color(0xFF0F0147))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardingModel {
  final String image;
  final String title;
  final String description;

  OnboardingModel({required this.image, required this.title, required this.description});
}
