import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isFromWishlist;

  const MovieCard({super.key, required this.movie, required this.isFromWishlist});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
double screenHeight = MediaQuery.of(context).size.height;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      child: Container(
        height: 100,
        child: Row(
          children: [
            // Film afişi
            ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.network(
                movie.imageLink,
                width: screenWidth * 0.15,
                height: screenHeight * 0.15,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie),
              ),
            ),
            // Film adı ve yönetmen adı
               Expanded(
                  child: Container(
                    color: const Color.fromARGB(255, 30, 35, 45),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!isFromWishlist)
                          Padding(
                            padding: EdgeInsets.fromLTRB(screenWidth * 0.35, 0, 0, 0),
                            child: RatingBar.builder(
                              initialRating: movie.userScore ?? 0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 10,
                              itemSize: 20,
                              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                          ),
                        if (isFromWishlist)
                        SizedBox(height: screenHeight * 0.01,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            movie.movieName,
                            style: TextStyle(fontSize: screenWidth * 0.043 , fontWeight: FontWeight.bold, color: Colors.white70),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '${movie.directorName}',
                            style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.white60),
                          ),
                        ),
                        if (!isFromWishlist)
                        SizedBox(height: screenHeight * 0.02,),
                        if (isFromWishlist)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            movie.releaseDate.day.toString() + '/' + movie.releaseDate.month.toString() + '/' + movie.releaseDate.year.toString(),
                            style: TextStyle(fontSize: screenWidth * 0.028 , color: Colors.white54),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01,),
                        SizedBox(
                          height: 0,
                          child: Divider(
                                              color: Colors.white30,
                                              thickness: 1,
                                      ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
} 