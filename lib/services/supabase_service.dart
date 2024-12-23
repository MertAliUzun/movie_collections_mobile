import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie_model.dart';
import '../models/user_model.dart';

class SupabaseService {
  final SupabaseClient _supabaseClient;

  SupabaseService(this._supabaseClient);

  String get currentUserName => 'test';

  Future<List<Movie>> getMovies() async {
    final response = await _supabaseClient
        .from('movies')
        .select()
        .eq('user_name', currentUserName)
        .execute();
    return (response.data as List).map((movie) => Movie.fromJson(movie)).toList();
  }

  Future<void> addMovie(Movie movie) async {
    await _supabaseClient.from('movies').insert({
      ...movie.toJson(),
      'user_name': currentUserName,
    }).execute();
  }

  Future<void> updateMovie(Movie movie) async {
    await _supabaseClient
        .from('movies')
        .update(movie.toJson())
        .eq('movie_name', movie.movieName)
        .eq('user_name', currentUserName)
        .execute();
  }

  Future<void> deleteMovie(String movieName) async {
    await _supabaseClient
        .from('movies')
        .delete()
        .eq('movie_name', movieName)
        .eq('user_name', currentUserName)
        .execute();
  }

  Future<List<Movie>> getWishlistMovies() async {
    final response = await _supabaseClient
        .from('movies')
        .select()
        .eq('user_name', currentUserName)
        .eq('watched', false)
        .execute();
    return (response.data as List).map((movie) => Movie.fromJson(movie)).toList();
  }

  Future<List<Movie>> getCollectionMovies() async {
    final response = await _supabaseClient
        .from('movies')
        .select()
        .eq('user_name', currentUserName)
        .eq('watched', true)
        .execute();
    return (response.data as List).map((movie) => Movie.fromJson(movie)).toList();
  }
} 