import 'package:arquicart/widgets/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

class AddressField extends StatefulWidget {
  final TextEditingController addressCtrl;
  final FocusNode addressFocus;
  final Function(AutocompletePrediction) onSelected;
  final String sessionToken;
  final GooglePlace googlePlace;
  AddressField({
    @required this.addressCtrl,
    @required this.addressFocus,
    @required this.onSelected,
    @required this.sessionToken, 
    @required this.googlePlace,
  });
  @override
  _AddressFieldState createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  bool _showField = true;
  List<AutocompletePrediction> _searchMatches = [];
  AutocompletePrediction _selectedAddress;

  @override
  void initState() {
    widget.addressCtrl.addListener(() async {
      String text = widget.addressCtrl.text;
      bool search = false;
      for (var i = 0; i < 10; i++) {
        if (text.contains(i.toString())) search = true;
      }
      if (search && mounted) {
        AutocompleteResponse response = await widget.googlePlace.autocomplete.get(
          text,
          sessionToken: widget.sessionToken,
          language: 'es',
        );
        setState(() {
          if (response.predictions.length > 0 && mounted && _showField) {
            _searchMatches = response.predictions.take(4).toList();
          } else
            _searchMatches = [];
        });
      }
      if (text == '' && mounted) setState(() => _searchMatches = []);
    });
    super.initState();
  }

  _onSelected(AutocompletePrediction match) {
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
      widget.addressCtrl.text = _selectedAddress.description;
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
                    Expanded(child: Text(match.description)),
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
            Expanded(child: Text(_selectedAddress.description)),
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
