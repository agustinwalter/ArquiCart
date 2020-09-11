import 'package:algolia/algolia.dart';
import 'package:arquicart/provider/AlgoliaProvider.dart';
import 'package:arquicart/provider/UserModel.dart';
import 'package:arquicart/widgets/LoginDialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget {
  final FunctionCallback onResultTap;
  const CustomAppBar({@required this.onResultTap});
  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  List<AlgoliaObjectSnapshot> _searchMatches = [];
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    controller.addListener(() {
      if (controller.text.length > 2) {
        Provider.of<AlgoliaProvider>(context, listen: false)
            .search(controller.text)
            .then((matches) => setState(() => _searchMatches = matches));
      } else {
        setState(() => _searchMatches = []);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

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
                height: 56,
              ),
            ),
            // Search Box
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xbb3c8bdc),
                  borderRadius: BorderRadius.all(const Radius.circular(24)),
                ),
                margin: EdgeInsets.fromLTRB(12, 6, 12, 0),
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
                            focusNode: focusNode,
                            controller: controller,
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
                    // Resluts
                    _searchMatches.length > 0
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Divider(
                              height: 0,
                              color: Colors.white,
                            ),
                          )
                        : SizedBox.shrink(),
                    Column(
                      children: _searchMatches
                          .map((result) => _searchResult(result))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Account icon
            Consumer<UserModel>(
              builder: (context, userModel, child) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => LoginDialog(),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(22)),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFF3c8bdc),
                        child: userModel.currentUser == null
                            ? Icon(
                                Icons.person,
                                color: Colors.white,
                              )
                            : Image.network(userModel.currentUser.photo),
                      ),
                    ),
                  ),
                );
              },
            ),
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
                  color: Colors.white, fontSize: 20, fontFamily: 'Coolvetica'),
            ),
          ),
          Positioned(
            top: -50,
            left: -30,
            child: Image.asset(
              'assets/img/logo.png',
              height: 112,
            ),
          )
        ],
      ),
    );
  }

  Widget _searchResult(AlgoliaObjectSnapshot result) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: (){ 
          widget.onResultTap(result.data['lat'], result.data['lon'], result.objectID); 
          controller.text = '';
          focusNode.unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.data['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              result.data['address'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Text(
              result.data['architects'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef FunctionCallback = void Function(double lat, double lon, String buildingId);