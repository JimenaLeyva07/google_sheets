class CoursesFieldsGoogleSheet {
  static const String id = 'idCurso';
  static const String name = 'NombreCurso';

  static List<String> getFields() => [id, name];
}


class Coursers {
  int? indexRow;
  String? id;
  String name;

  Coursers({
    this.indexRow,
    this.id,
    required this.name,
  });

  Map<String, String?> tojson(List<String> comment) => {
        CoursesFieldsGoogleSheet.id: id,
        CoursesFieldsGoogleSheet.name: name,
      };

  static Coursers fromJson(Map<String, dynamic> json, List<String> comment) => Coursers(
      id: json[CoursesFieldsGoogleSheet.id],
      name: json[CoursesFieldsGoogleSheet.name]);

  static Coursers fromJsontwo(Map<String, dynamic> json, int index) => Coursers(
        indexRow: index + 2,
        id: json[CoursesFieldsGoogleSheet.id],
        name: json[CoursesFieldsGoogleSheet.name],
      );
}