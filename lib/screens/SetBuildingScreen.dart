import 'package:arquicart/provider/BuildingModel.dart';
import 'package:arquicart/provider/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:arquicart/models/Building.dart';
import 'package:arquicart/widgets/Images.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
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
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _keyCtrl = TextEditingController();
  final TextEditingController _valueCtrl = TextEditingController();
  final FocusNode _architectFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _valueFocus = FocusNode();
  List<Asset> images = [];
  final places = GoogleMapsPlaces(
    apiKey: "AIzaSyDZ3M0YxKFS3K3GbRgHcXUpUFYdfhvctEo",
  );
  List<PlacesSearchResult> _searchMatches = [];
  PlacesSearchResult _searchSelected;
  bool publishing = false;
  bool published = false;
  List<Map<String, String>> _extraData = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.building != null) {
      _nameCtrl.text = widget.building.name;
      _architectCtrl.text = widget.building.architects;
      _addressCtrl.text = widget.building.address;
      _descriptionCtrl.text = widget.building.description;
    }
    _addressCtrl.addListener(() async {
      if (_addressCtrl.text.length > 2) {
        PlacesSearchResponse response = await places.searchByText(
          _addressCtrl.text,
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
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    _architectFocus.dispose();
    _addressFocus.dispose();
    _descriptionFocus.dispose();
    _valueFocus.dispose();
    places.dispose();
    super.dispose();
  }

  Future<void> _getImages() async {
    try {
      List<Asset> resultList = await MultiImagePicker.pickImages(
        maxImages: 50,
        materialOptions: MaterialOptions(
          actionBarColor: '#3c8bdc',
          statusBarColor: '#2d68a4',
        ),
      );
      setState(() => images.addAll(resultList));
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  _addBuilding() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    if (images.isEmpty) {
      // Agrega una imágen
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Agrega una imagen'),
          content: Text('Debes agregar al menos una imagen del edificio.'),
          actions: <Widget>[
            FlatButton(
              child: Text('ENTENDIDO'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }
    if (_searchSelected == null) {
      // Agregar una dirección válida
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Agrega una dirección válida'),
          content: Text('Debe seleccionar una dirección de la lista de sugerencias.'),
          actions: <Widget>[
            FlatButton(
              child: Text('ENTENDIDO'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => publishing = true);
    final double lat = _searchSelected.geometry.location.lat;
    final double lon = _searchSelected.geometry.location.lng;
    GeoPoint location = GeoPoint(lat, lon);
    String userUid = Provider.of<UserModel>(
      context,
      listen: false,
    ).currentUser.uid;
    String buildingUid = await Provider.of<BuildingModel>(
      context,
      listen: false,
    ).setBuilding(Building(
      name: _nameCtrl.text,
      architects: _architectCtrl.text,
      address: _addressCtrl.text,
      description: _descriptionCtrl.text,
      location: location,
      images: images,
      extraData: _extraData,
      publishedBy: userUid,
    ));
    // Upload images
    await BuildingModel().uploadImages(buildingUid, images);
    setState(() {
      publishing = false;
      published = true;
    });
  }

  _extraDataDialog() {
    _keyCtrl.clear();
    _valueCtrl.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Agrega un nuevo dato"),
        content: ListView(
          shrinkWrap: true,
          children: [
            _textField(
              'Nombre del dato',
              _keyCtrl,
              helperText: 'Ej.: "Año de innauguración"',
              autofocus: true,
              onEditingComplete: () => _valueFocus.requestFocus(),
            ),
            _textField(
              'Valor',
              _valueCtrl,
              focusNode: _valueFocus,
              textInputAction: TextInputAction.done,
              helperText: 'Ej: "2008"',
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actions: <Widget>[
          FlatButton(
            child: Text('CANCELAR'),
            textColor: Colors.grey,
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: Text('AGREGAR'),
            onPressed: () {
              if (_keyCtrl.text.length > 0 && _valueCtrl.text.length > 0) {
                setState(() {
                  _extraData.add(
                    {'key': _keyCtrl.text, 'value': _valueCtrl.text},
                  );
                });
              }
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
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
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text('Los campos con * son obligatorios'),
                SizedBox(height: 12),
                _textField(
                  'Nombre del edificio *',
                  _nameCtrl,
                  requiredField: true,
                  onEditingComplete: () => _addressFocus.requestFocus(),
                ),
                _textField(
                  'Dirección *',
                  _addressCtrl,
                  focusNode: _addressFocus,
                  requiredField: true,
                  onEditingComplete: () => _architectFocus.requestFocus(),
                  paddingBottom: 0,
                ),
                _searchMatches.length > 0
                    ? _suggestions()
                    : SizedBox(height: 12),
                _textField(
                  'Arquitecto/s *',
                  _architectCtrl,
                  requiredField: true,
                  focusNode: _architectFocus,
                  onEditingComplete: () => _descriptionFocus.requestFocus(),
                ),
                _textField(
                  'Descripción *',
                  _descriptionCtrl,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: 12,
                  requiredField: true,
                  focusNode: _descriptionFocus,
                ),
                if (_extraData.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos adicionales:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _extraData
                            .map(
                              (data) => _data(
                                '${data['key']}: ',
                                data['value'],
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 8),
                    ],
                  )
                else
                  SizedBox.shrink(),
                OutlineButton(
                  onPressed: _extraDataDialog,
                  borderSide: BorderSide(width: 2, color: Color(0xFF3c8bdc)),
                  textColor: Color(0xFF3c8bdc),
                  child: Text('AGREGAR MÁS DATOS'),
                ),
                Divider(),
                // Images
                if (images.length > 0)
                  Images(
                    height: 200,
                    images: images,
                    fromNetwork: false,
                    onRemoveImage: (index) => setState(
                      () => images.removeAt(index),
                    ),
                  )
                else
                  SizedBox.shrink(),
                if (images.length == 0)
                  Center(
                    child: Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.grey[300],
                    ),
                  )
                else
                  SizedBox.shrink(),
                OutlineButton(
                  onPressed: _getImages,
                  borderSide: BorderSide(width: 2, color: Color(0xFF3c8bdc)),
                  textColor: Color(0xFF3c8bdc),
                  child: Text('SUBIR IMÁGENES'),
                ),
                Text('Debes subir al menos una imagen.'),
                Divider(),
                SizedBox(height: 8),
                RaisedButton(
                  onPressed: _addBuilding,
                  color: Color(0xFF3c8bdc),
                  textColor: Colors.white,
                  child: Text('PUBLICAR EDIFICIO'),
                ),
              ],
            ),
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
              if (isDone)
                Icon(
                  Icons.done,
                  size: 60,
                  color: Colors.green,
                )
              else
                CircularProgressIndicator(),
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
              if (isDone)
                RaisedButton(
                  onPressed: () => Navigator.pop(context),
                  color: Color(0xFF3c8bdc),
                  textColor: Colors.white,
                  child: Text('IR AL INICIO'),
                )
              else
                SizedBox.shrink(),
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
    bool requiredField: false,
    String helperText,
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
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          isDense: true,
          labelText: label,
          helperText: helperText,
        ),
        validator: (value) {
          if (value.isEmpty && requiredField) {
            return 'Completa este campo';
          }
          return null;
        },
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
              _addressCtrl.text = match.formattedAddress;
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

  Widget _data(String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: <TextSpan>[
                  TextSpan(
                    text: left,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: right),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(
            () => _extraData.removeWhere((data) => data['value'] == right),
          ),
          child: Icon(Icons.close),
        )
      ],
    );
  }
}
