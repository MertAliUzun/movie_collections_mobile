import 'package:flutter/material.dart';
import '../aux/genreMap.dart';

class PersonMoviesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> movies;

  const PersonMoviesWidget({Key? key, required this.movies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Adjust the number of columns as needed
        childAspectRatio: 0.5, // Adjust the aspect ratio as needed
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return Card(
          color: const Color.fromARGB(255, 44, 50, 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight* 0.01,),
              movie['poster_path'] != null
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                      fit: BoxFit.cover,
                      height: 150,
                    )
                  : const Icon(Icons.movie, size: 100, color: Colors.white54),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  movie['title'] ?? 'No Title',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              if (movie['genre_ids'] != null && movie['release_date'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Text(
                        '${movie['genre_ids'].map((id) => genreMap[id]).take(3).join(', ')}',
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.01,),
                      Text(
                        '${movie['release_date'].split('-')[0]}',
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
} 