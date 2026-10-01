class ContactUser {
  String? id;
  String? name;
  String? phone;

  ContactUser({this.name, this.phone, this.id});

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
    };
  }

  ContactUser.fromJson(Map<String, dynamic> json, String documentId) {
    id = documentId;
    name = json["name"];
    phone = json["phone"];
  }
}