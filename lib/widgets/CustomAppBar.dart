import 'package:arquicart/widgets/LoginDialog.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget {
  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  List<String> _searchMatches = [
    // 'Iglesia Nuestra Señora Del Lujan',
    // 'Iglesia de los Testigos de Jehova',
    // 'Iglesia Adventista del Septimo Día',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => _infoDialog(),
                );
              },
              child: Image.asset(
                'assets/img/logo.png',
                height: 48,
              ),
            ),
            // Search Box
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xbb3c8bdc),
                  borderRadius: BorderRadius.all(const Radius.circular(24)),
                ),
                margin: EdgeInsets.fromLTRB(12, 3, 12, 0),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search field
                    Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(0, 12, 0, 10),
                              isDense: true,
                              hintText: 'Busca edificios o lugares',
                              hintStyle: TextStyle(
                                color: Colors.white.withAlpha(200),
                              ),
                              border: InputBorder.none,
                            ),
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.search,
                          ),
                        ),
                      ],
                    ),
                    _searchMatches.length > 0
                        ? Divider(
                            height: 0,
                            color: Colors.white,
                          )
                        : SizedBox.shrink(),
                    Column(
                      children: _searchMatches
                          .map((text) => _searchResult(text))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Account icon
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => LoginDialog(),
                  );
                },
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFF3c8bdc),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.transparent,
      child: Stack(
        overflow: Overflow.visible,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 86,
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
            child: Text(
              'ArquiCart es una aplicación que consiste en una guía geoposicionada y colaborativa donde los usuarios y el administrador podrán cargar información sobre diferentes edificios que tengan valor arquitectónico o lugares que lo hayan tenido.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          Positioned(
            top: -46,
            left: -24,
            child: Image.asset(
              'assets/img/logo.png',
              height: 96,
            ),
          )
        ],
      ),
    );
  }

  Widget _searchResult(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
