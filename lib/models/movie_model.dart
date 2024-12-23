class Movie {
  //final String id;
  final String movieName;
  final String directorName;
  final DateTime releaseDate;
  final String plot;
  final int runtime;
  final double imdbRating;
  final double rtRating;
  final List<String> writers;
  final List<String> actors;
  final bool watched;
  final String imageLink;
  final String userName;

  Movie({
    //required this.id,
    required this.movieName,
    required this.directorName,
    required this.releaseDate,
    required this.plot,
    required this.runtime,
    required this.imdbRating,
    required this.rtRating,
    required this.writers,
    required this.actors,
    required this.watched,
    required this.imageLink,
    required this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      //'id': id,
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
      'user_name': userName,
    };
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      //id: json['id'],
      movieName: json['movie_name'],
      directorName: json['director_name'],
      releaseDate: DateTime.parse(json['release_date']),
      plot: json['plot'],
      runtime: json['runtime'],
      imdbRating: json['imdb_rating'].toDouble(),
      rtRating: json['rt_rating'].toDouble(),
      writers: List<String>.from(json['writers']),
      actors: List<String>.from(json['actors']),
      watched: json['watched'],
      imageLink: json['image_link'],
      userName: json['user_name'],
    );
  }
} 