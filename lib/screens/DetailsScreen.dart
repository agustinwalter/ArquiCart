import 'package:arquicart/models/Building.dart';
import 'package:arquicart/provider/BuildingModel.dart';
import 'package:arquicart/widgets/Images.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  final Building building;
  DetailsScreen({@required this.building});
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String address;

  @override
  void initState() {
    super.initState();
    address = widget.building.address;
    if (address == '') {
      BuildingModel()
          .getAndSetAddress(widget.building.uid, widget.building.location)
          .then((add) => setState(() => address = add));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del edificio'),
        backgroundColor: Color(0xFF3c8bdc),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 20),
        shrinkWrap: true,
        children: [
          Images(height: 200, images: widget.building.images),
          // Name
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Text(
              widget.building.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          // Descripción
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Text(
              widget.building.description,
              style: TextStyle(fontSize: 16),
            ),
          ),
          _data('Dirección: ', address),
          _data('Arquitecto/s: ', widget.building.architects),
          // Extra data
          widget.building.extraData != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.building.extraData
                      .map((data) => _data('${data['key']}: ', data['value']))
                      .toList(),
                )
              : SizedBox.shrink(),
          SizedBox(height: 12),
          // Center(
          //   child: RaisedButton.icon(
          //     onPressed: () {},
          //     color: Color(0xFF3c8bdc),
          //     textColor: Colors.white,
          //     icon: Icon(Icons.edit),
          //     label: Text('EDITAR INFORMACIÓN'),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _data(String left, String right) {
    return Padding(
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
    );
  }
}
