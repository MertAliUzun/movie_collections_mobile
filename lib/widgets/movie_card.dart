import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isFromWishlist;

  const MovieCard({super.key, required this.movie, required this.isFromWishlist});

  @override
  Widget build(BuildContext context) {
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
                width: 60,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie),
              ),
            ),
            const SizedBox(width: 0.0),
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
                            padding: const EdgeInsets.fromLTRB(150, 0, 0, 0),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            movie.movieName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
                          ),
                        ),
                        SizedBox(height: 5,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Yönetmen: ${movie.directorName}',
                            style: const TextStyle(fontSize: 13, color: Colors.white54),
                          ),
                        ),
                        SizedBox(height: 15,),
                        SizedBox(
                          height: 0,
                          child: Divider(
                                              color: Colors.black,
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