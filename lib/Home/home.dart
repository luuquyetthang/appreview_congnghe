import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DuckNewsProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tin Vịt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
          title: Text('Tin Vịt'),
          backgroundColor: Colors.blue,
        ),
        body: NewsListScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DuckNewsProvider extends ChangeNotifier {
  Map<String, double> ratings = {};
  Map<String, String> comments = {};

  void setRatingAndComment(String title, double rating, String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('rating_$title', rating);
    await prefs.setString('comment_$title', comment);
    ratings[title] = rating;
    comments[title] = comment;
    notifyListeners();
  }

  Future<void> loadRatingsAndComments(List<String> titles) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String title in titles) {
      double rating = prefs.getDouble('rating_$title') ?? 0.0;
      String comment = prefs.getString('comment_$title') ?? '';
      ratings[title] = rating;
      comments[title] = comment;
    }
    notifyListeners();
  }
}

class NewsListScreen extends StatelessWidget {
  Future<List<DuckNews>> fetchDuckNewsList() async {
    final response = await http.get(
      Uri.parse('https://660d04c73a0766e85dbf4c43.mockapi.io/api/baiviet'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((data) => DuckNews.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load duck news');
    }
  }

  @override
  Widget build(BuildContext context) {
    final duckNewsProvider = Provider.of<DuckNewsProvider>(context, listen: false);

    return Scaffold(
      body: FutureBuilder<List<DuckNews>>(
        future: fetchDuckNewsList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<DuckNews> duckNewsList = snapshot.data!;
            duckNewsProvider.loadRatingsAndComments(duckNewsList.map((news) => news.ten).toList());
            return ListView.builder(
              itemCount: duckNewsList.length,
              itemBuilder: (context, index) {
                return Consumer<DuckNewsProvider>(
                  builder: (context, provider, child) {
                    double rating = provider.ratings[duckNewsList[index].ten] ?? 0.0;
                    String comment = provider.comments[duckNewsList[index].ten] ?? '';
                    return Card(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DuckNewsDetailScreen(duckNewsList[index]),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: Image.network(
                            duckNewsList[index].anh,
                            width: 100,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            duckNewsList[index].ten,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                duckNewsList[index].noiDung,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Đánh giá: ${rating.toStringAsFixed(1)} sao',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DuckNewsDetailScreen(duckNewsList[index]),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            ),
                            child: Text('Đánh giá'),
                          ),
                        ),
                      ),
                    );

                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
class DuckNews {
  final String ten;
  final String anh;
  final String noiDung;
  final String them;

  DuckNews(this.ten, this.anh, this.noiDung,this.them);

  factory DuckNews.fromJson(Map<String, dynamic> json) {
    return DuckNews(
      json['Ten'],
      json['Anh'],
      json['NoiDung'],
      json['Them'],
    );
  }
}
class DuckNewsDetailScreen extends StatefulWidget {
  final DuckNews duckNews;

  DuckNewsDetailScreen(this.duckNews);

  @override
  _DuckNewsDetailScreenState createState() => _DuckNewsDetailScreenState();
}
class _DuckNewsDetailScreenState extends State<DuckNewsDetailScreen> {
  double _rating = 0.0;
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final duckNewsProvider = Provider.of<DuckNewsProvider>(context, listen: false);
    _rating = duckNewsProvider.ratings[widget.duckNews.ten] ?? 0.0;
    _commentController.text = duckNewsProvider.comments[widget.duckNews.ten] ?? '';
  }

  void _saveRating(double newRating) {
    final duckNewsProvider = Provider.of<DuckNewsProvider>(context, listen: false);
    duckNewsProvider.setRatingAndComment(widget.duckNews.ten, newRating, _commentController.text);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Đánh giá của bạn đã được lưu!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Split the content into lines
    List<String> contentLines = widget.duckNews.noiDung.split('\n');
    String initialContent = contentLines.take(3).join('\n');
    String remainingContent = contentLines.skip(3).join('\n');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.duckNews.ten),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: NetworkImage(widget.duckNews.anh),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.duckNews.ten,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          initialContent,
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.duckNews.them,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 20),
              RatingWidget(
                initialRating: _rating,
                onRatingChanged: (newRating) {
                  setState(() {
                    _rating = newRating;
                  });
                  _saveRating(newRating);
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Nhập đánh giá',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RatingWidget extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double>? onRatingChanged;

  RatingWidget({required this.initialRating, this.onRatingChanged});

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final int wholeNumber = _rating.floor();
            final IconData iconData = index < wholeNumber
                ? Icons.star
                : index == wholeNumber && _rating % 1 != 0
                ? Icons.star_half
                : Icons.star_border;
            return IconButton(
              icon: Icon(
                iconData,
                color: Colors.orange,
                size: 40,
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
      ],
    );
  }
}
