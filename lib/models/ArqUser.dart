class ArqUser{
  String uid;
  String name;
  String email;
  String photo;
  String category;
  bool isAdmin;

  ArqUser({
    this.uid,
    this.name,
    this.email,
    this.photo,
    this.category,
    this.isAdmin: false,
  });
}

// enum Categories{
//   Estudiante,
//   Arquitecto,
//   Aficionado,
//   Otro
// }