class Group {
  final String id;
  final String name;
  final String description;
  final List<String> members;
  final List<String> admins;
  final DateTime createdAt;
  final String createdBy;
  final String groupType; // team, department, project, taskforce
  final String? groupImageUrl;
  final bool isActive;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.admins,
    required this.createdAt,
    required this.createdBy,
    required this.groupType,
    this.groupImageUrl,
    this.isActive = true,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      members: List<String>.from(json['members'] ?? []),
      admins: List<String>.from(json['admins'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      groupType: json['groupType'] as String,
      groupImageUrl: json['groupImageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'members': members,
      'admins': admins,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'groupType': groupType,
      'groupImageUrl': groupImageUrl,
      'isActive': isActive,
    };
  }
}