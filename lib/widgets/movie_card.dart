import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../sup/screen_util.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isFromWishlist;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String viewType;
  final bool isSelected;
  final bool selectionMode;
  final bool hasImportedSame;

  const MovieCard({
    super.key,
    required this.movie,
    required this.isFromWishlist,
    required this.onTap,
    required this.onLongPress,
    required this.viewType,
    this.isSelected = false,
    this.selectionMode = false,
    this.hasImportedSame = false,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = ScreenUtil.isTablet(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: hasImportedSame ? Colors.amber : Colors.blue, width: isTablet ? 1.0 : 0.7) : null,
        ),
        child: viewType.contains("List") ? Container(
          height: viewType == "List" 
            ? ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.12)
            : ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.07),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: Image.network(
                  movie.imageLink,
                  width: ScreenUtil.getAdaptiveCardWidth(context, viewType == "List" ? screenWidth * 0.20 : screenWidth * 0.13),
                  height: ScreenUtil.getAdaptiveCardHeight(context, viewType == "List" ? screenHeight * 0.15 : screenHeight * 0.10),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  Image.asset(
                    'assets/images/placeholder_poster.png',
                    width: ScreenUtil.getAdaptiveCardWidth(context, viewType == "List" ? screenWidth * 0.20 : screenWidth * 0.13),
                    height: ScreenUtil.getAdaptiveCardHeight(context, viewType == "List" ? screenHeight * 0.15 : screenHeight * 0.10),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
                            itemSize: ScreenUtil.getAdaptiveIconSize(context, 15.5),
                            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {},
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
                            itemSize: ScreenUtil.getAdaptiveIconSize(context, 20),
                            itemBuilder: (context, _) => const Icon(Icons.local_fire_department, color: Colors.red),
                            onRatingUpdate: (rating) {},
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          movie.movieName,
                          style: TextStyle(
                            fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.035),
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9)
                          ),
                          maxLines: 1,
                        ),
                      ),
                      //SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.001)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              movie.directorName,
                              style: TextStyle(
                                fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.027),
                                color: Colors.white70
                              ),
                            ),
                          ),
                          if(viewType == "List(Small)" && selectionMode)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? hasImportedSame ? Colors.amber : Colors.blue : null,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSelected ? hasImportedSame ? Icons.warning_amber : Icons.check : Icons.radio_button_unchecked,
                                  color: Colors.white,
                                  size: ScreenUtil.getAdaptiveIconSize(context, 20),
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
                              padding: ScreenUtil.getAdaptiveLTRBPadding(context, bottom: 5),
                              child: Text(
                                '${movie.releaseDate.day}/${movie.releaseDate.month}/${movie.releaseDate.year}',
                                style: TextStyle(
                                  fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.028),
                                  color: Colors.white54
                                ),
                              ),
                            ),
                            if (selectionMode)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? hasImportedSame ? Colors.amber : Colors.blue : null,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isSelected ? hasImportedSame ? Icons.warning_amber : Icons.check : Icons.radio_button_unchecked,
                                    color: Colors.white,
                                    size: ScreenUtil.getAdaptiveIconSize(context, 20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      //SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.001)),
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
        ) : viewType == "Card" ? 
        Container(
          height: ScreenUtil.getAdaptiveCardHeight(context, 200),
          width: double.infinity,
          child: Card(
            color: const Color.fromARGB(255, 44, 50, 60),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
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
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                      child: Image.network(
                        movie.imageLink,
                        width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.35),
                        height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.22),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        Image.asset(
                          'assets/images/placeholder_poster.png',
                          width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.35),
                          height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.22),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if(selectionMode)
                      Positioned(
                        bottom: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.01),
                        right: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.001),
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
                              size: ScreenUtil.getAdaptiveIconSize(context, 20),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(7, ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.01), 7, 0),
                  child: Text(
                    movie.movieName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.027),
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.005)),
                if (!isFromWishlist)
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.015)),
                    child: RatingBar.builder(
                      ignoreGestures: true,
                      initialRating: movie.userScore ?? 0,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 10,
                      itemSize: ScreenUtil.getAdaptiveIconSize(context, 9),
                      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {},
                    ),
                  ),
                if (isFromWishlist)
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.015)),
                    child: RatingBar.builder(
                      ignoreGestures: true,
                      initialRating: movie.hypeScore ?? 0,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: ScreenUtil.getAdaptiveIconSize(context, 15),
                      itemBuilder: (context, _) => const Icon(Icons.local_fire_department, color: Colors.red),
                      onRatingUpdate: (rating) {},
                    ),
                  ),
              ],
            ),
          ),
        )//: viewType == "Poster" ?
        : Container(
          height: ScreenUtil.getAdaptiveCardHeight(context, 200),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.01)),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      movie.imageLink,
                      width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.28),
                      height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.23),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      Image.asset(
                        'assets/images/placeholder_poster.png',
                        width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.28),
                        height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.23),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if(selectionMode)
                    Positioned(
                      bottom: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.01),
                      right: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.001),
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
                            size: ScreenUtil.getAdaptiveIconSize(context, 20),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.03)),
            ],
          ),
        ),
      ),
    );
  }
} 