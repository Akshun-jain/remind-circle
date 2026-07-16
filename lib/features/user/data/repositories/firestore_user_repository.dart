import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/user/data/models/user_profile_model.dart';
import 'package:remind_circle/features/user/data/repositories/user_repository.dart';
import 'package:remind_circle/features/user/domain/models/user_profile.dart';

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<void> createUser(UserProfile profile) async {
    final model = UserProfileModel(
      uid: profile.uid,
      name: profile.name,
      email: profile.email,
      photoUrl: profile.photoUrl,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );

    await _firestoreService.users.doc(profile.uid).set(model.toMap());
  }

  @override
  Future<UserProfile?> getUser(String uid) async {
    final doc = await _firestoreService.users.doc(uid).get();

    if (!doc.exists) return null;

    return UserProfileModel.fromMap(doc.data()!);
  }

  @override
  Future<bool> userExists(String uid) async {
    final doc = await _firestoreService.users.doc(uid).get();

    return doc.exists;
  }

  @override
  Future<void> updateUser(UserProfile profile) async {
    final model = UserProfileModel(
      uid: profile.uid,
      name: profile.name,
      email: profile.email,
      photoUrl: profile.photoUrl,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );

    await _firestoreService.users.doc(profile.uid).update(model.toMap());
  }
}
