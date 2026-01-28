import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DBConnection {
  static DBConnection? _instance;
  static Db? _db;

  // Private constructor
  DBConnection._();

  // Singleton instance
  static DBConnection getInstance() {
    _instance ??= DBConnection._();
    return _instance!;
  }

  // Load connection string from .env
  final String _connectionString = dotenv.env['MONGO_URI'] ?? '';

  // Get or establish connection
  Future<Db> getConnection() async {
    if (_db == null) {
      if (_connectionString.isEmpty) {
        throw Exception("MONGO_URI not found in .env file");
      }
      try {
        _db = await Db.create(_connectionString);
        await _db!.open();
        print("Connected to MongoDB Atlas");
      } catch (e) {
        print("Error connecting to MongoDB Atlas: $e");
        rethrow;
      }
    }
    return _db!;
  }

  // Close connection
  void closeConnection() {
    _db?.close();
    _db = null;
    print("MongoDB connection closed");
  }

  // Access collections
  DbCollection getCollection(String collectionName) {
    if (_db == null) {
      throw Exception("Database not connected. Call getConnection first.");
    }
    return _db!.collection(collectionName);
  }
}