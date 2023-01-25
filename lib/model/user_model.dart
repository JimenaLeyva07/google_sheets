class UserFieldsGoogleSheet {
  static const String id = 'id';
  static const String name = 'name';
  static const String email = 'email';
  static const String comments = 'comments';
  static const Map<String,String> range = {id:'A',name:'B',email:'C',comments:'D'};

  static List<String> getFields() => [id, name, email, comments];
  static String? getLettersColumns(String index) => range[index];
}

class User {
  int? indexRow;
  String? id;
  String name;
  String email;
  List<String> comments;

  User({
    this.indexRow,
    this.id,
    required this.name,
    required this.email,
    required this.comments,
  });

  Map<String, String?> tojson(List<String> comment) => {
        UserFieldsGoogleSheet.id: id,
        UserFieldsGoogleSheet.name: name,
        UserFieldsGoogleSheet.email: email,
        UserFieldsGoogleSheet.comments: comment.join("\n"),
      };

  static User fromJson(Map<String, dynamic> json, List<String> comment) => User(
      id: json[UserFieldsGoogleSheet.id],
      name: json[UserFieldsGoogleSheet.name],
      email: json[UserFieldsGoogleSheet.email],
      comments: comment);

  static User fromJsontwo(Map<String, dynamic> json, int index) => User(
        indexRow: index + 2,
        id: json[UserFieldsGoogleSheet.id],
        name: json[UserFieldsGoogleSheet.name],
        email: json[UserFieldsGoogleSheet.email],
        comments: json[UserFieldsGoogleSheet.comments].split('\n'),
      );
}
