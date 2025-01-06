import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/models/movie_model.dart';
import '../aux/genreMap.dart';
import '../services/tmdb_service.dart';

class CompanyScreen extends StatefulWidget {
  final String companyName;

  const CompanyScreen({Key? key, required this.companyName}) : super(key: key);

  @override
  _CompanyScreenState createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final TmdbService _tmdbService = TmdbService();
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMoviesByCompany();
  }

  Future<void> _fetchMoviesByCompany() async {
    try {
      final results = await _tmdbService.searchCompany(widget.companyName);
      
      if (results.isNotEmpty) {
        final companyId = results[0]['id'];
        _movies = await _tmdbService.getMoviesByCompany(companyId);
        _movies = _movies.where((movie) => movie['poster_path'] != null).toList();
        
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (e.g., show a snackbar)
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        title: Center(child: Text(widget.companyName, style: TextStyle(color: Colors.white),)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movies.isNotEmpty
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: _movies.length,
                  itemBuilder: (context, index) {
                    final movie = _movies[index];
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
                )
              : const Center(child: Text('No movies found for this company.', style: TextStyle(color: Colors.white54))),
    );
  }
} 