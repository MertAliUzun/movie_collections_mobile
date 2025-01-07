import 'package:flutter/material.dart';
import '../aux/genreMap.dart';

class PersonMoviesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> movies;
  final String personType;

  const PersonMoviesWidget({Key? key, required this.movies, required this.personType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Adjust the number of columns as needed
        childAspectRatio: 0.46, // Adjust the aspect ratio as needed
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () {
            // Navigate back with movie details
            Navigator.pop(context, movie['id']); // Pass the movie ID or details
          },
          child: Card(
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
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    movie['title'] ?? 'No Title',
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.028, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
                if(personType == 'Actor')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0,),
                  child: Text('(${movie['character']})', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025), textAlign: TextAlign.center,),
                ),
                SizedBox(height: screenHeight*0.005,),
                
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        if(movie['genre_ids'] != null && movie['genre_ids'].any((id) => genreMap[id] != null))
                        Text(
                          '${movie['genre_ids'].map((id) => genreMap[id]).take(3).join(', ')}',
                          style:  TextStyle(color: Colors.white54, fontSize: screenWidth * 0.025),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.001,),
                        if (movie['release_date'] != null)
                        Text(
                          '${movie['release_date'].split('-')[0]}',
                          style:  TextStyle(color: Colors.white54, fontSize: screenWidth * 0.025),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
} 