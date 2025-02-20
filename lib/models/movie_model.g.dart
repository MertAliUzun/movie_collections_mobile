// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 0;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      id: fields[0] as String,
      movieName: fields[1] as String,
      directorName: fields[2] as String,
      releaseDate: fields[3] as DateTime,
      plot: fields[4] as String?,
      runtime: fields[5] as int?,
      imdbRating: fields[6] as double?,
      writers: (fields[7] as List?)?.cast<String>(),
      actors: (fields[8] as List?)?.cast<String>(),
      watched: fields[9] as bool,
      imageLink: fields[10] as String,
      userEmail: fields[11] as String,
      watchDate: fields[12] as DateTime?,
      userScore: fields[13] as double?,
      hypeScore: fields[14] as double?,
      genres: (fields[15] as List?)?.cast<String>(),
      productionCompany: (fields[16] as List?)?.cast<String>(),
      customSortTitle: fields[17] as String?,
      budget: fields[20] as double?,
      country: fields[18] as String?,
      popularity: fields[19] as double?,
      revenue: fields[21] as double?,
      toSync: fields[22] as bool?,
      watchCount: fields[23] as int?,
      myNotes: fields[24] as String?,
      collectionType: fields[25] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.movieName)
      ..writeByte(2)
      ..write(obj.directorName)
      ..writeByte(3)
      ..write(obj.releaseDate)
      ..writeByte(4)
      ..write(obj.plot)
      ..writeByte(5)
      ..write(obj.runtime)
      ..writeByte(6)
      ..write(obj.imdbRating)
      ..writeByte(7)
      ..write(obj.writers)
      ..writeByte(8)
      ..write(obj.actors)
      ..writeByte(9)
      ..write(obj.watched)
      ..writeByte(10)
      ..write(obj.imageLink)
      ..writeByte(11)
      ..write(obj.userEmail)
      ..writeByte(12)
      ..write(obj.watchDate)
      ..writeByte(13)
      ..write(obj.userScore)
      ..writeByte(14)
      ..write(obj.hypeScore)
      ..writeByte(15)
      ..write(obj.genres)
      ..writeByte(16)
      ..write(obj.productionCompany)
      ..writeByte(17)
      ..write(obj.customSortTitle)
      ..writeByte(18)
      ..write(obj.country)
      ..writeByte(19)
      ..write(obj.popularity)
      ..writeByte(20)
      ..write(obj.budget)
      ..writeByte(21)
      ..write(obj.revenue)
      ..writeByte(22)
      ..write(obj.toSync)
      ..writeByte(23)
      ..write(obj.watchCount)
      ..writeByte(24)
      ..write(obj.myNotes)
      ..writeByte(25)
      ..write(obj.collectionType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
