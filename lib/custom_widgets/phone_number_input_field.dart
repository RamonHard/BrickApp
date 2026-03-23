import 'package:brickapp/models/country_code_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhoneInputField extends StatefulWidget {
  const PhoneInputField({
    Key? key,
    required this.hintText,
    this.textEditingController,
    this.onChanged,
    this.onCountryCodeChanged,
  }) : super(key: key);

  final String hintText;
  final TextEditingController? textEditingController;
  final Function(String)? onChanged;
  final Function(String)? onCountryCodeChanged;

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  String selectedCountryCode = '+256'; // Default to Uganda
  final TextEditingController _phoneController = TextEditingController();
  late TextEditingController _actualController;

  // List of common African country codes
  final List<CountryCode> countryCodes = [
    CountryCode('🇺🇬', '+256', 'Uganda'),
    CountryCode('🇰🇪', '+254', 'Kenya'),
    CountryCode('🇹🇿', '+255', 'Tanzania'),
    CountryCode('🇷🇼', '+250', 'Rwanda'),
    CountryCode('🇧🇮', '+257', 'Burundi'),
    CountryCode('🇨🇩', '+243', 'DR Congo'),
    CountryCode('🇸🇸', '+211', 'South Sudan'),
    CountryCode('🇪🇹', '+251', 'Ethiopia'),
    CountryCode('🇳🇬', '+234', 'Nigeria'),
    CountryCode('🇿🇦', '+27', 'South Africa'),
    CountryCode('🇬🇭', '+233', 'Ghana'),
    CountryCode('🇸🇳', '+221', 'Senegal'),
    CountryCode('🇲🇦', '+212', 'Morocco'),
    CountryCode('🇪🇬', '+20', 'Egypt'),
    CountryCode('🇺🇸', '+1', 'USA'),
    CountryCode('🇬🇧', '+44', 'UK'),
    CountryCode('🇨🇦', '+1', 'Canada'),
    CountryCode('🇦🇺', '+61', 'Australia'),
  ];

  @override
  void initState() {
    super.initState();
    _actualController = widget.textEditingController ?? TextEditingController();
    _phoneController.text = _extractPhoneNumber(_actualController.text);
    _updateSelectedCountryCode(_actualController.text);

    _phoneController.addListener(_onPhoneNumberChanged);
  }

  @override
  void dispose() {
    if (widget.textEditingController == null) {
      _actualController.dispose();
    }
    _phoneController.removeListener(_onPhoneNumberChanged);
    _phoneController.dispose();
    super.dispose();
  }

  String _extractPhoneNumber(String fullNumber) {
    for (var country in countryCodes) {
      if (fullNumber.startsWith(country.code)) {
        return fullNumber.substring(country.code.length);
      }
    }
    return fullNumber;
  }

  void _updateSelectedCountryCode(String fullNumber) {
    for (var country in countryCodes) {
      if (fullNumber.startsWith(country.code)) {
        setState(() {
          selectedCountryCode = country.code;
        });
        widget.onCountryCodeChanged?.call(selectedCountryCode);
        break;
      }
    }
  }

  void _onPhoneNumberChanged() {
    final fullNumber = selectedCountryCode + _phoneController.text;
    _actualController.text = fullNumber;
    widget.onChanged?.call(fullNumber);

    // Move the cursor to the end
    _actualController.selection = TextSelection.fromPosition(
      TextPosition(offset: _actualController.text.length),
    );
  }

  void _onCountryCodeChanged(String? newCode) {
    if (newCode != null && newCode != selectedCountryCode) {
      setState(() {
        selectedCountryCode = newCode;
      });
      _onPhoneNumberChanged();
      widget.onCountryCodeChanged?.call(selectedCountryCode);
    }
  }

  String _getFullPhoneNumber() {
    return selectedCountryCode + _phoneController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          children: [
            // Country Code Picker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(100),
                ),
                border: Border(
                  right: BorderSide(color: Colors.white, width: 1),
                ),
              ),
              child: DropdownButton<String>(
                value: selectedCountryCode,
                dropdownColor: Colors.grey[900],
                underline: const SizedBox(),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 24,
                ),
                style: GoogleFonts.actor(color: Colors.white, fontSize: 16),
                items:
                    countryCodes.map((country) {
                      return DropdownMenuItem<String>(
                        value: country.code,
                        child: Row(
                          children: [
                            Text(
                              country.flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              country.code,
                              style: GoogleFonts.actor(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: _onCountryCodeChanged,
              ),
            ),
            // Phone Number Input
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.actor(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(8.0),
                  hintText: widget.hintText,
                  hintStyle: GoogleFonts.actor(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
