class StudentFieldsGoogleSheet {
  static const String id = 'id';
  static const String studentName = 'student_name';
  static const String nameSection = 'name_section';
  static const String email = 'email';
  static const String progress = 'progress';

  static List<String> getFields() => [id, studentName,nameSection,email,progress];
}


class StudentModel {
  int? indexRow;
  String? id;
  String? studentName;
  String? nameSection;
  String? email;
  String? progress;

  StudentModel({
    this.indexRow,
    this.id,
    this.studentName,
    this.nameSection,
    this.email,
    this.progress,
  });

  Map<String, String?> tojson(List<String> comment) => {
        StudentFieldsGoogleSheet.id: id,
        StudentFieldsGoogleSheet.studentName: studentName,
        StudentFieldsGoogleSheet.nameSection: nameSection,
        StudentFieldsGoogleSheet.email: email,
        StudentFieldsGoogleSheet.progress: progress,
      };

  static StudentModel fromJson(Map<String, dynamic> json, List<String> comment) => StudentModel(
      id: json[StudentFieldsGoogleSheet.id],
      studentName: json[StudentFieldsGoogleSheet.studentName],
      nameSection: json[StudentFieldsGoogleSheet.nameSection],
      email: json[StudentFieldsGoogleSheet.email],
      progress: json[StudentFieldsGoogleSheet.progress],);

  static StudentModel fromJsontwo(Map<String, dynamic> json, int index) => StudentModel(
        indexRow: index + 2,
        id: json[StudentFieldsGoogleSheet.id],
        studentName: json[StudentFieldsGoogleSheet.studentName],
        nameSection: json[StudentFieldsGoogleSheet.nameSection],
        email: json[StudentFieldsGoogleSheet.email],
        progress: json[StudentFieldsGoogleSheet.progress],
      );
}