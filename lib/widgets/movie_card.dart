import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isFromWishlist;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String viewType;
  final bool isSelected;
  final bool selectionMode;

  const MovieCard({
    super.key,
    required this.movie,
    required this.isFromWishlist,
    required this.onTap,
    required this.onLongPress,
    required this.viewType,
    this.isSelected = false,
    this.selectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: Colors.blue, width: .7) : null,
        ),
        child: viewType.contains("List") ? Container(
          height: viewType == "List" ? screenHeight * 0.12 : screenHeight *0.07,
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
                  errorBuilder: (context, error, stackTrace) => //const Icon(Icons.movie),
                  Image.asset(
                    'assets/images/placeholder_poster.png',
                    width: viewType == "List" ? screenWidth * 0.20 : screenWidth * 0.13,
                    height: viewType == "List" ? screenHeight * 0.15 : screenHeight * 0.10,
                    fit: BoxFit.cover,
                    ), // Placeholder image
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
                            minRating: 0,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 10,
                            itemSize: 17,
                            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {
                              
                            },
                          ),
                        ),
                      if (isFromWishlist && viewType != "List(Small)")
                        Padding(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.5, 0, 0, 0),
                          child: RatingBar.builder(
                            ignoreGestures: true,
                            initialRating: movie.hypeScore ?? 0,
                            minRating: 0,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20,
                            itemBuilder: (context, _) => const Icon(Icons.local_fire_department, color: Colors.red),
                            onRatingUpdate: (rating) {
                              
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          movie.movieName,
                          style: TextStyle(fontSize: screenWidth * 0.035 , fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9)),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.001,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              movie.directorName,
                              style: TextStyle(fontSize: screenWidth * 0.027, color: Colors.white70),
                            ),
                          ),
                          if(viewType == "List(Small)" && selectionMode)
                          Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue : null,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSelected ? Icons.check : Icons.radio_button_unchecked,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (viewType != "List(Small)")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                movie.releaseDate.day.toString() + '/' + movie.releaseDate.month.toString() + '/' + movie.releaseDate.year.toString(),
                                style: TextStyle(fontSize: screenWidth * 0.028 , color: Colors.white54),
                              ),
                            ),
                            if (selectionMode)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue : null,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSelected ? Icons.check : Icons.radio_button_unchecked,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: screenHeight * 0.001,),
                      const SizedBox(
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
          child:  Card(
            color: const Color.fromARGB(255, 44, 50, 60),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0), // Sol üst köşe
                topRight: Radius.circular(16.0), // Sağ üst köşe
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0), // Sol üst köşe
                      topRight: Radius.circular(16.0), // Sağ üst köşe
                    ),
                    child: Image.network(
                      movie.imageLink,
                      width: screenWidth * 0.35, // Adjust width for grid layout
                      height: screenHeight * 0.22, // Adjust height for grid layout
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => //const Icon(Icons.movie),
                      Image.asset(
                        'assets/images/placeholder_poster.png',
                        width: screenWidth * 0.35, // Adjust width for grid layout
                        height: screenHeight * 0.22, // Adjust height for grid layout
                        fit: BoxFit.cover,
                        ),
                    ),
                  ),
                if(selectionMode)
                Positioned(
                    bottom: screenHeight * 0.01,
                    right: screenWidth * 0.001,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : null,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSelected ? Icons.check : Icons.radio_button_unchecked,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  ]
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(7, screenHeight * 0.01, 7, 0),
                  child: Text(
                    movie.movieName,
                    style:  TextStyle(color: Colors.white.withOpacity(0.9), fontSize: screenWidth * 0.027, fontWeight: FontWeight.bold), 
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005,),
                if (!isFromWishlist)
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.015),
                    child: RatingBar.builder(
                      ignoreGestures: true,
                      initialRating: movie.userScore ?? 0,
                      minRating: 0,
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
                    padding: EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.015),
                    child: RatingBar.builder(
                      ignoreGestures: true,
                      initialRating: movie.hypeScore ?? 0,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 15,
                      itemBuilder: (context, _) => const Icon(Icons.local_fire_department, color: Colors.red),
                      onRatingUpdate: (rating) {
                        
                      },
                    ),
                  ),
              ],
            ),
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
              Stack(
                children: [
                  
                  ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    movie.imageLink,
                    width: screenWidth * 0.28, // Adjust width for grid layout
                    height: screenHeight * 0.23, // Adjust height for grid layout
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => //const Icon(Icons.movie),
                    Image.asset(
                      'assets/images/placeholder_poster.png',
                      width: screenWidth * 0.28, // Adjust width for grid layout
                      height: screenHeight * 0.23, // Adjust height for grid layout
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if(selectionMode)
                Positioned(
                    bottom: screenHeight * 0.01,
                    right: screenWidth * 0.001,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : null,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSelected ? Icons.check : Icons.radio_button_unchecked,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ] 
              ),
              SizedBox(height: screenHeight*0.03,),
            ],
          ),
        ),
      ),
    );
  }
} 