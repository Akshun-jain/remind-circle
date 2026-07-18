import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remind_circle/features/events/domain/enums/event_type.dart';
import 'package:remind_circle/features/events/domain/enums/repeat_type.dart';

class Event {
  final String id;
  final String groupId;

  final String title;
  final String? personName;

  final EventType eventType;

  final DateTime eventDate;

  final RepeatType repeatType;

  final List<int> notifyBefore;

  final String? notes;

  final String createdBy;
  final String createdByName;

  final DateTime createdAt;

  final bool isActive;

  const Event({
    required this.id,
    required this.groupId,
    required this.title,
    this.personName,
    required this.eventType,
    required this.eventDate,
    required this.repeatType,
    required this.notifyBefore,
    this.notes,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.isActive,
  });

  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      groupId: map['groupId'] as String,
      title: map['title'] as String,
      personName: map['personName'] as String?,
      eventType: EventType.values.byName(map['eventType'] as String),
      eventDate: (map['eventDate'] as Timestamp).toDate(),
      repeatType: RepeatType.values.byName(map['repeatType'] as String),
      notifyBefore: List<int>.from(map['notifyBefore'] as List),
      notes: map['notes'] as String?,
      createdBy: map['createdBy'] as String,
      createdByName: map['createdByName'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'title': title,
      'personName': personName,
      'eventType': eventType.name,
      'eventDate': eventDate,
      'repeatType': repeatType.name,
      'notifyBefore': notifyBefore,
      'notes': notes,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }
}
