// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scripture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Scripture _$ScriptureFromJson(Map<String, dynamic> json) => _Scripture(
  id: json['id'] as String,
  book: json['book'] as String,
  bookOrder: (json['bookOrder'] as num).toInt(),
  chapter: (json['chapter'] as num).toInt(),
  verse: (json['verse'] as num).toInt(),
  text: json['text'] as String,
  translation: json['translation'] as String,
);

Map<String, dynamic> _$ScriptureToJson(_Scripture instance) =>
    <String, dynamic>{
      'id': instance.id,
      'book': instance.book,
      'bookOrder': instance.bookOrder,
      'chapter': instance.chapter,
      'verse': instance.verse,
      'text': instance.text,
      'translation': instance.translation,
    };

_BibleBook _$BibleBookFromJson(Map<String, dynamic> json) => _BibleBook(
  bookOrder: (json['bookOrder'] as num).toInt(),
  name: json['name'] as String,
  slug: json['slug'] as String,
  testament: $enumDecode(_$TestamentEnumMap, json['testament']),
  chapters: (json['chapters'] as num).toInt(),
);

Map<String, dynamic> _$BibleBookToJson(_BibleBook instance) =>
    <String, dynamic>{
      'bookOrder': instance.bookOrder,
      'name': instance.name,
      'slug': instance.slug,
      'testament': _$TestamentEnumMap[instance.testament]!,
      'chapters': instance.chapters,
    };

const _$TestamentEnumMap = {Testament.old: 'OT', Testament.new_: 'NT'};
