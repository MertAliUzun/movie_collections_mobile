class Movie {
  final String movieName;
  final String directorName;
  final DateTime releaseDate;
  final String? plot;
  final int? runtime;
  final double? imdbRating;
  final double? rtRating;
  final List<String>? writers;
  final List<String>? actors;
  bool watched;
  final String imageLink;
  final String userEmail;
  DateTime? watchDate;
  double? userScore;
  double? hypeScore;
  //final List<String>? genres;
  //final double? popularity;
  //final String? productionCompany;
  /*"cast": [
        {"id": 123456, "name": "Tessa Thompson", "character": "Lady", "order": 1},
        {"id": 654321, "name": "Justin Theroux", "character": "Tramp", "order": 2}
      ],*/
  //final int customSortOrder;
  //final double? budget;
  //final double? revenue;

  Movie({
    required this.movieName,
    required this.directorName,
    required this.releaseDate,
    this.plot,
    this.runtime,
    this.imdbRating,
    this.rtRating,
    this.writers,
    this.actors,
    required this.watched,
    required this.imageLink,
    required this.userEmail,
    this.watchDate,
    this.userScore,
    this.hypeScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'movie_name': movieName,
      'director_name': directorName,
      'release_date': releaseDate.toIso8601String(),
      'plot': plot,
      'runtime': runtime,
      'imdb_rating': imdbRating,
      'rt_rating': rtRating,
      'writers': writers,
      'actors': actors,
      'watched': watched,
      'image_link': imageLink,
      'user_email': userEmail,
      'watch_date': watchDate?.toIso8601String(),
      'user_score': userScore,
      'hype_score': hypeScore,
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
      rtRating: json['rt_rating']?.toDouble(),
      writers: json['writers'] != null ? List<String>.from(json['writers']) : null,
      actors: json['actors'] != null ? List<String>.from(json['actors']) : null,
      watched: json['watched'],
      imageLink: json['image_link'],
      userEmail: json['user_email'],
      watchDate: json['watch_date'] != null ? DateTime.parse(json['watch_date']) : null,
      userScore: json['user_score']?.toDouble(),
      hypeScore: json['hype_score']?.toDouble(),
    );
  }
} 