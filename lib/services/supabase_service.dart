import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie_model.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SupabaseService {
  final SupabaseClient _supabaseClient;

  SupabaseService(this._supabaseClient);

  String get currentEmail => 'test@test.com';

  Future<List<Movie>> getMovies() async {
    final response = await _supabaseClient
        .from('movies')
        .select()
        .eq('user_email', currentEmail)
        .execute();
    return (response.data as List).map((movie) => Movie.fromJson(movie)).toList();
  }

  Future<void> addMovie(Movie movie) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Save to local storage if no internet
      await _saveMovieToLocalStorage(movie);
    } else {
      // Save to database if internet is available
      await _supabaseClient.from('movies').insert({
        'movie_name': movie.movieName,
        'director_name': movie.directorName,
        'release_date': movie.releaseDate.toIso8601String(),
        'plot': movie.plot,
        'runtime': movie.runtime,
        'imdb_rating': movie.imdbRating,
        'writers': movie.writers,
        'actors': movie.actors,
        'watched': movie.watched,
        'image_link': movie.imageLink,
        'user_email': movie.userEmail,
        'watch_date': movie.watchDate?.toIso8601String(),
        'user_score': movie.userScore,
        'hype_score': movie.hypeScore,
        'genres': movie.genres,
        'production_company': movie.productionCompany,
        'custom_sort_title': movie.customSortTitle,
        'country': movie.country,
        'popularity': movie.popularity,
        'budget': movie.budget,
        'revenue': movie.revenue,
      }).execute();
    }
  }

  Future<void> _saveMovieToLocalStorage(Movie movie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String movieStorage = movie.watched ? "collectionMovies" : "wishlistMovies";
    String? moviesString = prefs.getString(movieStorage);
    List<Movie> movies = [];

    if (moviesString != null) {
      List<dynamic> jsonList = jsonDecode(moviesString);
      movies = jsonList.map((m) => Movie.fromJson(m)).toList();
    }

    // Update the movie in the local storage
    int index = movies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      movies[index] = movie; // Update existing movie
    } else {
      movies.add(movie); // Add new movie if not found
    }

    await prefs.setString(movieStorage, jsonEncode(movies));
  }

  Future<void> updateMovie(Movie movie) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Update in local storage if no internet
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String movieStorage = movie.watched ? "collectionMovies" : "wishlistMovies";
      String? moviesString = prefs.getString(movieStorage);
      List<Movie> movies = [];

      if (moviesString != null) {
        List<dynamic> jsonList = jsonDecode(moviesString);
        movies = jsonList.map((m) => Movie.fromJson(m)).toList();
      }

      // Update the movie in the local storage
      int index = movies.indexWhere((m) => m.id == movie.id);
      if (index != -1) {
        movies[index] = movie;
      } else {
        movies.add(movie); // If not found, add it
      }

      await prefs.setString(movieStorage, jsonEncode(movies));
    } else {
      // Update in database if internet is available
      await _supabaseClient
          .from('movies')
          .update({
            'movie_name': movie.movieName,
            'director_name': movie.directorName,
            'release_date': movie.releaseDate.toIso8601String(),
            'plot': movie.plot,
            'runtime': movie.runtime,
            'imdb_rating': movie.imdbRating,
            'writers': movie.writers,
            'actors': movie.actors,
            'image_link': movie.imageLink,
            'genres': movie.genres,
            'production_company': movie.productionCompany,
            'custom_sort_title': movie.customSortTitle,
            'watched': movie.watched,
            'watch_date': movie.watchDate?.toIso8601String(),
            'user_score': movie.userScore,
            'hype_score': movie.hypeScore
          })
          .eq('id', movie.id)
          .execute();
    }
  }

  Future<void> deleteMovie(String movieId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Delete from local storage if no internet
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String storage = 'collectionMovies'; // or 'wishlistMovies' based on context
      String? moviesString = prefs.getString(storage);
      
      if (moviesString != null) {
        List<dynamic> jsonList = jsonDecode(moviesString);
        List<Movie> movies = jsonList.map((m) => Movie.fromJson(m)).toList();
        movies.removeWhere((m) => m.id.toString() == movieId);
        await prefs.setString(storage, jsonEncode(movies));
      }
    } else {
      // Delete from database if internet is available
      await _supabaseClient
          .from('movies')
          .delete()
          .eq('id', movieId)
          .eq('user_email', currentEmail)
          .execute();
    }
  }

  Future<List<Movie>> getWishlistMovies() async {
    final response = await _supabaseClient
        .from('movies')
        .select()
        .eq('user_email', currentEmail)
        .eq('watched', false)
        .execute();

    List<Movie> movies = (response.data as List).map((movie) => Movie.fromJson(movie)).toList();
    
    // Save to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('wishlistMovies', jsonEncode(movies));

    return movies;
  }

  Future<List<Movie>> getCollectionMovies() async {
    final response = await _supabaseClient
        .from('movies')
        .select()
        .eq('user_email', currentEmail)
        .eq('watched', true)
        .execute();

    List<Movie> movies = (response.data as List).map((movie) => Movie.fromJson(movie)).toList();
    
    // Save to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('collectionMovies', jsonEncode(movies));

    return movies;
  }

  Future<void> syncLocalMovies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Sync collection movies
    String? collectionMoviesString = prefs.getString('collectionMovies');
    if (collectionMoviesString != null) {
      List<dynamic> jsonList = jsonDecode(collectionMoviesString);
      List<Movie> localCollectionMovies = jsonList.map((m) => Movie.fromJson(m)).toList();

      for (Movie movie in localCollectionMovies) {
        // Check if the movie already exists in the database
        final response = await _supabaseClient
            .from('movies')
            .select()
            .eq('movie_name', movie.movieName)
            .eq('user_email', movie.userEmail)
            .eq('watched', true)
            .execute();

        if (response.data.isEmpty) {
          // If it doesn't exist, add it to the database
          await addMovie(movie);
        } else {
          // If it exists, update it
          await updateMovie(movie);
        }
      }
    }

    // Sync wishlist movies
    String? wishlistMoviesString = prefs.getString('wishlistMovies');
    if (wishlistMoviesString != null) {
      List<dynamic> jsonList = jsonDecode(wishlistMoviesString);
      List<Movie> localWishlistMovies = jsonList.map((m) => Movie.fromJson(m)).toList();

      for (Movie movie in localWishlistMovies) {
        // Check if the movie already exists in the database
        final response = await _supabaseClient
            .from('movies')
            .select()
            .eq('movie_name', movie.movieName)
            .eq('user_email', movie.userEmail)
            .eq('watched', false)
            .execute();

        if (response.data.isEmpty) {
          // If it doesn't exist, add it to the database
          await addMovie(movie);
        } else {
          // If it exists, update it
          await updateMovie(movie);
        }
      }
    }
  }
} 