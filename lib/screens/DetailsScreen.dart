import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final List<String> images = [
    'https://i.pinimg.com/736x/97/c8/ae/97c8aead46d4911f32c1d98f942be1f8.jpg',
    'https://i.pinimg.com/736x/a0/6f/4c/a06f4cffd3a889ed3304324723e6f97b.jpg',
    'https://www.arkiplus.com/wp-content/uploads/2016/02/dise%C3%B1o-edificios-modernos.jpg',
    'https://i.ytimg.com/vi/2GLS-TsCpdY/maxresdefault.jpg',
    'https://images.adsttc.com/media/images/5cda/f8ec/284d/d10f/9600/000c/medium_jpg/4-4.jpg'
  ];
  final Map<String, dynamic> data = {
    'name': 'Edificio Mariano Moreno',
    'architect': 'Juan Dominguez',
    'studio': 'MM',
    'startBuilding': '2008',
    'endBuilding': '2013',
    'inauguration': '2014',
    'description':
        'Un edificio ​es una construcción dedicada a albergar distintas actividades humanas: vivienda, templo, teatro, comercio, etc. La inventiva humana ha ido mejorando las técnicas de construcción y decoración de sus partes, hasta hacer de la actividad de edificar una de las bellas artes: la arquitectura.'
  };

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
          Container(
            height: 200,
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  child: Image.network(
                    images[index],
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
          Divider(),
          // Name
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Text(
              data['name'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          // Column(
          //   children: [0,1,2,3].map((text) => _dataInfo()).toList(),
          // ),
          // Arquitecto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: <TextSpan>[
                  TextSpan(text: 'Arquitecto: '),
                  TextSpan(
                    text: 'Juan Dominguez',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // Estudio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: <TextSpan>[
                  TextSpan(text: 'Estudio: '),
                  TextSpan(
                    text: 'MM',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // Periodo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: <TextSpan>[
                  TextSpan(text: 'Periodo de construcción: '),
                  TextSpan(
                    text: '2008 a 2013',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // Inauguración
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: <TextSpan>[
                  TextSpan(text: 'Año de inauguración: '),
                  TextSpan(
                    text: '2014',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          // Descripción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'Un edificio ​es una construcción dedicada a albergar distintas actividades humanas: vivienda, templo, teatro, comercio, etc. La inventiva humana ha ido mejorando las técnicas de construcción y decoración de sus partes, hasta hacer de la actividad de edificar una de las bellas artes: la arquitectura.',
              style: TextStyle(fontSize: 16),
            ),
          ),
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

  // Widget _dataInfo() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //     child: RichText(
  //       text: TextSpan(
  //         style: TextStyle(color: Colors.black, fontSize: 16),
  //         children: <TextSpan>[
  //           TextSpan(text: '${data['']}: '),
  //           TextSpan(
  //             text: 'Juan Dominguez',
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
