import 'dart:convert';
import 'package:http/http.dart' as http;

class OmdbService {
  static const String _apiKey = '80523389';
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