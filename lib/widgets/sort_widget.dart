import 'package:flutter/material.dart';

class SortWidget extends StatelessWidget {
  final String sortBy;
  final bool isAscending;
  final Function(String) onSortByChanged;
  final Function(bool) onOrderChanged;
  final bool isFromWishlist;

  const SortWidget({
    Key? key,
    required this.sortBy,
    required this.isAscending,
    required this.onSortByChanged,
    required this.onOrderChanged,
    required this.isFromWishlist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a list of sorting options
    List<DropdownMenuItem<String>> sortingOptions = [
      const DropdownMenuItem(value: 'movieName', child: Text('Film Adı')),
      const DropdownMenuItem(value: 'releaseDate', child: Text('Çıkış Tarihi')),
      const DropdownMenuItem(value: 'directorName', child: Text('Yönetmen')),
      const DropdownMenuItem(value: 'imdbRating', child: Text('IMDB Puanı')),
      const DropdownMenuItem(value: 'rtRating', child: Text('Rotten Tomatoes Puanı')),
      const DropdownMenuItem(value: 'runtime', child: Text('Süre')),


    ];

    // Add userScore or hypeScore based on isFromWishlist
    if (isFromWishlist) {
      sortingOptions.add(const DropdownMenuItem(value: 'hypeScore', child: Text('Hype Puanı')));
    } else {
      sortingOptions.add(const DropdownMenuItem(value: 'userScore', child: Text('Kullanıcı Puanı')));
      sortingOptions.add(const DropdownMenuItem(value: 'watchDate', child: Text('İzlenme Tarihi')));
    }

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 30, 35, 45),
      title: const Text('Sıralama Seçenekleri',style: TextStyle(color: Colors.white),),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            dropdownColor: const Color.fromARGB(255, 30, 35, 45),
            style: const TextStyle(color: Colors.white),
            value: sortBy,
            items: sortingOptions,
            onChanged: (value) {
              if (value != null) {
                onSortByChanged(value);
                Navigator.of(context).pop();
              }
            },
          ),
          DropdownButton<String>(
            dropdownColor: const Color.fromARGB(255, 30, 35, 45),
            value: isAscending ? 'ascending' : 'descending',
            items: const [
              DropdownMenuItem(value: 'ascending', child: Text('Artan',style: TextStyle(color: Colors.white),)),
              DropdownMenuItem(value: 'descending', child: Text('Azalan',style: TextStyle(color: Colors.white),)),
            ],
            onChanged: (value) {
              if (value != null) {
                onOrderChanged(value == 'ascending');
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
} 