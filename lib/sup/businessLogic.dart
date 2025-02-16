import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie_model.dart';
import '../services/supabase_service.dart';
import 'package:hive/hive.dart';

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
            child: Text(S.of(context).no, style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // User confirmed
            child: Text(S.of(context).yes, style: TextStyle(color: Colors.white)),
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
        title: Text(S.of(context).editDirector, style: TextStyle(color: Colors.white)),
        content: TextField(
          onChanged: (value) {
            input = value;
          },
          decoration: InputDecoration(hintText: S.of(context).enterDirectorName, hintStyle: TextStyle(color: Colors.white)),
          controller: TextEditingController(text: input), // Set initial text
          style: const TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text(S.of(context).cancel, style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              directorNameController.text = input; // Update the director name
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text(S.of(context).ok, style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

Future<void> toggleWatchedStatus(BuildContext context, Movie movie, bool isFromWishlist, bool canPop) async {
  final box = Hive.box<Movie>('movies');
  
  String movieId = movie.id!;
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

  // Kullanıcıya bildirim göster
  final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).succesful, 
          message: isFromWishlist ? S.of(context).moviesMovedToCollection : S.of(context).moviesMovedToWatchlist, 
          contentType: ContentType.success, 
          inMaterialBanner: true,
        ), 
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);
  if (canPop) {
        Navigator.pop(context, true);
      }
}

Future<bool> checkConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult[0] == ConnectivityResult.none) { return false;}
  return true;
}