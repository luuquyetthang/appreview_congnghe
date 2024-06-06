import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart'; // Import thư viện sms_autofill

void main() {
  runApp(PasswordResetApp());
}

class PasswordResetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Reset UI',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ForgotPasswordForm(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/verify': (context) => VerificationScreen(),
        '/create-new-password': (context) => CreateNewPasswordScreen(),
      },
    );
  }
}

class ForgotPasswordForm extends StatefulWidget {
  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  Map<String, dynamic>? userDetails;

  Future<bool> _checkPhoneNumberExists(String phoneNumber) async {
    final String apiUrl = 'https://660d04c73a0766e85dbf4c43.mockapi.io/api/taikhoan?SDT=$phoneNumber';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> users = jsonDecode(response.body);
      if (users.isNotEmpty) {
        userDetails = users.first;
        return true;
      }
      return false;
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<void> _resetPassword(String phoneNumber) async {
    try {
      final String resetPasswordUrl = 'https://660d04c73a0766e85dbf4c43.mockapi.io/api/reset-password';
      final http.Response response = await http.post(
        Uri.parse(resetPasswordUrl),
        body: {
          'phone_number': phoneNumber,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Gửi mã xác minh qua tin nhắn SMS
        SmsAutoFill().listenForCode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset request sent successfully to $phoneNumber')),
        );
        Navigator.pushNamed(context, '/forgot-password', arguments: userDetails);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send password reset request')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while sending password reset request: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    bool phoneNumberExists = await _checkPhoneNumberExists(_phoneNumberController.text);
                    if (phoneNumberExists) {
                      await _resetPassword(_phoneNumberController.text);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Phone number does not exist')),
                      );
                    }
                  }
                },
                child: Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? userDetails = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Spacer(),
            Icon(Icons.lock, size: 100, color: Colors.yellow),
            SizedBox(height: 24),
            Text('Select which contact details should we use to reset your password', textAlign: TextAlign.center),
            SizedBox(height: 24),
            if (userDetails != null) ...[
              if (userDetails['SDT'] != null)
                ListTile(
                  leading: Icon(Icons.sms, color: Colors.green),
                  title: Text(userDetails['SDT']),
                  onTap: () {
                    Navigator.pushNamed(context, '/verify', arguments: userDetails['SDT']);
                  },
                ),
              if (userDetails['Email'] != null)
                ListTile(
                  leading: Icon(Icons.email, color: Colors.green),
                  title: Text(userDetails['Email']),
                  onTap: () {
                    Navigator.pushNamed(context, '/verify', arguments: userDetails['Email']);
                  },
                ),
            ],
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/verify');
              },
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String contactDetail = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Spacer(),
            Text('Code has been sent to $contactDetail', textAlign: TextAlign.center),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return Container(
                  width: 50,
                  child: TextField(
                    controller: _codeController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                  ),
                );
              }),
            ),
            SizedBox(height: 24),
            Text('Resend code in 55 s', textAlign: TextAlign.center, style: TextStyle(color: Colors.green)),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create-new-password');
              },
              child: Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateNewPasswordScreen extends StatefulWidget {
  @override
  _CreateNewPasswordScreenState createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Spacer(),
            Icon(Icons.shield, size: 100, color: Colors.green),
            SizedBox(height: 24),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Create Your New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Your Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: true,
                  onChanged: (value) {},
                ),
                Text('Remember me'),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Implement password reset logic
              },
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
