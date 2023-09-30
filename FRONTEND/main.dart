import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Surveillance',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: AuthenticationScreen(),
    );
  }
}

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Smart Surveillance',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the login screen
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the signup screen
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SignupScreen(),
                ));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Signup'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Login to Your Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              obscureText: true, // Hide the entered password
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Replace with your image capture logic
                String base64Image = "base64_encoded_image_here";

                // Send the image to the server for face detection
                final response = await detectFace(base64Image);

                // Show the result based on the response
                showFaceDetectionMessage(context, response);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> detectFace(String base64Image) async {
    final response = await http.post(
      Uri.parse('http://192.168.2.105:5000/notification'), // Replace with your server address
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"image": base64Image}),
    );

    if (response.statusCode == 200) {
      return response.body; // Response should contain "Face Detected" or "No Face Detected"
    } else {
      return "Error: ${response.statusCode}";
    }
  }

  void showFaceDetectionMessage(BuildContext context, String response) {
    if (response.contains("Face Detected")) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Face Detected'),
            content: const Text('Welcome! Your face has been detected.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('No Face Detected'),
            content: const Text('Sorry, no face detected. Try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Create an Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'License Plate Number'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement your signup logic here
                // You can access the entered values using the TextEditingController
              },
              child: const Text('Signup'),
            ),
          ],
        ),
      ),
    );
  }
}
