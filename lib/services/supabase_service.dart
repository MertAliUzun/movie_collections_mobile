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

    // After adding the movie, update local storage
    await _updateLocalStorageWithMovie(movie);
  }

  Future<void> _updateLocalStorageWithMovie(Movie movie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String movieStorage = movie.watched ? "collectionMovies" : "wishlistMovies";
    String? moviesString = prefs.getString(movieStorage);
    List<Movie> movies = [];

    if (moviesString != null) {
      List<dynamic> jsonList = jsonDecode(moviesString);
      movies = jsonList.map((m) => Movie.fromJson(m)).toList();
    }

    // Check for duplicates
    if (!movies.any((m) => m.id == movie.id)) {
      movies.add(movie);
      await prefs.setString(movieStorage, jsonEncode(movies));
    }
  }

  Future<void> updateMovie(Movie movie) async {
    final response = await _supabaseClient
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

  Future<void> deleteMovie(String movieId) async {
    try {
      await _supabaseClient
          .from('movies')
          .delete()
          .eq('id', movieId)
          .eq('user_email', currentEmail)
          .execute();
    } catch (e) {
      throw Exception('Failed to delete movie: $e');
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
        }
      }
    }
  }
} 