import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie_model.dart';
import '../models/user_model.dart';

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
      ...movie.toJson(),
      'user_email': movie.userEmail,
    }).execute();
  }

  Future<void> updateMovie(Movie movie) async {
    await _supabaseClient
        .from('movies')
        .update(movie.toJson())
        .eq('movie_name', movie.movieName)
        .eq('user_email', currentEmail)
        .execute();
  }

  Future<void> deleteMovie(String movieName) async {
    await _supabaseClient
        .from('movies')
        .delete()
        .eq('movie_name', movieName)
        .eq('user_email', currentEmail)
        .execute();
  }

  Future<List<Movie>> getWishlistMovies() async {
    final response = await _supabaseClient
        .from('movies')
        .select()
        .eq('user_email', currentEmail)
        .eq('watched', false)
        .execute();
    return (response.data as List).map((movie) => Movie.fromJson(movie)).toList();
  }

  Future<List<Movie>> getCollectionMovies() async {
    final response = await _supabaseClient
        .from('movies')
        .select()
        .eq('user_email', currentEmail)
        .eq('watched', true)
        .execute();
    return (response.data as List).map((movie) => Movie.fromJson(movie)).toList();
  }
} 