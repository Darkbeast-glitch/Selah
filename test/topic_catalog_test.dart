import 'package:flutter_test/flutter_test.dart';
import 'package:selah/core/constants/app_constants.dart';
import 'package:selah/features/scripture/data/topic_catalog.dart';

/// Guards the curated topic map.
///
/// Verse ids cannot be verified here — that needs the SQLite corpus, which
/// requires a platform — so `tool/verify_topics.py` asserts them against the
/// database. These tests cover what pure Dart can: that every topic the UI
/// offers has passages, and that lookup behaves as the conversation expects.
void main() {
  test('every Home topic shortcut has curated passages', () {
    for (final topic in HomeTopic.values) {
      final ids = TopicCatalog.idsFor(topic.label);
      expect(ids, isNotNull, reason: 'no passages for "${topic.label}"');
      expect(ids!, isNotEmpty, reason: topic.label);
    }
  });

  test('every Explore topic has curated passages', () {
    for (final group in ExploreGroup.values) {
      for (final topic in group.topics) {
        final ids = TopicCatalog.idsFor(topic);
        expect(ids, isNotNull, reason: 'no passages for "$topic"');
        expect(ids!, isNotEmpty, reason: topic);
      }
    }
  });

  test('verse ids are well formed', () {
    final pattern = RegExp(r'^[a-z0-9_]+_\d+_\d+$');
    for (final entry in TopicCatalog.topics.entries) {
      for (final id in entry.value) {
        expect(pattern.hasMatch(id), isTrue, reason: '${entry.key}: $id');
      }
    }
  });

  test('lookup is case insensitive and trims', () {
    expect(TopicCatalog.idsFor('fear'), isNotNull);
    expect(TopicCatalog.idsFor('FEAR'), isNotNull);
    expect(TopicCatalog.idsFor('  Fear  '), isNotNull);
  });

  test('a sentence is not treated as a topic', () {
    // Intent extraction from prose is the backend's job (PRD §11); guessing
    // here would silently return passages for the wrong theme.
    expect(TopicCatalog.idsFor('I am afraid of the future'), isNull);
    expect(TopicCatalog.idsFor('fear of failure'), isNull);
    expect(TopicCatalog.isTopic(''), isFalse);
  });

  test('no topic offers a single passage — a theme needs more than one voice', () {
    for (final entry in TopicCatalog.topics.entries) {
      expect(
        entry.value.length,
        greaterThanOrEqualTo(3),
        reason: '${entry.key} has only ${entry.value.length}',
      );
    }
  });
}
