import 'package:arquicart/models/ArqUser.dart';
import 'package:arquicart/provider/UserModel.dart';
import 'package:arquicart/screens/SetBuildingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:provider/provider.dart';

class LoginDialog extends StatefulWidget {
  final bool fromFab;
  const LoginDialog({Key key, this.fromFab: false}) : super(key: key);
  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  String dropdownValue = 'Estudiante';
  final List<String> categories = [
    'Estudiante',
    'Arquitecto',
    'Aficionado',
    'Otro'
  ];

  Future<void> _signInWithGoogle() async {
    ArqUser user = await Provider.of<UserModel>(
      context,
      listen: false,
    ).signInWithGoogle();
    if (!widget.fromFab) {
      setState(() {});
    } else {
      if (user.category == null) {
        setState(() {});
      } else {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SetBuildingScreen()),
        );
      }
    }
  }

  Future<void> _closeSession() async {
    await Provider.of<UserModel>(context, listen: false).closeSession();
    setState(() {});
  }

  Future<void> _setCategory() async {
    await Provider.of<UserModel>(context, listen: false)
        .setCategory(dropdownValue);
    if (!widget.fromFab) {
      setState(() {});
    } else {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SetBuildingScreen()),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.transparent,
      child: Stack(
        overflow: Overflow.visible,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 44,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xbb234aa2),
                  Color(0xbb3c8bdc),
                ],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Consumer<UserModel>(
              builder: (context, userModel, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _content(userModel.currentUser),
                );
              },
            ),
          ),
          // Person icon floating
          Positioned(
            top: -24,
            right: -24,
            child: Material(
              elevation: 18,
              shape: CircleBorder(),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFF3c8bdc),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _content(ArqUser currentUser) {
    // User not logged
    if (currentUser == null) {
      return [
        Text(
          !widget.fromFab
              ? '¡Bienvenido!'
              : 'Debes ingresar para poder agregar un edificio.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 16),
        GoogleSignInButton(
          onPressed: _signInWithGoogle,
          text: 'Ingresa con Google  ',
          borderRadius: 20,
        )
      ];
    }
    // User without category
    if (currentUser.category == null) {
      return [
        // Message
        Text(
          '¿Qué perfil se adapta mejor a ti?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        // Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: DropdownButton<String>(
            value: dropdownValue,
            dropdownColor: Color(0xFF3c8bdc),
            style: TextStyle(color: Colors.white, fontSize: 18),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
            underline: Container(
              height: 2,
              color: Colors.white,
            ),
            onChanged: (String newValue) =>
                setState(() => dropdownValue = newValue),
            items: categories.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        // Button
        RaisedButton(
          onPressed: _setCategory,
          color: Colors.white,
          child: Text('GUARDAR'),
        ),
        SizedBox(height: 20),
        // Close session
        FlatButton(
          onPressed: _closeSession,
          textColor: Colors.red[200],
          child: Text(
            'CERRAR SESIÓN',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ];
    } else {
      // User logged
      return [
        // Name and photo
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(46, 8, 12, 8),
              margin: EdgeInsets.only(left: 60),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Text(
                'AGUSTÍN WALTER',
                style: TextStyle(
                  color: Color(0xFF234aa2),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CircleAvatar(
              radius: 46,
              backgroundColor: Colors.white,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(42)),
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xFF424242),
                  child: currentUser.photo == null
                      ? Icon(
                          Icons.person,
                          color: Color(0xFFbdbdbd),
                          size: 68,
                        )
                      : Image.network(currentUser.photo),
                ),
              ),
            ),
          ],
        ),
        // Category
        Container(
          width: double.maxFinite,
          padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
          margin: EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Text(
            currentUser.category.toUpperCase(),
            style: TextStyle(
              color: Color(0xFF234aa2),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 24),
        // Close session
        FlatButton(
          onPressed: _closeSession,
          textColor: Colors.red[200],
          child: Text(
            'CERRAR SESIÓN',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ];
    }
  }
}
