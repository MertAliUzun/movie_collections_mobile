import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import '../models/movie_model.dart';
import '../services/ad_service.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'dart:io';

final AdService _adService = AdService();

Future<bool> deleteDetailsConfirm(BuildContext context, String detailType) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        content: Text(
          '${S.of(context).selected} $detailType ${S.of(context).willBeDeleted}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // User declined
            child: Text(S.of(context).no, style: const TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // User confirmed
            child: Text(S.of(context).yes, style: const TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );

  return confirm ?? false; // Return false if dialog was dismissed
}

void deleteDetails(BuildContext context, String detailType, {int? index, List<String>? selected, Function? onDelete}) {
  // Confirm deletion
  deleteDetailsConfirm(context, detailType).then((confirmed) {
    if (confirmed) {
      // Perform deletion logic
      if (selected != null && index != null) {
        selected.removeAt(index); // Remove the item from the list

        final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).succesful,
          message: '$detailType ${S.of(context).succesfullyDeleted}', 
          contentType: ContentType.success, 
          inMaterialBanner: true,
        ), 
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);

        if (onDelete != null) {
          onDelete(); // Call the callback to update the UI
        }
      }
    }
  });
}

Future<void> editDirector(BuildContext context, TextEditingController directorNameController) async {
  String input = directorNameController.text; // Pre-fill with current director name
  await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        title: Text(S.of(context).editDirector, style: const TextStyle(color: Colors.white)),
        content: TextField(
          onChanged: (value) {
            input = value;
          },
          decoration: InputDecoration(hintText: S.of(context).enterDirectorName, hintStyle: const TextStyle(color: Colors.white)),
          controller: TextEditingController(text: input), // Set initial text
          style: const TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text(S.of(context).cancel, style: const TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              directorNameController.text = input; // Update the director name
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text(S.of(context).ok, style: const TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

Future<void> toggleWatchedStatus(BuildContext context, Movie movie, bool isFromWishlist, bool canPop) async {
  final box = Hive.box<Movie>('movies');
  
  String movieId = movie.id;
  // Hive'dan sil
  if (isFromWishlist) {
    // Eğer film izleme listesinde ise, durumu güncelle
    movie.watched = true; // İzlenmiş olarak işaretle
  } else {
    // Eğer film koleksiyonda ise, durumu güncelle
    movie.watched = false; // İzlenmemiş olarak işaretle
  }

  // Hive'da güncelle
  box.put(movieId, movie);

  _adService.showInterstitialAd();

  // Kullanıcıya bildirim göster
  
  if (canPop) {
        Navigator.pop(context, true);
      }
}

Future<void> hideMovies(BuildContext context, Movie movie, bool canPop) async {
  final box = Hive.box<Movie>('movies');
  
  String movieId = movie.id;

  movie.hidden = !movie.hidden!;
  if(movie.hidden!) 
  {

  } else {

  }
  // Hive'da güncelle
  box.put(movieId, movie);

  _adService.showInterstitialAd();

  // Kullanıcıya bildirim göster
  
  if (canPop) {
        Navigator.pop(context, true);
      }
}

String getGenreLocalizedString(String genre, BuildContext context) {
  switch (genre) {
    case 'Action': return S.of(context).action;
    case 'Adventure': return S.of(context).adventure;
    case 'Animation': return S.of(context).animation;
    case 'Comedy': return S.of(context).comedy;
    case 'Crime': return S.of(context).crime;
    case 'Documentary': return S.of(context).documentary;
    case 'Drama': return S.of(context).drama;
    case 'Family': return S.of(context).family;
    case 'Fantasy': return S.of(context).fantasy;
    case 'History': return S.of(context).history;
    case 'Horror': return S.of(context).horror;
    case 'Music': return S.of(context).music;
    case 'Mystery': return S.of(context).mystery;
    case 'Romance': return S.of(context).romance;
    case 'Science Fiction': return S.of(context).scienceFiction;
    case 'TV Movie': return S.of(context).tvMovie;
    case 'Thriller': return S.of(context).thriller;
    case 'War': return S.of(context).war;
    case 'Western': return S.of(context).western;
    default: return genre; // Return the genre name if no match is found
  }
}

Future<bool> checkConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult[0] == ConnectivityResult.none) { return false;}
  return true;
}

Future<void> exportRecommendationsToCSV(BuildContext context, List<Movie> selectedMovies) async {
  try {
    // CSV verilerini hazırla
    List<List<dynamic>> csvData = [
      [
        'ID', 
        'Movie Name', 
        'Director Name', 
        'Release Date', 
        'Plot', 
        'Runtime', 
        'IMDB Rating', 
        'Writers', 
        'Actors', 
        'Watched', 
        'Image Link', 
        'User Email', 
        'Watch Date', 
        'User Score', 
        'Hype Score', 
        'Genres', 
        'Production Company', 
        'Custom Sort Title', 
        'Country', 
        'Popularity', 
        'Budget', 
        'Revenue', 
        'To Sync',
        'Watch Count',
        'My Notes',
        'Collection Type',
        'Creation Date',
        'PG Rating',
        'Franchises',
        'Tags',
        'Hidden'
      ],
    ];

    for (var movie in selectedMovies) {
      csvData.add([
        movie.id.toString(),
        movie.movieName.toString(),
        movie.directorName.toString(),
        movie.releaseDate.toIso8601String(),
        movie.plot?.toString() ?? '',
        movie.runtime?.toString() ?? '',
        movie.imdbRating?.toString() ?? '',
        movie.writers?.join(', ') ?? '',
        movie.actors?.join(', ') ?? '',
        false, //movie.watched.toString(),
        movie.imageLink.toString(),
        'test@test.com', //movie.userEmail.toString(),
        '', //movie.watchDate?.toIso8601String() ?? '',
        '', //movie.userScore?.toString() ?? '',
        '', //movie.hypeScore?.toString() ?? '',
        movie.genres?.join(', ') ?? '',
        movie.productionCompany?.join(', ') ?? '',
        '', //movie.customSortTitle?.toString() ?? '',
        movie.country?.toString() ?? '',
        movie.popularity?.toString() ?? '',
        movie.budget?.toString() ?? '',
        movie.revenue?.toString() ?? '',
        false, //movie.toSync.toString(),
        '', //movie.watchCount?.toString() ?? '',
        '', //movie.myNotes?.toString() ?? '',
        '', //movie.collectionType?.toString() ?? '',
        movie.creationDate?.toIso8601String() ?? '',
        movie.pgRating?.toString() ?? '',
        '', //movie.franchises?.join(', ') ?? '',
        '', //movie.tags?.join(', ') ?? '',
        false, //movie.hidden.toString(),
      ]);
    }

    String csvString = const ListToCsvConverter().convert(csvData);
    final csvBytes = utf8.encode(csvString);

    final archive = Archive()
      ..addFile(ArchiveFile('recommendations.csv', csvBytes.length, csvBytes));
    final zipData = ZipEncoder().encode(archive);
    
    // Geçici dosya oluştur
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/recommendations.zip');
    await tempFile.writeAsBytes(zipData);

    
    // Share Plus ile dosyayı paylaş
    final result = await Share.shareXFiles(
    [
      XFile(
        tempFile.path,
        mimeType: 'application/zip',
        name: 'recommendations.zip',
      )
    ],
      subject: 'Recommendation CSV Export',
      text: 'Here is your recommended movies file',
    );

    if (result.status == ShareResultStatus.success) {
      _adService.showInterstitialAd();
      
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).succesful,
          message: S.of(context).csvFileCreated,
          contentType: ContentType.success,
          inMaterialBanner: true,
        ),
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);
    }
  } catch (e) {
    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      content: AwesomeSnackbarContent(
        title: S.of(context).failure,
        message: '${S.of(context).errorWritingFile} $e',
        contentType: ContentType.failure,
        inMaterialBanner: true,
      ),
      dismissDirection: DismissDirection.horizontal,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showSnackBar(snackBar);
  }
}