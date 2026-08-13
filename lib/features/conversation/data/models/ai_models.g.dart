// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiReflection _$AiReflectionFromJson(Map<String, dynamic> json) =>
    _AiReflection(
      acknowledgement: json['acknowledgement'] as String,
      scriptures: (json['scriptures'] as List<dynamic>)
          .map((e) => AiScriptureNote.fromJson(e as Map<String, dynamic>))
          .toList(),
      response: json['response'] as String,
      reflectionQuestion: json['reflectionQuestion'] as String,
      followUpPrompt: json['followUpPrompt'] as String,
      safetyNotice: json['safetyNotice'] as String?,
    );

Map<String, dynamic> _$AiReflectionToJson(_AiReflection instance) =>
    <String, dynamic>{
      'acknowledgement': instance.acknowledgement,
      'scriptures': instance.scriptures,
      'response': instance.response,
      'reflectionQuestion': instance.reflectionQuestion,
      'followUpPrompt': instance.followUpPrompt,
      'safetyNotice': instance.safetyNotice,
    };

_AiScriptureNote _$AiScriptureNoteFromJson(Map<String, dynamic> json) =>
    _AiScriptureNote(
      id: json['id'] as String,
      reference: json['reference'] as String,
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$AiScriptureNoteToJson(_AiScriptureNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'reason': instance.reason,
    };

_AiPrayer _$AiPrayerFromJson(Map<String, dynamic> json) => _AiPrayer(
  prayerStarter: json['prayerStarter'] as String,
  safetyNotice: json['safetyNotice'] as String?,
);

Map<String, dynamic> _$AiPrayerToJson(_AiPrayer instance) => <String, dynamic>{
  'prayerStarter': instance.prayerStarter,
  'safetyNotice': instance.safetyNotice,
};
