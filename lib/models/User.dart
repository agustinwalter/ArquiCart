class User{
  final String uid;
  final String name;
  final String email;
  final String photo;
  final Categories category;
  final bool isAdmin;

  const User({
    this.uid,
    this.name,
    this.email,
    this.photo,
    this.category,
    this.isAdmin: false,
  });
}

enum Categories{
  Estudiante,
  Arquitecto,
  Aficionado,
  Otro
}