import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OmdbService {
  static final String _apiKey = dotenv.env['OMDB_API']!;
  static const String _baseUrl = 'http://www.omdbapi.com/';

  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    if (query.length < 2) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl?apikey=$_apiKey&s=$query&type=movie'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == 'True') {
        return List<Map<String, dynamic>>.from(data['Search']);
      }
    }
    return [];
  }

  Future<Map<String, dynamic>?> getMovieDetails(String imdbId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?apikey=$_apiKey&i=$imdbId&plot=full'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == 'True') {
        return data;
      }
    }
    return null;
  }
} 