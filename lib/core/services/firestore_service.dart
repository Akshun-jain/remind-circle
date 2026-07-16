import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get groups =>
      _firestore.collection('groups');
}
