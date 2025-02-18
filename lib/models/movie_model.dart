import 'package:hive/hive.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 0)
class Movie {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String movieName;
  
  @HiveField(2)
  final String directorName;
  
  @HiveField(3)
  final DateTime releaseDate;
  
  @HiveField(4)
  final String? plot;
  
  @HiveField(5)
  final int? runtime;
  
  @HiveField(6)
  final double? imdbRating;
  
  @HiveField(7)
  final List<String>? writers;
  
  @HiveField(8)
  final List<String>? actors;
  
  @HiveField(9)
  bool watched;
  
  @HiveField(10)
  final String imageLink;
  
  @HiveField(11)
  String userEmail;
  
  @HiveField(12)
  DateTime? watchDate;
  
  @HiveField(13)
  double? userScore;
  
  @HiveField(14)
  double? hypeScore;
  
  @HiveField(15)
  final List<String>? genres;
  
  @HiveField(16)
  final List<String>? productionCompany;
  
  @HiveField(17)
  final String? customSortTitle;

  @HiveField(18)
  final String? country;

  @HiveField(19)
  final double? popularity;

  @HiveField(20)
  final double? budget;

  @HiveField(21)
  final double? revenue;

  @HiveField(22)
  final bool? toSync;

  @HiveField(23)
  final int? watchCount;

  //delete writers
    /*"cast": [
        {"id": 123456, "name": "Tessa Thompson", "character": "Lady", "order": 1},
        {"id": 654321, "name": "Justin Theroux", "character": "Tramp", "order": 2}
      ],*/

  Movie({
    required this.id,
    required this.movieName,
    required this.directorName,
    required this.releaseDate,
    this.plot,
    this.runtime,
    this.imdbRating,
    this.writers,
    this.actors,
    required this.watched,
    required this.imageLink,
    required this.userEmail,
    this.watchDate,
    this.userScore,
    this.hypeScore,
    this.genres,
    this.productionCompany,
    this.customSortTitle,
    this.budget,
    this.country,
    this.popularity,
    this.revenue,
    this.toSync = false,
    this.watchCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie_name': movieName,
      'director_name': directorName,
      'release_date': releaseDate.toIso8601String(),
      'plot': plot,
      'runtime': runtime,
      'imdb_rating': imdbRating,
      'writers': writers,
      'actors': actors,
      'watched': watched,
      'image_link': imageLink,
      'user_email': userEmail,
      'watch_date': watchDate?.toIso8601String(),
      'user_score': userScore,
      'hype_score': hypeScore,
      'genres': genres,
      'production_company': productionCompany,
      'custom_sort_title' : customSortTitle,
      'country' : country,
      'popularity': popularity,
      'budget' : budget,
      'revenue' : revenue,
      'toSync': toSync,
      'watchCount': watchCount,
    };
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      movieName: json['movie_name'],
      directorName: json['director_name'],
      releaseDate: DateTime.parse(json['release_date']),
      plot: json['plot'],
      runtime: json['runtime'],
      imdbRating: json['imdb_rating']?.toDouble(),
      writers: json['writers'] != null ? List<String>.from(json['writers']) : null,
      actors: json['actors'] != null ? List<String>.from(json['actors']) : null,
      watched: json['watched'],
      imageLink: json['image_link'],
      userEmail: json['user_email'],
      watchDate: json['watch_date'] != null ? DateTime.parse(json['watch_date']) : null,
      userScore: json['user_score']?.toDouble(),
      hypeScore: json['hype_score']?.toDouble(),
      genres: json['genres'] != null ? List<String>.from(json['genres']) : null,
      productionCompany: json['production_company'] != null ? List<String>.from(json['production_company']) : null,
      customSortTitle: json['custom_sort_title'],
      country: json['country'],
      popularity: json['popularity']?.toDouble(),
      budget: json['budget']?.toDouble(),
      revenue: json['revenue']?.toDouble(),
      toSync: json['toSync'] ?? false,
      watchCount: json['watchCount']
    );
  }
} 