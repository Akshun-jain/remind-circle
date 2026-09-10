import 'dart:developer' as developer;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:remind_circle/features/events/domain/models/event.dart';
import 'package:remind_circle/features/events/presentation/screens/event_details_screen.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';

class NotificationNavigationService {
  NotificationNavigationService._();

  static final NotificationNavigationService instance =
      NotificationNavigationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GlobalKey<NavigatorState>? _navigatorKey;

  String? _pendingEventId;
  String? _pendingGroupId;
  bool _handlingNavigation = false;

  bool get hasPendingNavigation => _pendingEventId != null;

  Completer<bool>? _startupCompleter;

  void beginStartupCheck() {
    _startupCompleter ??= Completer<bool>();
  }

  Future<bool> waitForStartupCheck() async {
    final completer = _startupCompleter;

    if (completer != null) {
      return completer.future;
    }

    return false;
  }

  void completeStartupCheck({required bool notificationLaunch}) {
    final completer = _startupCompleter;

    if (completer != null && !completer.isCompleted) {
      completer.complete(notificationLaunch);
    }
  }

  void attachNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;

    if (_pendingEventId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryHandlePendingNavigation();
      });
    }
  }

  void retryPendingNavigation() {
    if (_pendingEventId == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryHandlePendingNavigation();
      });
    });
  }

  void handleNotificationTap({required String eventId, String? groupId}) {
    developer.log(
      'NOTIFICATION NAV DEBUG: handleNotificationTap '
      'eventId=$eventId groupId=$groupId',
    );

    if (eventId.trim().isEmpty) {
      developer.log('Notification navigation ignored: empty eventId.');
      return;
    }

    _pendingEventId = eventId.trim();
    _pendingGroupId = groupId?.trim().isNotEmpty == true
        ? groupId!.trim()
        : null;

    _tryHandlePendingNavigation();
  }

  Future<void> _tryHandlePendingNavigation() async {
    if (_handlingNavigation) return;

    final eventId = _pendingEventId;
    if (eventId == null) return;

    final navigator = _navigatorKey?.currentState;

    developer.log(
      'NOTIFICATION NAV DEBUG: NavigatorState '
      '${navigator == null ? "NULL" : "AVAILABLE"}',
    );

    if (navigator == null) {
      developer.log('NOTIFICATION NAV DEBUG: Waiting for NavigatorState.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      developer.log('Notification navigation waiting for signed-in user.');
      return;
    }

    _handlingNavigation = true;

    try {
      final event = await _loadEvent(
        eventId: eventId,
        groupId: _pendingGroupId,
      );

      if (event == null) {
        developer.log('Notification navigation: event not found: $eventId');
        _clearPendingNavigation();
        return;
      }

      final groupSnapshot = await _firestore
          .collection('groups')
          .doc(event.groupId)
          .get();

      if (!groupSnapshot.exists || groupSnapshot.data() == null) {
        developer.log(
          'Notification navigation: group not found: ${event.groupId}',
        );
        _clearPendingNavigation();
        return;
      }

      final group = Group.fromMap(groupSnapshot.id, groupSnapshot.data()!);

      final canManageEvent =
          event.createdBy == user.uid ||
          group.ownerId == user.uid ||
          group.admins.contains(user.uid);

      _clearPendingNavigation();

      developer.log(
        'NOTIFICATION NAV DEBUG: About to push EventDetailsScreen '
        'for event=${event.id}',
      );

      navigator.push(
        MaterialPageRoute(
          builder: (_) => EventDetailsScreen(
            event: event,
            group: group,
            canManageEvent: canManageEvent,
          ),
        ),
      );

      developer.log('Notification navigation: opened event ${event.id}');
    } catch (e, stack) {
      developer.log(
        'Notification navigation failed.',
        error: e,
        stackTrace: stack,
      );
    } finally {
      _handlingNavigation = false;
    }
  }

  Future<Event?> _loadEvent({required String eventId, String? groupId}) async {
    if (groupId != null) {
      final eventSnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('events')
          .doc(eventId)
          .get();

      if (!eventSnapshot.exists || eventSnapshot.data() == null) {
        return null;
      }

      return Event.fromMap(eventSnapshot.id, eventSnapshot.data()!);
    }

    // Scheduled local notifications only carry eventId.
    // Find the event through the user's accessible groups.
    final groupsSnapshot = await _firestore
        .collection('groups')
        .where(
          'memberIds',
          arrayContains: FirebaseAuth.instance.currentUser!.uid,
        )
        .get();

    for (final groupSnapshot in groupsSnapshot.docs) {
      final eventSnapshot = await groupSnapshot.reference
          .collection('events')
          .doc(eventId)
          .get();

      if (eventSnapshot.exists && eventSnapshot.data() != null) {
        return Event.fromMap(eventSnapshot.id, eventSnapshot.data()!);
      }
    }

    return null;
  }

  void _clearPendingNavigation() {
    _pendingEventId = null;
    _pendingGroupId = null;
  }
}
