class Movie {
  final String movieName;
  final String directorName;
  final DateTime releaseDate;
  final String? plot;
  final int? runtime;
  final double? imdbRating;
  final List<String>? writers;
  final List<String>? actors;
  bool watched;
  final String imageLink;
  final String userEmail;
  DateTime? watchDate;
  double? userScore;
  double? hypeScore;
  final List<String>? genres;
  final List<String>? productionCompany;
  final String? customSortTitle;
  final String? country;
  final double? popularity;
  final double? budget;
  final double? revenue;
  //final int customSortOrder;
 
  //delete writers
    /*"cast": [
        {"id": 123456, "name": "Tessa Thompson", "character": "Lady", "order": 1},
        {"id": 654321, "name": "Justin Theroux", "character": "Tramp", "order": 2}
      ],*/

  Movie({
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
    this.country,
    this.popularity,   
    this.budget,
    this.revenue,
  });

  Map<String, dynamic> toJson() {
    return {
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
    };
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
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
      productionCompany: json['production_companys'] != null ? List<String>.from(json['production_company']) : null,
      customSortTitle: json['custom_sort_title'],
      country: json['country'],
      popularity: json['popularity']?.toDouble(),
      budget: json['budget']?.toDouble(),
      revenue: json['revenue']?.toDouble(),
    );
  }
} 