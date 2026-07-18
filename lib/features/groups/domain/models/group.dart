class Group {
  const Group({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.inviteCode,
    required this.createdAt,
    required this.memberIds,
    required this.admins,
  });

  final String id;
  final String name;
  final String ownerId;
  final String inviteCode;
  final DateTime createdAt;
  final List<String> memberIds;
  final List<String> admins;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'inviteCode': inviteCode,
      'createdAt': createdAt,
      'memberIds': memberIds,
      'admins': admins,
    };
  }

  factory Group.fromMap(String id, Map<String, dynamic> map) {
    return Group(
      id: id,
      name: map['name'] as String,
      ownerId: map['ownerId'] as String,
      inviteCode: map['inviteCode'] as String,
      createdAt: (map['createdAt'] as dynamic).toDate(),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      admins: List<String>.from(map['admins'] ?? []),
    );
  }
}
