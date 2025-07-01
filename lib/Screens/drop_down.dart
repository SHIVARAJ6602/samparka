
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CascadingDropdownExample extends StatefulWidget {
  @override
  _CascadingDropdownExampleState createState() => _CascadingDropdownExampleState();
}

class _CascadingDropdownExampleState extends State<CascadingDropdownExample> {
  // Sample data for states, districts, and cities
  List<String> states = ['Karnataka', 'Maharashtra', 'Tamil Nadu'];
  List<String> districts = []; // Will be populated based on the selected state
  List<String> cities = []; // Will be populated based on the selected district

  String? selectedState;
  String? selectedDistrict;
  String? selectedCity;

  // Districts and cities data for Karnataka
  Map<String, List<String>> stateDistricts = {
    'Karnataka': ['Bangalore', 'Mysore', 'Mangalore'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai'],
  };

  Map<String, List<String>> districtCities = {
    'Bangalore': ['Whitefield', 'Koramangala', 'Electronic City'],
    'Mysore': ['Vijayanagar', 'Nazarbad', 'Gokulam'],
    'Mangalore': ['Pandeshwar', 'Bajpe', 'Kankanady'],
    'Mumbai': ['Andheri', 'Bandra', 'Juhu'],
    'Pune': ['Kothrud', 'Hinjewadi', 'Wakad'],
    'Nagpur': ['Civil Lines', 'Gandhi Baug', 'Ajni'],
    'Chennai': ['T Nagar', 'Adyar', 'Besant Nagar'],
    'Coimbatore': ['R S', 'Peelamedu', 'Ganapathy'],
    'Madurai': ['KK Nagar', 'Anna Nagar', 'Tallakulam'],
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cascading Dropdowns"),
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // State Dropdown
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade400, width: 1.0),
              ),
              child: DropdownButton<String>(
                hint: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Select State'),
                ),
                value: selectedState,
                onChanged: (String? newState) {
                  setState(() {
                    selectedState = newState;
                    selectedDistrict = null; // Reset district when state changes
                    selectedCity = null; // Reset city when district changes
                    districts = stateDistricts[selectedState] ?? [];
                  });
                },
                items: states.map<DropdownMenuItem<String>>((state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(state),
                    ),
                  );
                }).toList(),
                isExpanded: true,
                underline: Container(),
              ),
            ),
            SizedBox(height: 16),
            // District Dropdown (Depends on the selected state)
            if (selectedState != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400, width: 1.0),
                ),
                child: DropdownButton<String>(
                  hint: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Select District'),
                  ),
                  value: selectedDistrict,
                  onChanged: (String? newDistrict) {
                    setState(() {
                      selectedDistrict = newDistrict;
                      selectedCity = null; // Reset city when district changes
                      cities = districtCities[newDistrict] ?? [];
                    });
                  },
                  items: districts.map<DropdownMenuItem<String>>((district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(district),
                      ),
                    );
                  }).toList(),
                  isExpanded: true,
                  underline: Container(),
                ),
              ),
            SizedBox(height: 16),
            // City Dropdown (Depends on the selected district)
            if (selectedDistrict != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400, width: 1.0),
                ),
                child: DropdownButton<String>(
                  hint: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Select City'),
                  ),
                  value: selectedCity,
                  onChanged: (String? newCity) {
                    setState(() {
                      selectedCity = newCity;
                    });
                  },
                  items: cities.map<DropdownMenuItem<String>>((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(city),
                      ),
                    );
                  }).toList(),
                  isExpanded: true,
                  underline: Container(),
                ),
              ),
            SizedBox(height: 16),
            // Display selected values
            if (selectedState != null && selectedDistrict != null && selectedCity != null)
              Text(
                'Selected State: $selectedState\nSelected District: $selectedDistrict\nSelected City: $selectedCity',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
