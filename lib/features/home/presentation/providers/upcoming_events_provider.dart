import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/providers/auth_provider.dart';
import 'package:remind_circle/core/services/recurrence_service.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

import 'package:remind_circle/core/notifications/notification_service.dart';
import 'dart:developer' as developer;

import 'package:remind_circle/features/groups/domain/models/group.dart';

final upcomingEventsProvider = StreamProvider<List<Event>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user == null) {
    return Stream.value(const <Event>[]);
  }

  final firestore = FirebaseFirestore.instance;

  return _watchUpcomingEvents(firestore: firestore, userId: user.uid);
});

Stream<List<Event>> _watchUpcomingEvents({
  required FirebaseFirestore firestore,
  required String userId,
}) {
  final controller = StreamController<List<Event>>();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? groupsSubscription;

  final eventSubscriptions =
      <String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>{};

  final groupEvents = <String, List<Event>>{};
  Timer? refreshTimer;
  late void Function() scheduleNextRefresh;

  void emitEvents() {
    final allEvents = groupEvents.values.expand((events) => events).where((
      event,
    ) {
      final nextOccurrence = RecurrenceService.getNextOccurrence(event);

      return nextOccurrence != null && !nextOccurrence.isBefore(DateTime.now());
    }).toList();

    allEvents.sort((a, b) {
      final aNext = RecurrenceService.getNextOccurrence(a);
      final bNext = RecurrenceService.getNextOccurrence(b);

      if (aNext == null && bNext == null) {
        return 0;
      }

      if (aNext == null) {
        return 1;
      }

      if (bNext == null) {
        return -1;
      }

      return aNext.compareTo(bNext);
    });

    if (!controller.isClosed) {
      controller.add(allEvents);
    }

    scheduleNextRefresh();
  }

  scheduleNextRefresh = () {
    refreshTimer?.cancel();

    DateTime? nextRefresh;

    for (final events in groupEvents.values) {
      for (final event in events) {
        final nextOccurrence = RecurrenceService.getNextOccurrence(event);

        if (nextOccurrence == null) {
          continue;
        }

        if (nextRefresh == null || nextOccurrence.isBefore(nextRefresh)) {
          nextRefresh = nextOccurrence;
        }
      }
    }

    if (nextRefresh == null || controller.isClosed) {
      return;
    }

    final now = DateTime.now();
    final delay = nextRefresh.difference(now);

    refreshTimer = Timer(
      delay.isNegative
          ? const Duration(seconds: 1)
          : delay + const Duration(seconds: 1),
      () {
        if (!controller.isClosed) {
          emitEvents();
        }
      },
    );
  };

  Future<void> removeGroupListener(String groupId) async {
    final subscription = eventSubscriptions.remove(groupId);

    if (subscription != null) {
      await subscription.cancel();
    }

    groupEvents.remove(groupId);
  }

  void listenToGroupEvents(String groupId) {
    if (eventSubscriptions.containsKey(groupId)) {
      return;
    }

    final subscription = firestore
        .collection('groups')
        .doc(groupId)
        .collection('events')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          final events = snapshot.docs
              .map((doc) => Event.fromMap(doc.id, doc.data()))
              .toList();

          groupEvents[groupId] = events;

          unawaited(
            firestore
                .collection('groups')
                .doc(groupId)
                .get()
                .then((groupDoc) {
                  if (!groupDoc.exists) {
                    return;
                  }

                  final group = Group.fromMap(groupDoc.id, groupDoc.data()!);

                  for (final event in events) {
                    unawaited(
                      NotificationService.instance
                          .scheduleEventNotifications(
                            event,
                            groupName: group.name,
                          )
                          .catchError((error, stackTrace) {
                            developer.log(
                              'Failed to schedule shared event notification',
                              error: error,
                              stackTrace: stackTrace,
                            );
                          }),
                    );
                  }
                })
                .catchError((error, stackTrace) {
                  developer.log(
                    'Failed to load group for notification scheduling',
                    error: error,
                    stackTrace: stackTrace,
                  );
                }),
          );

          emitEvents();
        });

    eventSubscriptions[groupId] = subscription;
  }

  groupsSubscription = firestore
      .collection('groups')
      .where('memberIds', arrayContains: userId)
      .snapshots()
      .listen((groupsSnapshot) async {
        final currentGroupIds = groupsSnapshot.docs
            .map((doc) => doc.id)
            .toSet();

        for (final groupId in currentGroupIds) {
          listenToGroupEvents(groupId);
        }

        final removedGroupIds = eventSubscriptions.keys
            .where((groupId) => !currentGroupIds.contains(groupId))
            .toList();

        for (final groupId in removedGroupIds) {
          await removeGroupListener(groupId);
        }

        emitEvents();
      });

  controller.onCancel = () async {
    refreshTimer?.cancel();
    refreshTimer = null;
    await groupsSubscription?.cancel();

    for (final subscription in eventSubscriptions.values) {
      await subscription.cancel();
    }

    eventSubscriptions.clear();
    groupEvents.clear();

    await controller.close();
  };

  return controller.stream;
}
