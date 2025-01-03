import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isFromWishlist;
  final VoidCallback onTap;
  final String viewType;
    const MovieCard({
    super.key,
    required this.movie,
    required this.isFromWishlist,
    required this.onTap,
    required this.viewType,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: viewType.contains("List") ? Container(
        height: viewType == "List" ? screenHeight * 0.11 : screenHeight *0.07,
        child: Row(
          children: [
            // Film afişi
            ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.network(
                movie.imageLink,
                width: viewType == "List" ? screenWidth * 0.20 : screenWidth * 0.13,
                height: viewType == "List" ? screenHeight * 0.15 : screenHeight * 0.10,
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
                        if (!isFromWishlist && viewType != "List(Small)")
                          Padding(
                            padding: EdgeInsets.fromLTRB(screenWidth * 0.3, 0, 0, 0),
                            child: RatingBar.builder(
                              //unratedColor: Colors.blueGrey.withOpacity(0.6),
                              ignoreGestures: true,
                              initialRating: movie.userScore ?? 0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 10,
                              itemSize: 17,
                              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                          ),
                        if (isFromWishlist && viewType != "List(Small)")
                          Padding(
                            padding: EdgeInsets.fromLTRB(screenWidth * 0.5, 0, 0, 0),
                            child: RatingBar.builder(
                              ignoreGestures: true,
                              initialRating: movie.hypeScore ?? 0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 20,
                              itemBuilder: (context, _) => const Icon(Icons.local_fire_department, color: Colors.red),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            movie.movieName,
                            style: TextStyle(fontSize: screenWidth * 0.04 , fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9)),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '${movie.directorName}',
                            style: TextStyle(fontSize: screenWidth * 0.027, color: Colors.white70),
                          ),
                        ),
                        if (viewType != "List(Small)")
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
      ) : viewType== "Card" ? 
      Container(
        height: 200,
        width: double.infinity,
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: screenHeight * 0.005,),
            if (!isFromWishlist)
                        Padding(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0, 0, 0, 0),
                          child: RatingBar.builder(
                            ignoreGestures: true,
                            initialRating: movie.userScore ?? 0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 10,
                            itemSize: 10 ,
                            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                        ),
            if (isFromWishlist)
                        Padding(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0, 0, 0, 0),
                          child: RatingBar.builder(
                            ignoreGestures: true,
                            initialRating: movie.hypeScore ?? 0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 15,
                            itemBuilder: (context, _) => const Icon(Icons.local_fire_department, color: Colors.red),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                        ),
            SizedBox(height: screenHeight * 0.01,),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                movie.imageLink,
                width: screenWidth * 0.25, // Adjust width for grid layout
                height: screenHeight * 0.15, // Adjust height for grid layout
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Text(
                movie.movieName,
                style:  TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold), textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

      )//: viewType == "Poster" ?
      : Container(
        height: 200,
        width: double.infinity,
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: screenHeight * 0.01,),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                movie.imageLink,
                width: screenWidth * 0.28, // Adjust width for grid layout
                height: screenHeight * 0.23, // Adjust height for grid layout
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie),
              ),
            ),
            SizedBox(height: screenHeight*0.03,),
          ],
        ),
      
      ),
    );
  }
} 