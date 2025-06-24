import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:movie_collections_mobile/services/ad_service.dart';
import '../services/tmdb_service.dart';
import '../screens/director_screen.dart';
import '../sup/screen_util.dart';
import 'dart:async';

class PopularPeopleScreen extends StatefulWidget {
  final bool? isFromWishlist;
  final String? userEmail;
  final String systemLanguage;

  const PopularPeopleScreen({
    Key? key, 
    this.isFromWishlist,
    this.userEmail,
    required this.systemLanguage,
  }) : super(key: key);

  @override
  _PopularPeopleScreenState createState() => _PopularPeopleScreenState();
}

class _PopularPeopleScreenState extends State<PopularPeopleScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _debounce;
  List<Map<String, dynamic>> _searchResults = [];
  List<dynamic> _popularPeople = [];
  bool _isSearching = false;
  bool _isLoading = true;
  final _tmdbService = TmdbService();
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _loadPopularPeople();
    _adService.loadBannerAd(
      onAdLoaded: (ad) {
        setState(() {}); // UI'ı güncelle
      },
    );
    _adService.loadInterstitialAd(
      onAdLoaded: (ad) {
        setState(() {
          _adService.showInterstitialAd();
        });
      }
    );
  }

  Future<void> _loadPopularPeople() async {
    try {
      final people = await _tmdbService.getPopularPeople();
      if (mounted) {
        setState(() {
          _popularPeople = people;
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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (query.length >= 2) {
        setState(() {
          _isSearching = true;
        });
        try {
          final results = await _tmdbService.searchPeople(query);
          if (mounted) {
            setState(() {
              _searchResults = results;
              _isSearching = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isSearching = false;
            });
          }
        }
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
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
        scrolledUnderElevation: 0,
        title: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
              ),
              decoration: InputDecoration(
                hintText: S.of(context).searchPeople,
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white54,
                  size: ScreenUtil.getAdaptiveIconSize(context, 24),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ]
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: ScreenUtil.getAdaptiveIconSize(context, 24),
        ),
      ),
      body: Column(
        children: [
          
          if (_searchResults.isNotEmpty)
            Container(
              constraints: BoxConstraints(
                maxHeight: ScreenUtil.getAdaptiveCardHeight(context, 200),
              ),
              child: Card(
                color: const Color.fromARGB(255, 40, 45, 54),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final person = _searchResults[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(8.0),
                      leading: person['profile_path'] != null
                          ? Image.network(
                              'https://image.tmdb.org/t/p/w500${person['profile_path']}',
                              width: ScreenUtil.getAdaptiveCardWidth(context, 50),
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, color: Colors.white54),
                            )
                          : const Icon(Icons.person, color: Colors.white54),
                      title: Text(
                        person['name'],
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                        ),
                      ),
                      subtitle: Text(
                        person['known_for_department'] ?? 'Unknown',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 14),
                        ),
                      ),
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
                        _searchController.clear();
                        _searchResults = [];
                        _searchFocusNode.unfocus();
                      },
                    );
                  },
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                  children: [ GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 4 : 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
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
                          child: Card(
                            color: const Color.fromARGB(255, 44, 50, 60),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: person['profile_path'] != null
                                      ? Image.network(
                                          'https://image.tmdb.org/t/p/w500${person['profile_path']}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.person, color: Colors.white54, size: 50),
                                        )
                                      : const Icon(Icons.person, color: Colors.white54, size: 50),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          person['name'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil.getAdaptiveTextSize(context, 14),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          person['known_for_department'] == 'Acting' ? S.of(context).actor : 
                                          person['known_for_department'] == 'Directing' ? S.of(context).director :
                                          person['known_for_department'] == 'Producing' ? S.of(context).producer :
                                          person['known_for_department'] == 'Writing' ? S.of(context).writer  : S.of(context).actor,
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: ScreenUtil.getAdaptiveTextSize(context, 12),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if(_adService.bannerAd != null)
                            FutureBuilder<Widget>(
                future: _adService.showBannerAd(isTablet),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!;
                  }
                  return const SizedBox.shrink();
                },
                            ),
                  ]
                ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _adService.disposeAds();
    super.dispose();
  }
} 