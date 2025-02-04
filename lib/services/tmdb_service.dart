import 'dart:convert';
import 'package:http/http.dart' as http;
import '../sup/genreMap.dart';

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
  Future<List<Map<String, dynamic>>> searchCompany(String query) async {
    if (query.length < 2) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/search/company?api_key=$_apiKey&query=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null) {
        return List<Map<String, dynamic>>.from(data['results']);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getMoviesByPerson(int personId, String personType) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/person/$personId/movie_credits?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['crew'] != null) {
        if(personType == 'Director') { return List<Map<String, dynamic>>.from(data['crew'].where((movie) => movie['job'] == 'Director'));  }
        else if ( personType == 'Actor') { return List<Map<String, dynamic>>.from(data['cast'].where((movie) => movie['character'] != null)); }
        else if ( personType == 'Writer') { return List<Map<String, dynamic>>.from(data['crew'].where((movie) => movie['department'] == 'Writing')); }
        else { return List<Map<String, dynamic>>.from(data['crew'].where((movie) => movie['job'] == 'Director'));}
        
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

  Future<List<Map<String, dynamic>>> getMoviesByGenre(String genre, String popularity) async {
    final genreId = genreMap.entries.firstWhere(
      (entry) => entry.value.toLowerCase() == genre.toLowerCase(),
      orElse: () => MapEntry(-1, ''),
    ).key;

    if (genreId == -1) {
      throw Exception('Genre not found');
    }

    List<Map<String, dynamic>> allMovies = [];

    // Fetch 60 movies by making 3 requests (20 movies each)
    for (int page = 1; page <= 3; page++) {
      String url;
      if (popularity == 'Daily') {
        url = '$_baseUrl/trending/movie/day?api_key=$_apiKey&with_genres=$genreId&page=$page';
      } else if (popularity == 'Weekly') {
        url = '$_baseUrl/trending/movie/week?api_key=$_apiKey&with_genres=$genreId&page=$page';
      } else {
        url = '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=$genreId&page=$page';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          allMovies.addAll(List<Map<String, dynamic>>.from(data['results']));
        }
      }
    }

    return allMovies;
  }
  Future<List<Map<String, dynamic>>> getSimilarMovies(int movieId) async {
    List<Map<String, dynamic>> similarMovies = [];
  final response = await http.get(
    Uri.parse('$_baseUrl/movie/$movieId/similar?api_key=$_apiKey'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['results'] != null) {
      similarMovies.addAll(List<Map<String, dynamic>>.from(data['results']));
    }
  }

  return similarMovies.toSet().toList(); // Eğer hata veya sonuç yoksa boş liste döndür
}

  Future<List<Map<String, dynamic>>> getMoviesByCompany(int companyId) async {
    List<Map<String, dynamic>> allMovies = [];
    
    for (int page = 1; page <= 9; page++) { 
      final response = await http.get(
        Uri.parse('$_baseUrl/discover/movie?api_key=$_apiKey&with_companies=$companyId&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          allMovies.addAll(List<Map<String, dynamic>>.from(data['results']));
        }
      }
    }

    // Benzersiz filmleri filtreleyin
    return allMovies.toSet().toList();
}
  /*
  Future<List<Map<String, dynamic>>> getMoviesByCompany(int companyId) async {
  List<Map<String, dynamic>> allMovies = [];
  int totalPages = 1;

  for (int page = 1; page <= totalPages; page++) {
    final response = await http.get(
      Uri.parse('$_baseUrl/discover/movie?api_key=$_apiKey&with_companies=$companyId&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (page == 1) {
        totalPages = data['total_pages'] ?? 1;
      }
      if (data['results'] != null) {
        allMovies.addAll(List<Map<String, dynamic>>.from(data['results']));
      }
    } else {
      print('Error: ${response.statusCode}');
      break;
    }
  }
  return allMovies.toSet().toList();
} */
} 