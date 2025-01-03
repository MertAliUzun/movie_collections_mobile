import 'dart:convert';
import 'package:http/http.dart' as http;

class TmdbService {
  static const String _apiKey = '61898fc6229d9ec067b5e35b00e8cda5';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    if (query.length < 2) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null) {
        return List<Map<String, dynamic>>.from(data['results']);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> searchPeople(String query) async {
    if (query.length < 2) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/search/person?api_key=$_apiKey&query=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null) {
        return List<Map<String, dynamic>>.from(data['results']);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getMoviesByPerson(int personId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/person/$personId/movie_credits?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['crew'] != null) {
        return List<Map<String, dynamic>>.from(data['crew'].where((movie) => movie['job'] == 'Director'));
      }
    }
    return [];
  }
    Future<Map<String, dynamic>?> getPersonalDetails(int personId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/person/$personId?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey&append_to_response=credits'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    }
    return null;
  }
} 