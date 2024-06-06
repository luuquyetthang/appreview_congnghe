import 'package:flutter/material.dart';
import 'edit.dart';
import 'package:btl/Home/test.dart';
import 'package:btl/dkdn/fromdn.dart';
import 'package:btl/Home/Search.dart';
import 'package:btl/Home/sosanh.dart';

class Profile1 extends StatelessWidget {
  final String username;

  Profile1({required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ProfileScreen(username: username),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final String username;

  ProfileScreen({required this.username});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> profile;
  late String _searchQuery = ''; // Initialize _searchQuery variable
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  void fetchProfile() {
    setState(() {
      isLoading = true;
    });

    // Simulate network delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        profile = {
          'fullName': 'John Doe',
        };
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                    NetworkImage('https://i.imgur.com/BoN9kdC.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditProfileScreen(username: widget.username,searchQuery: _searchQuery,),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {
                // Handle help tap
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginForm(),
                  ),
                );
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
}
