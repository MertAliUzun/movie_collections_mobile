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
        childAspectRatio: 0.42, // Adjust the aspect ratio as needed
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
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(36.0), // Sol üst köşe
                topRight: Radius.circular(36.0), // Sağ üst köşe
              ),
            ),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [               
                movie['poster_path'] != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36.0), // Sol üst köşe
                          topRight: Radius.circular(36.0), // Sağ üst köşe
                        ),
                      child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                          fit: BoxFit.cover,
                          height: screenHeight * 0.22,
                          width: screenWidth * 0.35,
                        ),
                    )
                    : const Icon(Icons.movie, size: 100, color: Colors.white54),
                SizedBox(height: screenHeight *0.01,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 0, 2, 15),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          movie['title'] ?? 'No Title',
                          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      if(personType == 'Actor')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0,),
                        child: Text('(${movie['character']})', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 1,),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: screenHeight*0.005,),
                
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                    child: Column(
                      children: [
                        if(movie['genre_ids'] != null && movie['genre_ids'].any((id) => genreMap[id] != null))
                        Text(
                          '${movie['genre_ids'].map((id) => genreMap[id]).take(3).join(', ')}',
                          style:  TextStyle(color: Colors.white54, fontSize: screenWidth * 0.025),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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