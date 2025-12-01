class WhatsAppGroup {
  final int id;
  final String groupName;
  final String link;

  WhatsAppGroup({
    required this.id,
    required this.groupName,
    required this.link,
  });

  factory WhatsAppGroup.fromJson(Map<String, dynamic> json) {
    return WhatsAppGroup(
      id: json['id'],
      groupName: json['group_name'],
      link: json['link'],
    );
  }
}
