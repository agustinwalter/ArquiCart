import 'package:algolia/algolia.dart';
import 'package:arquicart/provider/AlgoliaProvider.dart';
import 'package:arquicart/provider/UserModel.dart';
import 'package:arquicart/widgets/LoginDialog.dart';
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../globals.dart';

class CustomAppBar extends StatefulWidget {
  final OnResultTap onResultTap;
  final Function onLoadButtonTap;
  final LoadButtonStatus loadButtonStatus;
  const CustomAppBar({
    @required this.onResultTap,
    @required this.loadButtonStatus,
    @required this.onLoadButtonTap,
  });
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
        child: Column(
          children: [
            // Search bar and logo
            Row(
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
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 12, 0, 10),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
            // Load button
            if (widget.loadButtonStatus == LoadButtonStatus.loading ||
                widget.loadButtonStatus == LoadButtonStatus.visible)
              RaisedButton.icon(
                onPressed: widget.onLoadButtonTap,
                label: Text('Edificios en esta área'),
                icon: widget.loadButtonStatus == LoadButtonStatus.loading
                    ? Container(
                        child: CircularProgressIndicator(strokeWidth: 2),
                        width: 16,
                        height: 16,
                        margin: EdgeInsets.only(right: 8),
                      )
                    : Icon(
                        Icons.location_on,
                        color: Color(0xFF3c8bdc),
                      ),
                color: Colors.white,
                shape: StadiumBorder(),
              )
            else
              SizedBox.shrink()
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
              vertical: 70,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ArquiCart es una aplicación que consiste en una guía geoposicionada y colaborativa donde los usuarios y el administrador podrán cargar información sobre diferentes edificios que tengan valor arquitectónico o lugares que lo hayan tenido.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Coolvetica',
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Contacto:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Coolvetica',
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.mail),
                      color: Colors.white,
                      onPressed: () async {
                        final mailtoLink = Mailto(to: ['arquicart@gmail.com']);
                        await launch('$mailtoLink');
                      },
                    ),
                    IconButton(
                      icon: Icon(FontAwesome5Brands.whatsapp),
                      color: Colors.white,
                      onPressed: () async {
                        const url = 'https://wa.me/message/5S6VPL7ITULKO1';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(FontAwesome5Brands.facebook),
                      color: Colors.white,
                      onPressed: () async {
                        const url =
                            'https://www.facebook.com/ArquiCart-117378636773594';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(FontAwesome.instagram),
                      color: Colors.white,
                      onPressed: () async {
                        const url = 'https://www.instagram.com/arquicart/';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                  ],
                )
              ],
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
        onTap: () {
          widget.onResultTap(result);
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
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (result.data['address'] != '')
              Text(
                result.data['address'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              )
            else
              SizedBox.shrink(),
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

typedef OnResultTap = void Function(AlgoliaObjectSnapshot);
