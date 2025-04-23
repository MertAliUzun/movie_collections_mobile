// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Movie Collection`
  String get movieCollection {
    return Intl.message(
      'Movie Collection',
      name: 'movieCollection',
      desc: '',
      args: [],
    );
  }

  /// `Collection`
  String get collection {
    return Intl.message(
      'Collection',
      name: 'collection',
      desc: '',
      args: [],
    );
  }

  /// `Watch List`
  String get wishlist {
    return Intl.message(
      'Watch List',
      name: 'wishlist',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet connection!`
  String get checkInternet {
    return Intl.message(
      'Please check your internet connection!',
      name: 'checkInternet',
      desc: '',
      args: [],
    );
  }

  /// `Error!`
  String get error {
    return Intl.message(
      'Error!',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `No ID Token found.`
  String get noIdToken {
    return Intl.message(
      'No ID Token found.',
      name: 'noIdToken',
      desc: '',
      args: [],
    );
  }

  /// `No Access Token found.`
  String get noAccessToken {
    return Intl.message(
      'No Access Token found.',
      name: 'noAccessToken',
      desc: '',
      args: [],
    );
  }

  /// `Google Sign-In was canceled.`
  String get signInCancel {
    return Intl.message(
      'Google Sign-In was canceled.',
      name: 'signInCancel',
      desc: '',
      args: [],
    );
  }

  /// `Unable to Detect Movies!`
  String get unableToDetectMovies {
    return Intl.message(
      'Unable to Detect Movies!',
      name: 'unableToDetectMovies',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Sign Out`
  String get signOut {
    return Intl.message(
      'Sign Out',
      name: 'signOut',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to sign out?`
  String get signOutConfirm {
    return Intl.message(
      'Are you sure you want to sign out?',
      name: 'signOutConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Sign Out is Succesful!`
  String get signOutSucceful {
    return Intl.message(
      'Sign Out is Succesful!',
      name: 'signOutSucceful',
      desc: '',
      args: [],
    );
  }

  /// `Signed Out from your account.`
  String get signedOutAccount {
    return Intl.message(
      'Signed Out from your account.',
      name: 'signedOutAccount',
      desc: '',
      args: [],
    );
  }

  /// `Succesful!`
  String get succesful {
    return Intl.message(
      'Succesful!',
      name: 'succesful',
      desc: '',
      args: [],
    );
  }

  /// `CSV file succesfully created: `
  String get csvFileCreated {
    return Intl.message(
      'CSV file succesfully created: ',
      name: 'csvFileCreated',
      desc: '',
      args: [],
    );
  }

  /// `Error writing file: `
  String get errorWritingFile {
    return Intl.message(
      'Error writing file: ',
      name: 'errorWritingFile',
      desc: '',
      args: [],
    );
  }

  /// `Error converting line: `
  String get errorConvertingLine {
    return Intl.message(
      'Error converting line: ',
      name: 'errorConvertingLine',
      desc: '',
      args: [],
    );
  }

  /// `CSV file succesfully imported.`
  String get csvFileImported {
    return Intl.message(
      'CSV file succesfully imported.',
      name: 'csvFileImported',
      desc: '',
      args: [],
    );
  }

  /// `Error reading file: `
  String get errorReadingFile {
    return Intl.message(
      'Error reading file: ',
      name: 'errorReadingFile',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled!`
  String get cancelled {
    return Intl.message(
      'Cancelled!',
      name: 'cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled choosing file.`
  String get cancelChooseFile {
    return Intl.message(
      'Cancelled choosing file.',
      name: 'cancelChooseFile',
      desc: '',
      args: [],
    );
  }

  /// `Storage permissions were not given.`
  String get noStoragePermission {
    return Intl.message(
      'Storage permissions were not given.',
      name: 'noStoragePermission',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message(
      'Title',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Release Date`
  String get releaseDate {
    return Intl.message(
      'Release Date',
      name: 'releaseDate',
      desc: '',
      args: [],
    );
  }

  /// `Director`
  String get director {
    return Intl.message(
      'Director',
      name: 'director',
      desc: '',
      args: [],
    );
  }

  /// `IMDB Rating`
  String get imdbRating {
    return Intl.message(
      'IMDB Rating',
      name: 'imdbRating',
      desc: '',
      args: [],
    );
  }

  /// `Runtime`
  String get runtime {
    return Intl.message(
      'Runtime',
      name: 'runtime',
      desc: '',
      args: [],
    );
  }

  /// `Hype Score`
  String get hypeScore {
    return Intl.message(
      'Hype Score',
      name: 'hypeScore',
      desc: '',
      args: [],
    );
  }

  /// `User Score`
  String get userScore {
    return Intl.message(
      'User Score',
      name: 'userScore',
      desc: '',
      args: [],
    );
  }

  /// `Watch Date`
  String get watchDate {
    return Intl.message(
      'Watch Date',
      name: 'watchDate',
      desc: '',
      args: [],
    );
  }

  /// `Welcome, `
  String get welcome {
    return Intl.message(
      'Welcome, ',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `View As`
  String get viewAs {
    return Intl.message(
      'View As',
      name: 'viewAs',
      desc: '',
      args: [],
    );
  }

  /// `Group By`
  String get groupBy {
    return Intl.message(
      'Group By',
      name: 'groupBy',
      desc: '',
      args: [],
    );
  }

  /// `Sort By`
  String get sortBy {
    return Intl.message(
      'Sort By',
      name: 'sortBy',
      desc: '',
      args: [],
    );
  }

  /// `Sort `
  String get sort {
    return Intl.message(
      'Sort ',
      name: 'sort',
      desc: '',
      args: [],
    );
  }

  /// `Export to CSV`
  String get exportCSV {
    return Intl.message(
      'Export to CSV',
      name: 'exportCSV',
      desc: '',
      args: [],
    );
  }

  /// `Import from CSV`
  String get importCSV {
    return Intl.message(
      'Import from CSV',
      name: 'importCSV',
      desc: '',
      args: [],
    );
  }

  /// `Random Movie`
  String get randomMovie {
    return Intl.message(
      'Random Movie',
      name: 'randomMovie',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get none {
    return Intl.message(
      'None',
      name: 'none',
      desc: '',
      args: [],
    );
  }

  /// `Genre`
  String get genre {
    return Intl.message(
      'Genre',
      name: 'genre',
      desc: '',
      args: [],
    );
  }

  /// `Release Year`
  String get releaseYear {
    return Intl.message(
      'Release Year',
      name: 'releaseYear',
      desc: '',
      args: [],
    );
  }

  /// `Watch Year`
  String get watchYear {
    return Intl.message(
      'Watch Year',
      name: 'watchYear',
      desc: '',
      args: [],
    );
  }

  /// `Ascending`
  String get ascending {
    return Intl.message(
      'Ascending',
      name: 'ascending',
      desc: '',
      args: [],
    );
  }

  /// `Descending`
  String get descending {
    return Intl.message(
      'Descending',
      name: 'descending',
      desc: '',
      args: [],
    );
  }

  /// `List`
  String get list {
    return Intl.message(
      'List',
      name: 'list',
      desc: '',
      args: [],
    );
  }

  /// `List(Small)`
  String get listSmall {
    return Intl.message(
      'List(Small)',
      name: 'listSmall',
      desc: '',
      args: [],
    );
  }

  /// `Card`
  String get card {
    return Intl.message(
      'Card',
      name: 'card',
      desc: '',
      args: [],
    );
  }

  /// `Poster`
  String get poster {
    return Intl.message(
      'Poster',
      name: 'poster',
      desc: '',
      args: [],
    );
  }

  /// ` movies deleted.`
  String get moviesDeleted {
    return Intl.message(
      ' movies deleted.',
      name: 'moviesDeleted',
      desc: '',
      args: [],
    );
  }

  /// ` movies selected`
  String get moviesSelected {
    return Intl.message(
      ' movies selected',
      name: 'moviesSelected',
      desc: '',
      args: [],
    );
  }

  /// `Delete Chosen Movies`
  String get deleteChosenMovies {
    return Intl.message(
      'Delete Chosen Movies',
      name: 'deleteChosenMovies',
      desc: '',
      args: [],
    );
  }

  /// `selected movies will be deleted. Do you confirm?`
  String get selectedMoviesDeleteConfirm {
    return Intl.message(
      'selected movies will be deleted. Do you confirm?',
      name: 'selectedMoviesDeleteConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Movies`
  String get movies {
    return Intl.message(
      'Movies',
      name: 'movies',
      desc: '',
      args: [],
    );
  }

  /// `Search Movies`
  String get searchMovies {
    return Intl.message(
      'Search Movies',
      name: 'searchMovies',
      desc: '',
      args: [],
    );
  }

  /// `Action`
  String get action {
    return Intl.message(
      'Action',
      name: 'action',
      desc: '',
      args: [],
    );
  }

  /// `Adventure`
  String get adventure {
    return Intl.message(
      'Adventure',
      name: 'adventure',
      desc: '',
      args: [],
    );
  }

  /// `Animation`
  String get animation {
    return Intl.message(
      'Animation',
      name: 'animation',
      desc: '',
      args: [],
    );
  }

  /// `Comedy`
  String get comedy {
    return Intl.message(
      'Comedy',
      name: 'comedy',
      desc: '',
      args: [],
    );
  }

  /// `Crime`
  String get crime {
    return Intl.message(
      'Crime',
      name: 'crime',
      desc: '',
      args: [],
    );
  }

  /// `Documentary`
  String get documentary {
    return Intl.message(
      'Documentary',
      name: 'documentary',
      desc: '',
      args: [],
    );
  }

  /// `Drama`
  String get drama {
    return Intl.message(
      'Drama',
      name: 'drama',
      desc: '',
      args: [],
    );
  }

  /// `Family`
  String get family {
    return Intl.message(
      'Family',
      name: 'family',
      desc: '',
      args: [],
    );
  }

  /// `Fantasy`
  String get fantasy {
    return Intl.message(
      'Fantasy',
      name: 'fantasy',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
  }

  /// `Horror`
  String get horror {
    return Intl.message(
      'Horror',
      name: 'horror',
      desc: '',
      args: [],
    );
  }

  /// `Music`
  String get music {
    return Intl.message(
      'Music',
      name: 'music',
      desc: '',
      args: [],
    );
  }

  /// `Mystery`
  String get mystery {
    return Intl.message(
      'Mystery',
      name: 'mystery',
      desc: '',
      args: [],
    );
  }

  /// `Romance`
  String get romance {
    return Intl.message(
      'Romance',
      name: 'romance',
      desc: '',
      args: [],
    );
  }

  /// `Science Fiction`
  String get scienceFiction {
    return Intl.message(
      'Science Fiction',
      name: 'scienceFiction',
      desc: '',
      args: [],
    );
  }

  /// `TV Movie`
  String get tvMovie {
    return Intl.message(
      'TV Movie',
      name: 'tvMovie',
      desc: '',
      args: [],
    );
  }

  /// `Thriller`
  String get thriller {
    return Intl.message(
      'Thriller',
      name: 'thriller',
      desc: '',
      args: [],
    );
  }

  /// `War`
  String get war {
    return Intl.message(
      'War',
      name: 'war',
      desc: '',
      args: [],
    );
  }

  /// `Western`
  String get western {
    return Intl.message(
      'Western',
      name: 'western',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get selected {
    return Intl.message(
      'Selected',
      name: 'selected',
      desc: '',
      args: [],
    );
  }

  /// `will be deleted?`
  String get willBeDeleted {
    return Intl.message(
      'will be deleted?',
      name: 'willBeDeleted',
      desc: '',
      args: [],
    );
  }

  /// ` succesfully deleted`
  String get succesfullyDeleted {
    return Intl.message(
      ' succesfully deleted',
      name: 'succesfullyDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Edit Director`
  String get editDirector {
    return Intl.message(
      'Edit Director',
      name: 'editDirector',
      desc: '',
      args: [],
    );
  }

  /// `Enter director name`
  String get enterDirectorName {
    return Intl.message(
      'Enter director name',
      name: 'enterDirectorName',
      desc: '',
      args: [],
    );
  }

  /// `Movies has been moved to Collection!`
  String get moviesMovedToCollection {
    return Intl.message(
      'Movies has been moved to Collection!',
      name: 'moviesMovedToCollection',
      desc: '',
      args: [],
    );
  }

  /// `Movies has been moved to Watch List!`
  String get moviesMovedToWatchlist {
    return Intl.message(
      'Movies has been moved to Watch List!',
      name: 'moviesMovedToWatchlist',
      desc: '',
      args: [],
    );
  }

  /// `Unable to Upload Images!`
  String get unableUploadImages {
    return Intl.message(
      'Unable to Upload Images!',
      name: 'unableUploadImages',
      desc: '',
      args: [],
    );
  }

  /// `Failure!`
  String get failure {
    return Intl.message(
      'Failure!',
      name: 'failure',
      desc: '',
      args: [],
    );
  }

  /// `Unable to Find Movies!`
  String get unableFindMovie {
    return Intl.message(
      'Unable to Find Movies!',
      name: 'unableFindMovie',
      desc: '',
      args: [],
    );
  }

  /// `Unable to Get Movie Details!`
  String get unableGetMovieDetails {
    return Intl.message(
      'Unable to Get Movie Details!',
      name: 'unableGetMovieDetails',
      desc: '',
      args: [],
    );
  }

  /// `Movie has been Succesfully Added!`
  String get movieAdded {
    return Intl.message(
      'Movie has been Succesfully Added!',
      name: 'movieAdded',
      desc: '',
      args: [],
    );
  }

  /// `Add Genre`
  String get addGenre {
    return Intl.message(
      'Add Genre',
      name: 'addGenre',
      desc: '',
      args: [],
    );
  }

  /// `Add Actor`
  String get addActor {
    return Intl.message(
      'Add Actor',
      name: 'addActor',
      desc: '',
      args: [],
    );
  }

  /// `Add Writer`
  String get addWriter {
    return Intl.message(
      'Add Writer',
      name: 'addWriter',
      desc: '',
      args: [],
    );
  }

  /// `Add Production Company`
  String get addProductionCompany {
    return Intl.message(
      'Add Production Company',
      name: 'addProductionCompany',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter`
  String get pleaseEnter {
    return Intl.message(
      'Please Enter',
      name: 'pleaseEnter',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Actor`
  String get actor {
    return Intl.message(
      'Actor',
      name: 'actor',
      desc: '',
      args: [],
    );
  }

  /// `Writer`
  String get writer {
    return Intl.message(
      'Writer',
      name: 'writer',
      desc: '',
      args: [],
    );
  }

  /// `Company`
  String get company {
    return Intl.message(
      'Company',
      name: 'company',
      desc: '',
      args: [],
    );
  }

  /// `Add New Movie`
  String get addNewMovie {
    return Intl.message(
      'Add New Movie',
      name: 'addNewMovie',
      desc: '',
      args: [],
    );
  }

  /// `Movie Title`
  String get movieTitle {
    return Intl.message(
      'Movie Title',
      name: 'movieTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please enter movie title`
  String get pleaseEnterMovieTitle {
    return Intl.message(
      'Please enter movie title',
      name: 'pleaseEnterMovieTitle',
      desc: '',
      args: [],
    );
  }

  /// `Custom Sort Title`
  String get customSortTitle {
    return Intl.message(
      'Custom Sort Title',
      name: 'customSortTitle',
      desc: '',
      args: [],
    );
  }

  /// `Genres`
  String get genres {
    return Intl.message(
      'Genres',
      name: 'genres',
      desc: '',
      args: [],
    );
  }

  /// `No Genres Selected`
  String get noGenresSelected {
    return Intl.message(
      'No Genres Selected',
      name: 'noGenresSelected',
      desc: '',
      args: [],
    );
  }

  /// `Director Null`
  String get directorNull {
    return Intl.message(
      'Director Null',
      name: 'directorNull',
      desc: '',
      args: [],
    );
  }

  /// `Actors`
  String get actors {
    return Intl.message(
      'Actors',
      name: 'actors',
      desc: '',
      args: [],
    );
  }

  /// `No Actors Selected`
  String get noActorsSelected {
    return Intl.message(
      'No Actors Selected',
      name: 'noActorsSelected',
      desc: '',
      args: [],
    );
  }

  /// `Writers`
  String get writers {
    return Intl.message(
      'Writers',
      name: 'writers',
      desc: '',
      args: [],
    );
  }

  /// `No Writers Selected`
  String get noWritersSelected {
    return Intl.message(
      'No Writers Selected',
      name: 'noWritersSelected',
      desc: '',
      args: [],
    );
  }

  /// `Production Companies`
  String get productionCompanies {
    return Intl.message(
      'Production Companies',
      name: 'productionCompanies',
      desc: '',
      args: [],
    );
  }

  /// `No Companies Selected`
  String get noCompaniesSelected {
    return Intl.message(
      'No Companies Selected',
      name: 'noCompaniesSelected',
      desc: '',
      args: [],
    );
  }

  /// `Release Date: `
  String get releaseDateColon {
    return Intl.message(
      'Release Date: ',
      name: 'releaseDateColon',
      desc: '',
      args: [],
    );
  }

  /// `Watch Date: `
  String get watchDateColon {
    return Intl.message(
      'Watch Date: ',
      name: 'watchDateColon',
      desc: '',
      args: [],
    );
  }

  /// `Budget: `
  String get budgetColon {
    return Intl.message(
      'Budget: ',
      name: 'budgetColon',
      desc: '',
      args: [],
    );
  }

  /// `Revenue: `
  String get revenueColon {
    return Intl.message(
      'Revenue: ',
      name: 'revenueColon',
      desc: '',
      args: [],
    );
  }

  /// `Plot`
  String get plot {
    return Intl.message(
      'Plot',
      name: 'plot',
      desc: '',
      args: [],
    );
  }

  /// `Runtime (Minutes)`
  String get runtimeMinutes {
    return Intl.message(
      'Runtime (Minutes)',
      name: 'runtimeMinutes',
      desc: '',
      args: [],
    );
  }

  /// `Please enter valid number`
  String get enterValidNumber {
    return Intl.message(
      'Please enter valid number',
      name: 'enterValidNumber',
      desc: '',
      args: [],
    );
  }

  /// `IMDB Score`
  String get imdbScore {
    return Intl.message(
      'IMDB Score',
      name: 'imdbScore',
      desc: '',
      args: [],
    );
  }

  /// `Please enter valid score (0-10)`
  String get enterValidScore {
    return Intl.message(
      'Please enter valid score (0-10)',
      name: 'enterValidScore',
      desc: '',
      args: [],
    );
  }

  /// `Add Movie`
  String get addMovie {
    return Intl.message(
      'Add Movie',
      name: 'addMovie',
      desc: '',
      args: [],
    );
  }

  /// `Press to choose movie poster`
  String get pressChoosePoster {
    return Intl.message(
      'Press to choose movie poster',
      name: 'pressChoosePoster',
      desc: '',
      args: [],
    );
  }

  /// `Movie has been Succesfully Updated!`
  String get movieUpdated {
    return Intl.message(
      'Movie has been Succesfully Updated!',
      name: 'movieUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Movie has been Succesfully Deleted!`
  String get movieDeleted {
    return Intl.message(
      'Movie has been Succesfully Deleted!',
      name: 'movieDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching similar movies: `
  String get errorFetchingSimilar {
    return Intl.message(
      'Error fetching similar movies: ',
      name: 'errorFetchingSimilar',
      desc: '',
      args: [],
    );
  }

  /// `Movie Details`
  String get movieDetails {
    return Intl.message(
      'Movie Details',
      name: 'movieDetails',
      desc: '',
      args: [],
    );
  }

  /// `Similar Movies`
  String get similarMovies {
    return Intl.message(
      'Similar Movies',
      name: 'similarMovies',
      desc: '',
      args: [],
    );
  }

  /// `No Title`
  String get noTitle {
    return Intl.message(
      'No Title',
      name: 'noTitle',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Invalid IMDB ID!`
  String get invalidIMDB {
    return Intl.message(
      'Invalid IMDB ID!',
      name: 'invalidIMDB',
      desc: '',
      args: [],
    );
  }

  /// `Alias: `
  String get aliasColon {
    return Intl.message(
      'Alias: ',
      name: 'aliasColon',
      desc: '',
      args: [],
    );
  }

  /// `Birth Date: `
  String get birthDateColon {
    return Intl.message(
      'Birth Date: ',
      name: 'birthDateColon',
      desc: '',
      args: [],
    );
  }

  /// `Death Date: `
  String get deathDateColon {
    return Intl.message(
      'Death Date: ',
      name: 'deathDateColon',
      desc: '',
      args: [],
    );
  }

  /// `Birth Place: `
  String get birthPlaceColon {
    return Intl.message(
      'Birth Place: ',
      name: 'birthPlaceColon',
      desc: '',
      args: [],
    );
  }

  /// `Biography: `
  String get biographyColon {
    return Intl.message(
      'Biography: ',
      name: 'biographyColon',
      desc: '',
      args: [],
    );
  }

  /// `No movies were found`
  String get noMoviesFound {
    return Intl.message(
      'No movies were found',
      name: 'noMoviesFound',
      desc: '',
      args: [],
    );
  }

  /// `No movies were found for this company`
  String get noMoviesFoundForCompany {
    return Intl.message(
      'No movies were found for this company',
      name: 'noMoviesFoundForCompany',
      desc: '',
      args: [],
    );
  }

  /// `Popular For`
  String get popularFor {
    return Intl.message(
      'Popular For',
      name: 'popularFor',
      desc: '',
      args: [],
    );
  }

  /// `Error Fetching Movies!`
  String get errorFetchingMovies {
    return Intl.message(
      'Error Fetching Movies!',
      name: 'errorFetchingMovies',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get daily {
    return Intl.message(
      'Daily',
      name: 'daily',
      desc: '',
      args: [],
    );
  }

  /// `Weekly`
  String get weekly {
    return Intl.message(
      'Weekly',
      name: 'weekly',
      desc: '',
      args: [],
    );
  }

  /// `Monthly`
  String get monthly {
    return Intl.message(
      'Monthly',
      name: 'monthly',
      desc: '',
      args: [],
    );
  }

  /// `Watch Count`
  String get watchCount {
    return Intl.message(
      'Watch Count',
      name: 'watchCount',
      desc: '',
      args: [],
    );
  }

  /// `Data for this Director could not be found!`
  String get dataNotRetrivedDirector {
    return Intl.message(
      'Data for this Director could not be found!',
      name: 'dataNotRetrivedDirector',
      desc: '',
      args: [],
    );
  }

  /// `Data for this Actor could not be found!`
  String get dataNotRetrivedActor {
    return Intl.message(
      'Data for this Actor could not be found!',
      name: 'dataNotRetrivedActor',
      desc: '',
      args: [],
    );
  }

  /// `Data for this Writer could not be found!`
  String get dataNotRetrivedWriter {
    return Intl.message(
      'Data for this Writer could not be found!',
      name: 'dataNotRetrivedWriter',
      desc: '',
      args: [],
    );
  }

  /// `Please return to the previous screen`
  String get returnPreviousScreen {
    return Intl.message(
      'Please return to the previous screen',
      name: 'returnPreviousScreen',
      desc: '',
      args: [],
    );
  }

  /// `No movies found for this genre!`
  String get noMoviesForGenre {
    return Intl.message(
      'No movies found for this genre!',
      name: 'noMoviesForGenre',
      desc: '',
      args: [],
    );
  }

  /// `My Notes`
  String get myNotes {
    return Intl.message(
      'My Notes',
      name: 'myNotes',
      desc: '',
      args: [],
    );
  }

  /// `Collection Type`
  String get collectionType {
    return Intl.message(
      'Collection Type',
      name: 'collectionType',
      desc: '',
      args: [],
    );
  }

  /// `VHS`
  String get vhs {
    return Intl.message(
      'VHS',
      name: 'vhs',
      desc: '',
      args: [],
    );
  }

  /// `DVD`
  String get dvd {
    return Intl.message(
      'DVD',
      name: 'dvd',
      desc: '',
      args: [],
    );
  }

  /// `Blu-Ray`
  String get bluRay {
    return Intl.message(
      'Blu-Ray',
      name: 'bluRay',
      desc: '',
      args: [],
    );
  }

  /// `Steelbook`
  String get steelbook {
    return Intl.message(
      'Steelbook',
      name: 'steelbook',
      desc: '',
      args: [],
    );
  }

  /// `Digital`
  String get digital {
    return Intl.message(
      'Digital',
      name: 'digital',
      desc: '',
      args: [],
    );
  }

  /// `Streaming`
  String get streaming {
    return Intl.message(
      'Streaming',
      name: 'streaming',
      desc: '',
      args: [],
    );
  }

  /// `(Rent)`
  String get rent {
    return Intl.message(
      '(Rent)',
      name: 'rent',
      desc: '',
      args: [],
    );
  }

  /// `(Buy)`
  String get buy {
    return Intl.message(
      '(Buy)',
      name: 'buy',
      desc: '',
      args: [],
    );
  }

  /// `(Subscription)`
  String get subscription {
    return Intl.message(
      '(Subscription)',
      name: 'subscription',
      desc: '',
      args: [],
    );
  }

  /// `Where to Watch?`
  String get whereToWatch {
    return Intl.message(
      'Where to Watch?',
      name: 'whereToWatch',
      desc: '',
      args: [],
    );
  }

  /// `Creation Date`
  String get creationDate {
    return Intl.message(
      'Creation Date',
      name: 'creationDate',
      desc: '',
      args: [],
    );
  }

  /// `Franchise`
  String get franchise {
    return Intl.message(
      'Franchise',
      name: 'franchise',
      desc: '',
      args: [],
    );
  }

  /// `Franchises`
  String get franchises {
    return Intl.message(
      'Franchises',
      name: 'franchises',
      desc: '',
      args: [],
    );
  }

  /// `Add Franchise`
  String get addFranchise {
    return Intl.message(
      'Add Franchise',
      name: 'addFranchise',
      desc: '',
      args: [],
    );
  }

  /// `Tag`
  String get tag {
    return Intl.message(
      'Tag',
      name: 'tag',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get tags {
    return Intl.message(
      'Tags',
      name: 'tags',
      desc: '',
      args: [],
    );
  }

  /// `Add Tag`
  String get addTag {
    return Intl.message(
      'Add Tag',
      name: 'addTag',
      desc: '',
      args: [],
    );
  }

  /// `No Tags Selected`
  String get noTagsSelected {
    return Intl.message(
      'No Tags Selected',
      name: 'noTagsSelected',
      desc: '',
      args: [],
    );
  }

  /// `No Franchises Selected`
  String get noFranchisesSelected {
    return Intl.message(
      'No Franchises Selected',
      name: 'noFranchisesSelected',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade to Premium`
  String get buyPremium {
    return Intl.message(
      'Upgrade to Premium',
      name: 'buyPremium',
      desc: '',
      args: [],
    );
  }

  /// `Buy`
  String get buyButton {
    return Intl.message(
      'Buy',
      name: 'buyButton',
      desc: '',
      args: [],
    );
  }

  /// `Remove All Ads`
  String get removeAds {
    return Intl.message(
      'Remove All Ads',
      name: 'removeAds',
      desc: '',
      args: [],
    );
  }

  /// `Remove Movie Adding Limit`
  String get removeMovieLimit {
    return Intl.message(
      'Remove Movie Adding Limit',
      name: 'removeMovieLimit',
      desc: '',
      args: [],
    );
  }

  /// `Cloud BackUp for Your Movies`
  String get cloudBackUp {
    return Intl.message(
      'Cloud BackUp for Your Movies',
      name: 'cloudBackUp',
      desc: '',
      args: [],
    );
  }

  /// `Premium Customer Support`
  String get premiumSupport {
    return Intl.message(
      'Premium Customer Support',
      name: 'premiumSupport',
      desc: '',
      args: [],
    );
  }

  /// `Check Underrated and Overrated Movies`
  String get checkUnderratedOverrated {
    return Intl.message(
      'Check Underrated and Overrated Movies',
      name: 'checkUnderratedOverrated',
      desc: '',
      args: [],
    );
  }

  /// `January`
  String get january {
    return Intl.message(
      'January',
      name: 'january',
      desc: '',
      args: [],
    );
  }

  /// `February`
  String get february {
    return Intl.message(
      'February',
      name: 'february',
      desc: '',
      args: [],
    );
  }

  /// `March`
  String get march {
    return Intl.message(
      'March',
      name: 'march',
      desc: '',
      args: [],
    );
  }

  /// `April`
  String get april {
    return Intl.message(
      'April',
      name: 'april',
      desc: '',
      args: [],
    );
  }

  /// `May`
  String get may {
    return Intl.message(
      'May',
      name: 'may',
      desc: '',
      args: [],
    );
  }

  /// `June`
  String get june {
    return Intl.message(
      'June',
      name: 'june',
      desc: '',
      args: [],
    );
  }

  /// `July`
  String get july {
    return Intl.message(
      'July',
      name: 'july',
      desc: '',
      args: [],
    );
  }

  /// `August`
  String get august {
    return Intl.message(
      'August',
      name: 'august',
      desc: '',
      args: [],
    );
  }

  /// `September`
  String get september {
    return Intl.message(
      'September',
      name: 'september',
      desc: '',
      args: [],
    );
  }

  /// `October`
  String get october {
    return Intl.message(
      'October',
      name: 'october',
      desc: '',
      args: [],
    );
  }

  /// `November`
  String get november {
    return Intl.message(
      'November',
      name: 'november',
      desc: '',
      args: [],
    );
  }

  /// `December`
  String get december {
    return Intl.message(
      'December',
      name: 'december',
      desc: '',
      args: [],
    );
  }

  /// `Movie Limit Reached`
  String get movieLimitReached {
    return Intl.message(
      'Movie Limit Reached',
      name: 'movieLimitReached',
      desc: '',
      args: [],
    );
  }

  /// `You have reached movie limit (250 for Watch List, 250 for Collection). Please upgrade to Premium for Unlimited Movies. `
  String get movieLimitMessage {
    return Intl.message(
      'You have reached movie limit (250 for Watch List, 250 for Collection). Please upgrade to Premium for Unlimited Movies. ',
      name: 'movieLimitMessage',
      desc: '',
      args: [],
    );
  }

  /// `Select PG Rating`
  String get selectPgRating {
    return Intl.message(
      'Select PG Rating',
      name: 'selectPgRating',
      desc: '',
      args: [],
    );
  }

  /// `Recommend Movie Mode`
  String get recommendMovieMode {
    return Intl.message(
      'Recommend Movie Mode',
      name: 'recommendMovieMode',
      desc: '',
      args: [],
    );
  }

  /// `Find Movie Mode`
  String get findMovieMode {
    return Intl.message(
      'Find Movie Mode',
      name: 'findMovieMode',
      desc: '',
      args: [],
    );
  }

  /// `Latest Movies`
  String get latestMovies {
    return Intl.message(
      'Latest Movies',
      name: 'latestMovies',
      desc: '',
      args: [],
    );
  }

  /// `Upcoming Movies`
  String get upcomingMovies {
    return Intl.message(
      'Upcoming Movies',
      name: 'upcomingMovies',
      desc: '',
      args: [],
    );
  }

  /// `What kind of movies are you looking for?`
  String get whatKindMoviesLookingFor {
    return Intl.message(
      'What kind of movies are you looking for?',
      name: 'whatKindMoviesLookingFor',
      desc: '',
      args: [],
    );
  }

  /// `By typing the genre or topic of the film, you can get recommendations`
  String get getRecommendationFromAI {
    return Intl.message(
      'By typing the genre or topic of the film, you can get recommendations',
      name: 'getRecommendationFromAI',
      desc: '',
      args: [],
    );
  }

  /// `Producer`
  String get producer {
    return Intl.message(
      'Producer',
      name: 'producer',
      desc: '',
      args: [],
    );
  }

  /// `Hide Chosen Movies`
  String get hideChosenMovies {
    return Intl.message(
      'Hide Chosen Movies',
      name: 'hideChosenMovies',
      desc: '',
      args: [],
    );
  }

  /// `Do you confirm hiding selected movies?`
  String get selectedMoviesHideConfirm {
    return Intl.message(
      'Do you confirm hiding selected movies?',
      name: 'selectedMoviesHideConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Movies have been hidden`
  String get moviesAreHidden {
    return Intl.message(
      'Movies have been hidden',
      name: 'moviesAreHidden',
      desc: '',
      args: [],
    );
  }

  /// `Discover`
  String get discover {
    return Intl.message(
      'Discover',
      name: 'discover',
      desc: '',
      args: [],
    );
  }

  /// `Popular Movies`
  String get popularMovies {
    return Intl.message(
      'Popular Movies',
      name: 'popularMovies',
      desc: '',
      args: [],
    );
  }

  /// `Popular People`
  String get popularPeople {
    return Intl.message(
      'Popular People',
      name: 'popularPeople',
      desc: '',
      args: [],
    );
  }

  /// `Restore Hidden Movies`
  String get restoreHiddenMovies {
    return Intl.message(
      'Restore Hidden Movies',
      name: 'restoreHiddenMovies',
      desc: '',
      args: [],
    );
  }

  /// `Other Movies in Series`
  String get otherMoviesInSeries {
    return Intl.message(
      'Other Movies in Series',
      name: 'otherMoviesInSeries',
      desc: '',
      args: [],
    );
  }

  /// `Movies restored`
  String get moviesRestored {
    return Intl.message(
      'Movies restored',
      name: 'moviesRestored',
      desc: '',
      args: [],
    );
  }

  /// `Do you confirm restoring selected movies?`
  String get selectedMoviesRestoreConfirm {
    return Intl.message(
      'Do you confirm restoring selected movies?',
      name: 'selectedMoviesRestoreConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Hidden Movies`
  String get hiddenMovies {
    return Intl.message(
      'Hidden Movies',
      name: 'hiddenMovies',
      desc: '',
      args: [],
    );
  }

  /// `No Hidden Movies`
  String get noHiddenMovies {
    return Intl.message(
      'No Hidden Movies',
      name: 'noHiddenMovies',
      desc: '',
      args: [],
    );
  }

  /// `Search People`
  String get searchPeople {
    return Intl.message(
      'Search People',
      name: 'searchPeople',
      desc: '',
      args: [],
    );
  }

  /// `Movie recommend file created.`
  String get recommendFileCreated {
    return Intl.message(
      'Movie recommend file created.',
      name: 'recommendFileCreated',
      desc: '',
      args: [],
    );
  }

  /// `Do you confirm creating a recommed movie file with selected movies?`
  String get recommendFileCreationConfirm {
    return Intl.message(
      'Do you confirm creating a recommed movie file with selected movies?',
      name: 'recommendFileCreationConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Select movies to add to your Watch List`
  String get selectMoviesToAdd {
    return Intl.message(
      'Select movies to add to your Watch List',
      name: 'selectMoviesToAdd',
      desc: '',
      args: [],
    );
  }

  /// `Movies have been added to your Watch List.`
  String get moviesAddedToWatchList {
    return Intl.message(
      'Movies have been added to your Watch List.',
      name: 'moviesAddedToWatchList',
      desc: '',
      args: [],
    );
  }

  /// `Premium will be bought for the account that is logged in on your play store. It won't be bought for your user logged in this app. However you can use premium for all users in this app when it is bought.`
  String get premiumWillBeForPlayStoreUser {
    return Intl.message(
      'Premium will be bought for the account that is logged in on your play store. It won\'t be bought for your user logged in this app. However you can use premium for all users in this app when it is bought.',
      name: 'premiumWillBeForPlayStoreUser',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'aa'),
      Locale.fromSubtags(languageCode: 'ab'),
      Locale.fromSubtags(languageCode: 'af'),
      Locale.fromSubtags(languageCode: 'ak'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'az'),
      Locale.fromSubtags(languageCode: 'ba'),
      Locale.fromSubtags(languageCode: 'be'),
      Locale.fromSubtags(languageCode: 'bg'),
      Locale.fromSubtags(languageCode: 'bm'),
      Locale.fromSubtags(languageCode: 'bn'),
      Locale.fromSubtags(languageCode: 'bs'),
      Locale.fromSubtags(languageCode: 'ca'),
      Locale.fromSubtags(languageCode: 'ce'),
      Locale.fromSubtags(languageCode: 'cs'),
      Locale.fromSubtags(languageCode: 'cv'),
      Locale.fromSubtags(languageCode: 'cy'),
      Locale.fromSubtags(languageCode: 'da'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'el'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'et'),
      Locale.fromSubtags(languageCode: 'eu'),
      Locale.fromSubtags(languageCode: 'fa'),
      Locale.fromSubtags(languageCode: 'ff'),
      Locale.fromSubtags(languageCode: 'fi'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'ga'),
      Locale.fromSubtags(languageCode: 'gd'),
      Locale.fromSubtags(languageCode: 'gu'),
      Locale.fromSubtags(languageCode: 'ha'),
      Locale.fromSubtags(languageCode: 'he'),
      Locale.fromSubtags(languageCode: 'hi'),
      Locale.fromSubtags(languageCode: 'hr'),
      Locale.fromSubtags(languageCode: 'ht'),
      Locale.fromSubtags(languageCode: 'hu'),
      Locale.fromSubtags(languageCode: 'hy'),
      Locale.fromSubtags(languageCode: 'id'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'jv'),
      Locale.fromSubtags(languageCode: 'ka'),
      Locale.fromSubtags(languageCode: 'kg'),
      Locale.fromSubtags(languageCode: 'kk'),
      Locale.fromSubtags(languageCode: 'km'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'ks'),
      Locale.fromSubtags(languageCode: 'ku'),
      Locale.fromSubtags(languageCode: 'ky'),
      Locale.fromSubtags(languageCode: 'lb'),
      Locale.fromSubtags(languageCode: 'lt'),
      Locale.fromSubtags(languageCode: 'lv'),
      Locale.fromSubtags(languageCode: 'mk'),
      Locale.fromSubtags(languageCode: 'ml'),
      Locale.fromSubtags(languageCode: 'mn'),
      Locale.fromSubtags(languageCode: 'mr'),
      Locale.fromSubtags(languageCode: 'ms'),
      Locale.fromSubtags(languageCode: 'my'),
      Locale.fromSubtags(languageCode: 'ne'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'no'),
      Locale.fromSubtags(languageCode: 'pa'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ro'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'rw'),
      Locale.fromSubtags(languageCode: 'sd'),
      Locale.fromSubtags(languageCode: 'sk'),
      Locale.fromSubtags(languageCode: 'sl'),
      Locale.fromSubtags(languageCode: 'sm'),
      Locale.fromSubtags(languageCode: 'so'),
      Locale.fromSubtags(languageCode: 'sq'),
      Locale.fromSubtags(languageCode: 'sr'),
      Locale.fromSubtags(languageCode: 'su'),
      Locale.fromSubtags(languageCode: 'sv'),
      Locale.fromSubtags(languageCode: 'sw'),
      Locale.fromSubtags(languageCode: 'ta'),
      Locale.fromSubtags(languageCode: 'te'),
      Locale.fromSubtags(languageCode: 'tg'),
      Locale.fromSubtags(languageCode: 'th'),
      Locale.fromSubtags(languageCode: 'tk'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'tt'),
      Locale.fromSubtags(languageCode: 'ug'),
      Locale.fromSubtags(languageCode: 'uk'),
      Locale.fromSubtags(languageCode: 'ur'),
      Locale.fromSubtags(languageCode: 'uz'),
      Locale.fromSubtags(languageCode: 'vi'),
      Locale.fromSubtags(languageCode: 'wo'),
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'zu'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
