import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  final String _viewType;
  final String _groupByText;
  final String _sortBy;
  final ValueChanged<String> _changeViewType;
  final ValueChanged<String> _toggleGroupBy;
  final ValueChanged<String> _onSortByChanged;

  DrawerWidget({
    required String viewType,
    required String groupByText,
    required String sortBy,
    required ValueChanged<String> changeViewType,
    required ValueChanged<String> toggleGroupBy,
    required ValueChanged<String> onSortByChanged,
  })  : _viewType = viewType,
        _groupByText = groupByText,
        _changeViewType = changeViewType,
        _toggleGroupBy = toggleGroupBy,
        _sortBy = sortBy,
        _onSortByChanged = onSortByChanged;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> sortingOptions = [
      const DropdownMenuItem(value: 'movieName', child: Text('Film Adı')),
      const DropdownMenuItem(value: 'releaseDate', child: Text('Çıkış Tarihi')),
      const DropdownMenuItem(value: 'directorName', child: Text('Yönetmen')),
      const DropdownMenuItem(value: 'imdbRating', child: Text('IMDB Puanı')),
      const DropdownMenuItem(value: 'runtime', child: Text('Süre')),


    ];
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top),
      width: screenWidth * 0.7,
      child: Drawer(
        backgroundColor: Color.fromARGB(255, 44, 50, 60),
        child: ListView(
          children: [
            DrawerHeader(child: Icon(Icons.home, size: 50)),
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
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.15, 0, 0, 0),
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        underline: SizedBox(),
                        onChanged: (Object? newValue) {
                          if (newValue is String) {
                            _changeViewType(newValue);
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
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.225, 0, 0, 0),
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        underline: SizedBox(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _toggleGroupBy(newValue);
                          }
                        },
                        items: ['None', 'Director', 'Genre'].map((String choice) {
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
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
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
                          }
                        },
                        items: sortingOptions,
                      ),
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
