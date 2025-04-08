import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../sup/genreMap.dart';

class TmdbService {
  static final String _apiKey =  dotenv.env['TMDB_API']!;
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
        List<Map<String, dynamic>> movies = [];

        if (data['crew'] != null) {
          if (personType == 'Directing') {
            movies = List<Map<String, dynamic>>.from(data['crew'].where((movie) => movie['job'] == 'Director'));
          } else if (personType == 'Acting') {
            movies = List<Map<String, dynamic>>.from(data['cast'].where((movie) => movie['character'] != null));
          } else if (personType == 'Writing') {
            movies = List<Map<String, dynamic>>.from(data['crew'].where((movie) => movie['department'] == 'Writing'));
          } else {
            movies = List<Map<String, dynamic>>.from(data['crew'].where((movie) => movie['job'] == 'Director'));
          }
        }

        movies.sort((a, b) {
          DateTime dateA = DateTime.tryParse(a['release_date'] ?? '') ?? DateTime(0);
          DateTime dateB = DateTime.tryParse(b['release_date'] ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });

        return movies;
      }
      return [];
    }

    Future<Map<String, dynamic>?> getPersonalDetails(int personId, String languageCode) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/person/$personId?api_key=$_apiKey&language=$languageCode'),
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

  Future<List< dynamic>>  getPopularMovies() async {
    final List< dynamic> movies = [];
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
          movies.addAll(data['results']);
        }
    }
    return movies;
  }

  Future<List< dynamic>>  getLatestMovies() async {
    final List< dynamic> movies = [];
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
          movies.addAll(data['results']);
        }
    }
     // Filmleri release_date'e göre azalan sırayla sıralıyoruz
      movies.sort((a, b) {
        DateTime dateA = DateTime.parse(a['release_date']);
        DateTime dateB = DateTime.parse(b['release_date']);
        return dateB.compareTo(dateA);
      });
    return movies;
  }

  Future<List< dynamic>>  getUpcomingMovies() async {
    final List< dynamic> movies = [];
    // Bugünün tarihini alıyoruz
    DateTime now = DateTime.now();
    String startDate = now.toIso8601String().split('T').first; // "YYYY-MM-DD"
    
    // 3 ay sonrası
    DateTime threeMonthsLater = now.add(Duration(days: 90));
    String endDate = threeMonthsLater.toIso8601String().split('T').first; // "YYYY-MM-DD"

    
    final response = await http.get(
      Uri.parse('$_baseUrl/discover/movie?api_key=$_apiKey&primary_release_date.gte=$startDate&primary_release_date.lte=$endDate'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
          movies.addAll(data['results']);
        }
    }

     // Filmleri release_date'e göre azalan sırayla sıralıyoruz
      movies.sort((a, b) {
        DateTime dateA = DateTime.parse(a['release_date']);
        DateTime dateB = DateTime.parse(b['release_date']);
        return dateA.compareTo(dateB);
      });

    return movies;
  }

  Future<List<Map<String, dynamic>>> getMultipleMovies(List<String> movieTitles) async {
    final List<Map<String, dynamic>> movies = [];
  
    for (final title in movieTitles) {
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/search/movie?api_key=$_apiKey&query=$title'),
      );
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['results'].isNotEmpty) {
          movies.add(data['results'][0]); // İlk sonucun ID'si
        }
      }
    }
  
    return movies;
  }

  Future<List<int>> getTMDBIds(List<String> movieTitles) async {
    final List<int> movieIds = [];
  
    for (final title in movieTitles) {
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/search/movie?api_key=$_apiKey&query=$title'),
      );
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['results'].isNotEmpty) {
          movieIds.add(data['results'][0]['id']); // İlk sonucun ID'si
        }
      }
    }
  
    return movieIds;
  }

  Future<List<Map<String, dynamic>>> getMoviesByGenre(String genre, String popularity) async {
    final genreId = genreMap.entries.firstWhere(
      (entry) => entry.value.toLowerCase() == genre.toLowerCase(),
      orElse: () => const MapEntry(-1, ''),
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
    Uri.parse('$_baseUrl/movie/$movieId/recommendations?api_key=$_apiKey'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['results'] != null) {
      similarMovies.addAll(List<Map<String, dynamic>>.from(data['results']));
    }
  }

  return similarMovies.toSet().toList(); // Eğer hata veya sonuç yoksa boş liste döndür
}

Future<List<Map<String, dynamic>>> getCollectionMovies(int collectionId) async {
    List<Map<String, dynamic>> collectionMovies = [];
  final response = await http.get(
    Uri.parse('$_baseUrl/collection/$collectionId?api_key=$_apiKey'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['parts'] != null) {
      collectionMovies.addAll(List<Map<String, dynamic>>.from(data['parts']));
    }
  }

  return collectionMovies.toSet().toList(); // Eğer hata veya sonuç yoksa boş liste döndür
}

Future<List<Map<String, dynamic>>> getMoviesByProvider(int providerId) async {
    List<Map<String, dynamic>> providerMovies = [];
  final response = await http.get(
    Uri.parse('$_baseUrl/discover/movie?api_key=$_apiKey&with_watch_providers=$providerId&sort_by=popularity.desc'),
  );
  print(json.decode(response.body));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['results'] != null) {
      providerMovies.addAll(List<Map<String, dynamic>>.from(data['results']));
    }
  }

  return providerMovies.toSet().toList(); // Eğer hata veya sonuç yoksa boş liste döndür
}

Future<List<Map<String, dynamic>>> getPgRating(int movieId) async {
  List<Map<String, dynamic>> pgRatings = [];
  final response = await http.get(
    Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey&language=en-US&append_to_response=release_dates'),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['release_dates']['results'] != null) {
      pgRatings.addAll(List<Map<String, dynamic>>.from(data['release_dates']['results']));
    }
  }

  return pgRatings.toSet().toList(); // Eğer hata veya sonuç yoksa boş liste döndür
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
    allMovies.sort((a, b) {
          DateTime dateA = DateTime.tryParse(a['release_date'] ?? '') ?? DateTime(0);
          DateTime dateB = DateTime.tryParse(b['release_date'] ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });

    // Benzersiz filmleri filtreleyin
    return allMovies.toSet().toList();
}

Future<Map<String, dynamic>?> getProviders(int movieId) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/watch/providers?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // TR bölgesi için sağlayıcıları al, yoksa US bölgesine bak
      final results = data['results'];
      if (results == null) return null;
      
      final providers = results['US'];
      
      if (providers != null) {
        return {
          'flatrate': List<Map<String, dynamic>>.from(providers['flatrate'] ?? []),
          'rent': List<Map<String, dynamic>>.from(providers['rent'] ?? []),
          'buy': List<Map<String, dynamic>>.from(providers['buy'] ?? []),
        };
      }
    }
    return null;
  } catch (e) {
    //print('Error fetching providers: $e');
    return null;
  }
}
Future<List< dynamic>>  getPopularPeople() async {
    final List< dynamic> people = [];
    final response = await http.get(
      Uri.parse('$_baseUrl/person/popular?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
          people.addAll(data['results']);
        }
    }
    print(people);
     
    return people;
  }

} 