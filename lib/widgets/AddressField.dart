import 'package:arquicart/widgets/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class AddressField extends StatefulWidget {
  final TextEditingController addressCtrl;
  final FocusNode addressFocus;
  final Function(PlacesSearchResult) onSelected;
  final places = GoogleMapsPlaces(
    apiKey: "AIzaSyDZ3M0YxKFS3K3GbRgHcXUpUFYdfhvctEo",
  );
  AddressField({
    @required this.addressCtrl,
    @required this.addressFocus,
    @required this.onSelected,
  });
  @override
  _AddressFieldState createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  bool _showField = true;
  List<PlacesSearchResult> _searchMatches = [];
  PlacesSearchResult _selectedAddress;

  @override
  void initState() {
    widget.addressCtrl.addListener(() async {
      String text = widget.addressCtrl.text;
      bool search = false;
      for (var i = 0; i < 10; i++) {
        if (text.contains(i.toString())) search = true;
      }
      if (search && mounted) {
        PlacesSearchResponse response = await widget.places.searchByText(text);
        setState(() {
          if (response.results.length > 0 && mounted && _showField) {
            _searchMatches = response.results.take(4).toList();
          } else
            _searchMatches = [];
        });
      }
      if (text == '' && mounted) setState(() => _searchMatches = []);
    });
    super.initState();
  }

  _onSelected(PlacesSearchResult match) {
    widget.onSelected(match);
    setState(() {
      _selectedAddress = match;
      _showField = false;
      _searchMatches = [];
    });
  }

  _onEdit() {
    widget.onSelected(null);
    setState(() {
      widget.addressCtrl.text = _selectedAddress.formattedAddress;
      _selectedAddress = null;
      _searchMatches = [];
      _showField = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showField)
          CustomTextField(
            label: 'Dirección *',
            controller: widget.addressCtrl,
            focusNode: widget.addressFocus,
            requiredField: true,
            paddingBottom: 0,
          )
        else
          SizedBox.shrink(),
        if (_searchMatches.length > 0) searchMatches() else SizedBox.shrink(),
        if (_selectedAddress != null) selectedAddress() else SizedBox.shrink()
      ],
    );
  }

  Widget searchMatches() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _searchMatches.map((match) {
          return GestureDetector(
            onTap: () => _onSelected(match),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on),
                    Expanded(child: Text(match.formattedAddress)),
                  ],
                ),
                Divider()
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget selectedAddress() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dirección *'),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: Color(0xFF3c8bdc),
            ),
            SizedBox(width: 4),
            Expanded(child: Text(_selectedAddress.formattedAddress)),
            SizedBox(width: 4),
            GestureDetector(
              onTap: _onEdit,
              child: Icon(Icons.edit),
            ),
          ],
        )
      ],
    );
  }
}
