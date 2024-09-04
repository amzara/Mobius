class MobiusObject {
  String name;
  String objectId;
  String parentId;
  String baseType;

  MobiusObject({
    required this.name,
    required this.objectId,
    required this.parentId,
    required this.baseType,
  });

  // Factory constructor
  factory MobiusObject.fromJson(Map<String, dynamic> json) {
    return MobiusObject(
      name: json['name'] ?? '',
      objectId: json['objectId'] ?? '',
      parentId: json['parentId'] ?? '',
      baseType: json['baseTypeId'] ?? '',
    );
  }
}