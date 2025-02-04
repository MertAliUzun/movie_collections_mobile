import '../models/movie_model.dart';

Map<String, List<Movie>> groupByDirector(List<Movie> movies) {
  Map<String, List<Movie>> groupedMovies = {};

  for (var movie in movies) {
    // Split director names by comma and trim whitespace
    List<String> directors = movie.directorName.split(',').map((name) => name.trim()).toList();
    for (var director in directors) {
      if (!groupedMovies.containsKey(director)) {
        groupedMovies[director] = [];
      }
      groupedMovies[director]!.add(movie);
    }
  }

  return groupedMovies;
}

Map<String, List<Movie>> groupByGenre(List<Movie> movies) {
  Map<String, List<Movie>> groupedMovies = {};

  for (var movie in movies) {
    for (var genre in movie.genres!) {
      if (!groupedMovies.containsKey(genre)) {
        groupedMovies[genre] = [];
      }
      groupedMovies[genre]!.add(movie);
    }
  }

  return groupedMovies;
}
Map<String, List<Movie>> groupByYear(List<Movie> movies, String yearType) {
  Map<String, List<Movie>> groupedMovies = {};

  for (var movie in movies) {
    String year = movie.watchDate!.year.toString(); 
    if(yearType == 'Release Date') { year = movie.releaseDate.year.toString(); }
   
    
    // Eğer grup yoksa oluştur
    if (!groupedMovies.containsKey(year)) {
      groupedMovies[year] = [];
    }
    
    // Filmi ilgili yıl grubuna ekle
    groupedMovies[year]!.add(movie);
  }

  return groupedMovies;
}


