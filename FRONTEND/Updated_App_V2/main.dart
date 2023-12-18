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
      appBar: AppBar(
        title: const Text('Smart Surveillance'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => AuthenticationScreen(),
              ));
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ));
            },
            icon: const Icon(Icons.login),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SignupScreen(),
              ));
            },
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/apphome.jpg"), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                '',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
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
      ),
    );
  }
}

class User {
  final dynamic cnic;
  final String username;
  final String password_hash;
  final String full_name;
  final String vehicle_type;
  final String vehicle_model;
  final String vehicle_color;
  final String registered_city;
  final String license_plate;

  User({
    required this.cnic,
    required this.username,
    required this.password_hash,
    required this.full_name,
    required this.vehicle_type,
    required this.vehicle_model,
    required this.vehicle_color,
    required this.registered_city,
    required this.license_plate
  });
}

List<User> users = [];

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SignupScreen(),
              ));
            },
            icon: const Icon(Icons.person_add),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const AuthenticationScreen(),
              ));
            },
            icon: const Icon(Icons.home),
          ),
        ],
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
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () async {
                final enteredUsername = usernameController.text;
                final enteredPassword = passwordController.text;

                // Replace local data retrieval with server call
                final user = await loginfl(enteredUsername, enteredPassword);

                if (user != null) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => LoggedInScreen(user: user),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid username or password'),
                    ),
                  );
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final cnicController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const AuthenticationScreen(),
              ));
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ));
            },
            icon: const Icon(Icons.login),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
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
                  controller: cnicController,
                  decoration: const InputDecoration(labelText: 'CNIC'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your CNIC';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    _signupAsync();
                  },
                  child: const Text('Signup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signupAsync() async {
    if (_validateForm()) {
      final cnic = cnicController.text;
      final username = usernameController.text;
      final password_hash = passwordController.text;
      String full_name = " ";
      String vehicle_type = " ";
      String vehicle_model = " ";
      String vehicle_color = " ";
      String registered_city = " ";
      String license_plate = " ";

      // Create a User object with CNIC, username, and password
      final newUser = User(
        cnic: cnic,
        username: username,
        password_hash: password_hash,
        full_name: full_name,
        vehicle_type: vehicle_type,
        vehicle_model: vehicle_model,
        vehicle_color: vehicle_color,
        registered_city: registered_city,
        license_plate: license_plate,
      );

      // Add the user to the list
      users.add(newUser);

      // Call the Flask signup API
      await signup(cnic, username, password_hash);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup successful. Please log in.'),
        ),
      );

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ));
    }
  }

  bool _validateForm() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      return true;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fix the errors in the form'),
      ),
    );
    return false;
  }
}

class LoggedInScreen extends StatelessWidget {
  final User user;

  const LoggedInScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged In'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const SignedOutScreen(),
              ));
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Welcome, ${user.username}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('CNIC:'),
            subtitle: Text(user.cnic.toString()), // Convert to String
          ),
          ListTile(
            title: const Text('Name:'),
            subtitle: Text(user.full_name),
          ),
          ListTile(
            title: const Text('Vehicle Type:'),
            subtitle: Text(user.vehicle_type),
          ),
          ListTile(
            title: const Text('Model:'),
            subtitle: Text(user.vehicle_model),
          ),
          ListTile(
            title: const Text('Color:'),
            subtitle: Text(user.vehicle_color),
          ),
          ListTile(
            title: const Text('Registered City:'),
            subtitle: Text(user.registered_city),
          ),
          ListTile(
            title: const Text('License Plate Number:'),
            subtitle: Text(user.license_plate),
          ),
        ],
      ),
    );
  }
}


Future<User?> loginfl(String username, String password) async {
  final url = Uri.parse('http://10.1.151.113:5000/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      // Check if the required keys exist in the response
      if (data.containsKey('cnic') &&
          data.containsKey('username') &&
          data.containsKey('password_hash') &&
          data.containsKey('full_name') &&
          data.containsKey('vehicle_type') &&
          data.containsKey('vehicle_model') &&
          data.containsKey('vehicle_color') &&
          data.containsKey('registered_city') &&
          data.containsKey('license_plate')) {
        // Extract user information from the data received
        User user = User(
          cnic: data['cnic'],
          username: data['username'],
          password_hash: data['password_hash'],
          full_name: data['full_name'],
          vehicle_type: data['vehicle_type'],
          vehicle_model: data['vehicle_model'],
          vehicle_color: data['vehicle_color'],
          registered_city: data['registered_city'],
          license_plate: data['license_plate'],
        );

        return user;
      } else {
        print('Missing key(s) in the response');
        return null;
      }
    } else {
      // Handle error
      print('Login failed: ${response.body}');
      return null;
    }
  } catch (error) {
    print('Error: $error');
    return null;
  }
}


class SignedOutScreen extends StatelessWidget {
  const SignedOutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signed Out'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const AuthenticationScreen(),
              ));
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ));
            },
            icon: const Icon(Icons.login),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'User has signed out',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const AuthenticationScreen(),
                ));
              },
              child: const Text('Home'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ));
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}


Future<void> signup(String cnic, String username, String password) async {
  final url = Uri.parse('http://10.1.151.113:5000/signup');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'cnic': cnic,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Handle success
      print('Signup successful');
    } else {
      // Handle error
      print('Signup failed: ${response.body}');
    }
  } catch (error) {
    print('Error: $error');
  }
}


Future<void> login(String username, String password) async {
  final url = Uri.parse('http://10.1.151.113:5000/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Handle success
      var data = json.decode(response.body);
      // Use the data as needed, e.g., navigating to a new screen with user info
      print('Login successful: $data');
    } else {
      // Handle error
      print('Login failed: ${response.body}');
    }
  } catch (error) {
    print('Error: $error');
  }
}
