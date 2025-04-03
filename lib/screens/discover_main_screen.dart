import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import '../services/tmdb_service.dart';
import '../sup/screen_util.dart';
import '../screens/popular_people_screen.dart';
import '../screens/director_screen.dart';

class DiscoverMainScreen extends StatefulWidget {
  final bool? isFromWishlist;
  final String? userEmail;
  final String? systemLanguage;

  const DiscoverMainScreen({
    Key? key,
    this.isFromWishlist,
    this.userEmail,
    this.systemLanguage,
  }) : super(key: key);

  @override
  _DiscoverMainScreenState createState() => _DiscoverMainScreenState();
}

class _DiscoverMainScreenState extends State<DiscoverMainScreen> {
  final _tmdbService = TmdbService();
  List<dynamic> _popularPeople = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPopularPeople();
  }

  Future<void> _loadPopularPeople() async {
    try {
      final people = await _tmdbService.getPopularPeople();
      if (mounted) {
        setState(() {
          // Sadece ilk 10 kişiyi al
          _popularPeople = people.take(10).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = ScreenUtil.isTablet(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        centerTitle: true,
        title: Text(
          'S.of(context).discover',
          style: TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: ScreenUtil.getAdaptiveIconSize(context, 24),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Popüler Kişiler Başlık
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PopularPeopleScreen(
                            isFromWishlist: widget.isFromWishlist,
                            userEmail: widget.userEmail,
                            systemLanguage: widget.systemLanguage,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'S.of(context).popularPeople',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white70,
                            size: ScreenUtil.getAdaptiveIconSize(context, 24),
                          )
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Popüler Kişiler Yatay Liste
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    height: isTablet ? 280 : 275,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _popularPeople.length,
                      itemBuilder: (context, index) {
                        final person = _popularPeople[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DirectorScreen(
                                  personName: person['name'],
                                  personType: person['known_for_department'],
                                  systemLanguage: widget.systemLanguage,
                                  isFromWishlist: widget.isFromWishlist,
                                  userEmail: widget.userEmail,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: isTablet ? 180 : 140,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: Card(
                              color: const Color.fromARGB(255, 44, 50, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                      child: person['profile_path'] != null
                                          ? Image.network(
                                              'https://image.tmdb.org/t/p/w500${person['profile_path']}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.person, color: Colors.white54, size: 50),
                                            )
                                          : Container(
                                              color: const Color.fromARGB(255, 54, 60, 70),
                                              child: const Icon(Icons.person, color: Colors.white54, size: 50),
                                            ),
                                    ),
                                  ),
                                  
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 44, 50, 60),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            person['name'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil.getAdaptiveTextSize(context, 14),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 32),
            
            // Buraya gelecekte eklenecek diğer keşif bölümleri için yer bırakıyoruz
            // ...
          ],
        ),
      ),
    );
  }
} 