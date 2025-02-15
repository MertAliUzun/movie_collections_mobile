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

  /// `Check your internet connection!`
  String get check_internet {
    return Intl.message(
      'Check your internet connection!',
      name: 'check_internet',
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
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'tr'),
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
