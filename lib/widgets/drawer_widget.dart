import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../screens/edit_movie_screen.dart';

class DrawerWidget extends StatelessWidget {
  final String _viewType;
  final String _groupByText;
  final String _sortBy;
  final String _sortDir;
  final bool _isFromWishlist;
  final List<Movie> _movies;
  final ValueChanged<String> _changeViewType;
  final ValueChanged<String> _toggleGroupBy;
  final ValueChanged<String> _onSortByChanged;
  final ValueChanged<String> _onSortDirChanged;
  final String? userPicture; // Kullanıcı profil resmi
  final String? userId; 
  final String? userEmail; 
  final String? userName;

  DrawerWidget({
    required String viewType,
    required String groupByText,
    required String sortBy,
    required String sortDir,
    required bool isFromWishlist,
    required List<Movie> movies,
    required ValueChanged<String> changeViewType,
    required ValueChanged<String> toggleGroupBy,
    required ValueChanged<String> onSortByChanged,
    required ValueChanged<String> onSortDirChanged,
    this.userPicture, // Kullanıcı profil resmini al
    this.userEmail,
    this.userId,
    this.userName
  })  : _viewType = viewType,
        _groupByText = groupByText,
        _changeViewType = changeViewType,
        _toggleGroupBy = toggleGroupBy,
        _sortBy = sortBy,
        _onSortByChanged = onSortByChanged,
        _onSortDirChanged = onSortDirChanged,
        _sortDir = sortDir,
        _isFromWishlist = isFromWishlist,
        _movies = movies;

  Movie? _getRandomMovie(BuildContext context) {
    final random = Random();
    
    // Koşula göre filtreleme yap
    List<Movie> filteredMovies = _isFromWishlist
        ? _movies.where((movie) => !movie.watched).toList() // watched == false
        : _movies.where((movie) => movie.watched).toList(); // watched == true
  
    if (filteredMovies.isEmpty) {
      // Eğer filtrelenmiş listede film yoksa, Snackbar göster
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: 'Failure!', 
          message: 'Unable to Detect Movies!', 
          contentType: ContentType.failure, 
          inMaterialBanner: true,
        ), 
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);

      return null; // Hiçbir film bulunamadıysa null döndür
    }
  
    // Rastgele bir film seç
    return filteredMovies[random.nextInt(filteredMovies.length)];
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> sortingOptions = [
      const DropdownMenuItem(value: 'movieName', child: Text('Title')),
      const DropdownMenuItem(value: 'releaseDate', child: Text('Release Date')),
      const DropdownMenuItem(value: 'directorName', child: Text('Director')),
      const DropdownMenuItem(value: 'imdbRating', child: Text('IMDB Rating')),
      const DropdownMenuItem(value: 'runtime', child: Text('Runtime')),
    ];
    if (_isFromWishlist) {
      sortingOptions.add(const DropdownMenuItem(value: 'hypeScore', child: Text('Hype Score')));
    } else {
      sortingOptions.add(const DropdownMenuItem(value: 'userScore', child: Text('User Score')));
      sortingOptions.add(const DropdownMenuItem(value: 'watchDate', child: Text('Watch Date')));
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top),
      width: screenWidth * 0.7,
      child: Drawer(
        backgroundColor: Color.fromARGB(255, 44, 50, 60),
        child: ListView(
          children: [
            DrawerHeader(
              child: userPicture != null
                  ? Column(
                    children: [
                      ClipOval(
                         child: Image.network(
                           userPicture!,
                           fit: BoxFit.scaleDown, // Resmi çerçeveye göre ölçeklendirir
                           width: 90, // Çap kadar genişlik
                           height: 90, // Çap kadar yükseklik
                         ),
                       ),
                       Padding(
                         padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                         child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.white),
                            children: [
                              TextSpan(
                                text: 'Welcome, ',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              TextSpan(
                                text: userName!,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                       ),
                    ],
                  )
                  : IconButton(
                icon: Icon(Icons.login, size: 50),
                onPressed: () {
                  // Giriş yapma fonksiyonunuzu burada çağırın
                  //loginFunction();
                },
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View As',
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: screenWidth * 0.55,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                      child: DropdownButton<String>(
                        value: _viewType,
                        icon: Padding(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.16, 0, 0, 0),
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        underline: SizedBox(),
                        onChanged: (Object? newValue) {
                          if (newValue is String) {
                            _changeViewType(newValue);
                            Navigator.of(context).pop();
                          }
                        },
                        items: ['List', 'List(Small)', 'Card', 'Poster'].map((String choice) {
                          return DropdownMenuItem<String>(
                            value: choice,
                            child: Text(
                              choice,
                              style: TextStyle(fontSize: screenWidth * 0.055, color: Colors.white70),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Group By',
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: screenWidth * 0.55,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                      child: DropdownButton<String>(
                        value: _groupByText,
                        icon: Padding(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.11, 0, 0, 0),
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        underline: SizedBox(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _toggleGroupBy(newValue);
                            Navigator.of(context).pop();
                          }
                        },
                        items: ['None', 'Director', 'Genre', 'Release Year', if (!_isFromWishlist) 'Watch Year',].map((String choice) {
                          return DropdownMenuItem<String>(
                            value: choice,
                            child: Text(
                              choice,
                              style: TextStyle(fontSize: screenWidth * 0.055, color: Colors.white70),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort By',
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: screenWidth * 0.55,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.02, 0, 0, 0),
                      child: DropdownButton<String>(
                        value: _sortBy,
                        icon: Padding(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.14, 0, 0, 0),
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.055,),
                        underline: SizedBox(),
                        onChanged: (Object? newValue) {
                          if (newValue is String) {
                            _onSortByChanged(newValue);
                            Navigator.of(context).pop();
                          }
                        },
                        items: sortingOptions,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Sort ',
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold),
                      ),
                      Icon(_sortDir == 'Ascending' ? Icons.north : Icons.south , color: Colors.white, size: 18,),
                    ],
                  ),
                  Container(
                    width: screenWidth * 0.55,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                      child: DropdownButton<String>(
                        value: _sortDir,
                        icon: Padding(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.14, 0, 0, 0),
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.055,),
                        underline: SizedBox(),
                        onChanged: (Object? newValue) {
                          if (newValue is String) {
                            _onSortDirChanged(newValue);
                            Navigator.of(context).pop();
                          }
                        },
                        items: ['Ascending', 'Descending'].map((String choice) {
                          return DropdownMenuItem<String>(
                            value: choice,
                            child: Text(
                              choice,
                              style: TextStyle(fontSize: screenWidth * 0.055, color: Colors.white70),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Column(
                children: [
                  Container(
                    width: screenWidth * 0.45,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.03, 0, screenHeight * 0.01),
                      child: TextButton(onPressed:() {
                        final movie = _getRandomMovie(context);
                        if (movie == null)
                        Navigator.of(context).pop();
                        if (movie != null)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMovieScreen(isFromWishlist: _isFromWishlist, movie: movie, userEmail: userEmail,),
                          ),
                        );
                      },style: TextButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white,
                          width: .3,
                        ),
                        backgroundColor: const Color.fromARGB(255, 34, 40, 50),),  
                        child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Random Movie', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.039),),
                            SizedBox(width: screenWidth * 0.03,),
                            Icon(size: screenWidth * 0.055,
                            _isFromWishlist ? Icons.bookmark : Icons.movie,  
                             color: _isFromWishlist ? Colors.red : Colors.amber,),
                          ],
                        ), 
                      )),
                    ),
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
