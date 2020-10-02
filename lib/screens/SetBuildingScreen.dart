import 'dart:async';
import 'package:arquicart/provider/BuildingModel.dart';
import 'package:arquicart/provider/UserModel.dart';
import 'package:arquicart/widgets/AddressField.dart';
import 'package:arquicart/widgets/CustomTextField.dart';
import 'package:arquicart/widgets/ExtraData.dart';
import 'package:arquicart/widgets/ExtraDataDialog.dart';
import 'package:arquicart/widgets/LoadingOverlay.dart';
import 'package:arquicart/models/Building.dart';
import 'package:arquicart/widgets/Images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

GooglePlace googlePlace =
    GooglePlace("AIzaSyDZ3M0YxKFS3K3GbRgHcXUpUFYdfhvctEo");

class SetBuildingScreen extends StatefulWidget {
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Asset> images = [];
  bool publishing = false;
  bool published = false;
  List<Map<String, String>> _extraData = [];
  AutocompletePrediction _placeSelected;
  String sessionToken;

  @override
  void initState() {
    super.initState();
    _generateNewSessionToken();
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
    super.dispose();
  }

  _generateNewSessionToken() => sessionToken = Uuid().v4();

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
    if (!_formKey.currentState.validate()) return;
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
    if (_placeSelected == null) {
      // Agrega una dirección
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Agrega una dirección válida'),
          content: Text(
              'Debes seleccionar una dirección de la lista de sugerencias.'),
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

    // Get location of the address an generate a new token
    DetailsResponse details = await googlePlace.details.get(
      _placeSelected.placeId,
      fields: "geometry",
      sessionToken: sessionToken,
    );
    _generateNewSessionToken();
    
    final double lat = details.result.geometry.location.lat;
    final double lon = details.result.geometry.location.lng;
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
      address: _placeSelected.description,
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
      builder: (context) => ExtraDataDialog(
        keyCtrl: _keyCtrl,
        valueCtrl: _valueCtrl,
        valueFocus: _valueFocus,
        onDataAdded: () {
          setState(() {
            _extraData.add(
              {'key': _keyCtrl.text, 'value': _valueCtrl.text},
            );
          });
        },
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
                CustomTextField(
                  label: 'Nombre del edificio *',
                  controller: _nameCtrl,
                  requiredField: true,
                  onEditingComplete: () => _addressFocus.requestFocus(),
                ),
                AddressField(
                  addressCtrl: _addressCtrl,
                  addressFocus: _addressFocus,
                  onSelected: (place) {
                    _placeSelected = place;
                    _architectFocus.requestFocus();
                  },
                  sessionToken: sessionToken,
                  googlePlace: googlePlace,
                ),
                SizedBox(height: 12),
                CustomTextField(
                  label: 'Arquitecto/s *',
                  controller: _architectCtrl,
                  requiredField: true,
                  focusNode: _architectFocus,
                  onEditingComplete: () => _descriptionFocus.requestFocus(),
                ),
                CustomTextField(
                  label: 'Descripción *',
                  controller: _descriptionCtrl,
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
                              (data) => ExtraData(
                                left: data['key'],
                                right: data['value'],
                                onTap: () => setState(
                                  () => _extraData.removeWhere(
                                    (d) => d['value'] == data['value'],
                                  ),
                                ),
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
        LoadingOverlay(publishing, false),
        LoadingOverlay(published, true),
      ],
    );
  }
}
