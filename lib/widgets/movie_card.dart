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
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Row(
          children: [
            // Film afişi
            ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.network(
                movie.imageLink,
                width: 50,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie),
              ),
            ),
            const SizedBox(width: 16.0),
            // Film adı ve yönetmen adı
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isFromWishlist)
                      RatingBar.builder(
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
                    Text(
                      movie.movieName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Yönetmen: ${movie.directorName}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
} 