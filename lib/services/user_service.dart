import 'package:mongo_dart/mongo_dart.dart';
import 'api_service.dart';

class UserService {
  static const String collectionName = 'users';

  // Register a new user
  Future<bool> register(String username, String password) async {
    try {
      final collection = DBConnection.getInstance().getCollection(collectionName);

      // Check if user already exists
      final existingUser = await collection.findOne({'username': username});
      if (existingUser != null) {
        print("User already exists");
        return false;
      }

      // Insert new user
      await collection.insertOne({
        'username': username,
        'password': password, // In production, hash the password!
        'createdAt': DateTime.now().toIso8601String(),
      });
      print("User registered successfully");
      return true;
    } catch (e) {
      print("Error registering user: $e");
      return false;
    }
  }

  // Login user
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final collection = DBConnection.getInstance().getCollection(collectionName);
      final user = await collection.findOne({
        'username': username,
        'password': password,
      });
      if (user != null) {
        print("Login successful");
        return user;
      } else {
        print("Invalid credentials");
        return null;
      }
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }
}