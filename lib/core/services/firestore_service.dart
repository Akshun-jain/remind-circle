import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get groups =>
      _firestore.collection('groups');

  CollectionReference<Map<String, dynamic>> get inviteCodes =>
      _firestore.collection('inviteCodes');

  /// Events inside a group
  CollectionReference<Map<String, dynamic>> groupEvents(String groupId) {
    return groups.doc(groupId).collection('events');
  }
}
