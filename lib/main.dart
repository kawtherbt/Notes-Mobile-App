import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'notes_page.dart';
import 'login_page.dart';
import 'sign_up_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyBGWtlBBmdpVQ9TfUDkPz4VqfxBdoxT1fY',
        appId: '1:736451319430:android:dc9d40a403c182b58ee307',
        messagingSenderId: '736451319430',
        projectId: 'notes-app-4f1c0',
        storageBucket: 'notes-app-4f1c0.firebasestorage.app',
      ),
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Using teal to match the other pages
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => AuthScreen(),
        '/signup': (context) => SignUpPage(),
        '/notes': (context) => NotesPage(),
      },
    );
  }
}

// HomeScreen manages authentication state and shows the appropriate page
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking the authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Chargement...'),
              backgroundColor: Colors.teal,
              centerTitle: true,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If the user is signed in
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Bienvenue'),
              backgroundColor: Colors.teal,
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate directly to the Notes page
                    Navigator.pushReplacementNamed(context, '/notes');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Aller à Notes', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          );
        }

        // If the user is not signed in, show the SignUpPage
        return Scaffold(
          appBar: AppBar(
            title: Text('Créer un compte'),
            backgroundColor: Colors.teal,
            centerTitle: true,
          ),
          body: SignUpPage(), // Directly render SignUpPage for the user to sign up
        );
      },
    );
  }
}
