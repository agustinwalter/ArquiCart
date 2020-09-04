import 'package:arquicart/provider/BuildingModel.dart';
import 'package:arquicart/provider/UserModel.dart';
import 'package:geohash/geohash.dart';
import 'package:google_maps_webservice/places.dart';
import 'dart:io';
import 'package:arquicart/models/Building.dart';
import 'package:arquicart/widgets/Images.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SetBuildingScreen extends StatefulWidget {
  final Building building;
  const SetBuildingScreen({this.building});
  @override
  _SetBuildingScreenState createState() => _SetBuildingScreenState();
}

class _SetBuildingScreenState extends State<SetBuildingScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _architectCtrl = TextEditingController();
  final TextEditingController _studioCtrl = TextEditingController();
  final TextEditingController _yearBeginCtrl = TextEditingController();
  final TextEditingController _yearEndCtrl = TextEditingController();
  final TextEditingController _yearOpenCtrl = TextEditingController();
  final TextEditingController _directionCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final FocusNode _architectFocus = FocusNode();
  final FocusNode _studioFocus = FocusNode();
  final FocusNode _yearBeginFocus = FocusNode();
  final FocusNode _yearEndFocus = FocusNode();
  final FocusNode _yearOpenFocus = FocusNode();
  final FocusNode _directionFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  List<File> images = [];
  final places = GoogleMapsPlaces(
    apiKey: "AIzaSyDVnH1nR6sEUHDS3Z5X6Rf32TRFWmB8ifg",
  );
  List<PlacesSearchResult> _searchMatches = [];
  PlacesSearchResult _searchSelected;
  bool publishing = false;
  bool published = false;

  @override
  void initState() {
    if (widget.building != null) {
      _nameCtrl.text = widget.building.name;
      _architectCtrl.text = widget.building.architect;
      _studioCtrl.text = widget.building.studio;
      _yearBeginCtrl.text = widget.building.yearBegin.toString();
      _yearEndCtrl.text = widget.building.yearEnd.toString();
      _yearOpenCtrl.text = widget.building.yearOpen.toString();
      _directionCtrl.text = widget.building.direction;
      _descriptionCtrl.text = widget.building.description;
    }
    _directionCtrl.addListener(() async {
      if (_directionCtrl.text.length > 2) {
        PlacesSearchResponse response = await places.searchByText(
          _directionCtrl.text,
        );
        if (response.isOkay) {
          setState(() => _searchMatches = response.results.take(5).toList());
        }
      } else {
        setState(() => _searchMatches = []);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _architectCtrl.dispose();
    _studioCtrl.dispose();
    _yearBeginCtrl.dispose();
    _yearEndCtrl.dispose();
    _yearOpenCtrl.dispose();
    _directionCtrl.dispose();
    _descriptionCtrl.dispose();
    _architectFocus.dispose();
    _studioFocus.dispose();
    _yearBeginFocus.dispose();
    _yearEndFocus.dispose();
    _yearOpenFocus.dispose();
    _directionFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  void _addImages() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Subir imagen'),
          content: Text('¿De dónde quieres subir la imagen?'),
          actions: <Widget>[
            FlatButton(
              child: Text('CÁMARA'),
              onPressed: () => _getImage(ImageSource.camera),
            ),
            FlatButton(
              child: Text('GALERÍA'),
              onPressed: () => _getImage(ImageSource.gallery),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    Navigator.of(context).pop();
    final pickedFile = await ImagePicker().getImage(source: source);
    setState(() => images.add(File(pickedFile.path)));
  }

  Future<void> _addBuilding() async {
    if (_directionCtrl.text.length > 0) {
      setState(() => publishing = true);
      String geohash = Geohash.encode(
        _searchSelected.geometry.location.lat,
        _searchSelected.geometry.location.lng,
      );
      String userUid = Provider.of<UserModel>(
        context,
        listen: false,
      ).currentUser.uid;
      String uid = await BuildingModel().setBuilding(Building(
        name: _nameCtrl.text,
        architect: _architectCtrl.text,
        studio: _studioCtrl.text,
        yearBegin: _yearBeginCtrl.text,
        yearEnd: _yearEndCtrl.text,
        yearOpen: _yearOpenCtrl.text,
        direction: _directionCtrl.text,
        description: _descriptionCtrl.text,
        lat: _searchSelected.geometry.location.lat,
        lon: _searchSelected.geometry.location.lng,
        geohash: geohash,
        publishedBy: userUid,
      ));
      // Upload images
      Future.delayed(const Duration(milliseconds: 2000), () {
        setState(() {
          publishing = false;
          published = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Agrega un edificio'),
            backgroundColor: Color(0xFF3c8bdc),
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              Text(
                  'Completa los siguientes datos para agregar un edificio, solo la direción es obligatoria.'),
              SizedBox(height: 12),
              _textField(
                'Nombre del edificio',
                _nameCtrl,
                autofocus: true,
                onEditingComplete: () => _directionFocus.requestFocus(),
              ),
              _textField('Dirección', _directionCtrl,
                  focusNode: _directionFocus,
                  onEditingComplete: () => _architectFocus.requestFocus(),
                  paddingBottom: 0),
              _searchMatches.length > 0 ? _suggestions() : SizedBox(height: 12),
              _textField(
                'Nombre del arquitecto',
                _architectCtrl,
                focusNode: _architectFocus,
                onEditingComplete: () => _studioFocus.requestFocus(),
              ),
              _textField(
                'Nombre del estudio',
                _studioCtrl,
                focusNode: _studioFocus,
                onEditingComplete: () => _yearBeginFocus.requestFocus(),
              ),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      'Año de inicio de obra',
                      _yearBeginCtrl,
                      keyboardType: TextInputType.number,
                      focusNode: _yearBeginFocus,
                      onEditingComplete: () => _yearEndFocus.requestFocus(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      'Año de fin de obra',
                      _yearEndCtrl,
                      keyboardType: TextInputType.number,
                      focusNode: _yearEndFocus,
                      onEditingComplete: () => _yearOpenFocus.requestFocus(),
                    ),
                  ),
                ],
              ),
              _textField(
                'Año de inauguración',
                _yearOpenCtrl,
                keyboardType: TextInputType.number,
                focusNode: _yearOpenFocus,
                onEditingComplete: () => _descriptionFocus.requestFocus(),
              ),
              _textField(
                'Descripción',
                _descriptionCtrl,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: 12,
                focusNode: _descriptionFocus,
              ),
              Divider(),
              images.length > 0
                  ? Images(height: 200, images: images, fromNetwork: false)
                  : SizedBox.shrink(),
              images.length == 0
                  ? Center(
                      child: Icon(
                        Icons.image,
                        size: 60,
                        color: Colors.grey[300],
                      ),
                    )
                  : SizedBox.shrink(),
              OutlineButton(
                onPressed: _addImages,
                borderSide: BorderSide(width: 2, color: Color(0xFF3c8bdc)),
                textColor: Color(0xFF3c8bdc),
                child: Text('SUBIR IMÁGENES'),
              ),
              Divider(),
              SizedBox(height: 8),
              RaisedButton(
                onPressed: _addBuilding,
                color: Color(0xFF3c8bdc),
                textColor: Colors.white,
                child: Text('AGREGAR EDIFICIO'),
              ),
            ],
          ),
        ),
        _overlay(publishing, false),
        _overlay(published, true),
      ],
    );
  }

  Widget _overlay(bool show, bool isDone) {
    if (show) {
      return Material(
        color: Colors.white.withOpacity(.8),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isDone
                  ? Icon(
                      Icons.done,
                      size: 60,
                      color: Colors.green,
                    )
                  : CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Text(
                  isDone
                      ? '¡Listo! Los datos del edificio se han enviado a revisión, pronto estarán publicados.'
                      : 'Los datos se están publicando, no cierres esta pantalla hasta que finalice el proceso.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              isDone
                  ? RaisedButton(
                      onPressed: () => Navigator.pop(context),
                      color: Color(0xFF3c8bdc),
                      textColor: Colors.white,
                      child: Text('IR AL INICIO'),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType: TextInputType.text,
    TextInputAction textInputAction: TextInputAction.next,
    int maxLines: 1,
    FocusNode focusNode,
    void Function() onEditingComplete,
    double paddingBottom: 12,
    bool autofocus: false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom),
      child: TextFormField(
        autofocus: autofocus,
        controller: controller,
        focusNode: focusNode,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        minLines: 1,
        maxLines: maxLines,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          isDense: true,
          labelText: label,
        ),
      ),
    );
  }

  Widget _suggestions() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Column(
        children: _searchMatches.map((match) {
          return InkWell(
            onTap: () {
              _directionCtrl.text = match.formattedAddress;
              _searchSelected = match;
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Icon(Icons.location_on),
                  SizedBox(width: 8),
                  Expanded(child: Text(match.formattedAddress))
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
