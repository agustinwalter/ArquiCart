import 'package:arquicart/models/Building.dart';
import 'package:arquicart/widgets/Images.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final Building building;

  DetailsScreen({@required this.building});

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
          building.images.length > 0
              ? Images(height: 200, images: building.images)
              : SizedBox.shrink(),
          building.name != null
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: Text(
                    building.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                )
              : SizedBox.shrink(),
          building.architect != null
              ? _data('Arquitecto: ', building.architect)
              : SizedBox.shrink(),
          building.studio != null
              ? _data('Estudio: ', building.studio)
              : SizedBox.shrink(),
          building.yearBegin != null
              ? _data('Periodo de construcción: ',
                  '${building.yearBegin} a ${building.yearEnd}')
              : SizedBox.shrink(),
          building.yearOpen != null
              ? _data('Año de inauguración: ', '${building.yearOpen}')
              : SizedBox.shrink(),
          building.direction != null
              ? _data('Dirección: ', building.direction)
              : SizedBox.shrink(),
          Divider(),
          // Descripción
          building.description != null
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    building.description,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : SizedBox.shrink(),
          Divider(),
          SizedBox(height: 12),
          Center(
            child: RaisedButton.icon(
              onPressed: () {},
              color: Color(0xFF3c8bdc),
              textColor: Colors.white,
              icon: Icon(Icons.edit),
              label: Text('EDITAR INFORMACIÓN'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _data(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 16),
          children: <TextSpan>[
            TextSpan(text: left),
            TextSpan(
              text: right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
