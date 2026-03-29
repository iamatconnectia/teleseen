import 'package:collection/collection.dart' show IterableExtension;
import 'package:country_pickers/country.dart' as picker_country;
import 'package:country_pickers/country_pickers.dart' as picker;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/config/models/address_field_config.dart';
import '../../../common/constants.dart';
import '../../../common/tools/flash.dart';
import '../../../data/boxes.dart';
import '../../../models/index.dart'
    show Address, AppModel, CartModel, City, Country, CountryState, UserModel;
import '../../../modules/dynamic_layout/helper/helper.dart';
import '../../../services/index.dart';
import '../../../widgets/common/place_picker.dart';
import '../choose_address_screen.dart';
import 'checkout_action.dart';

part 'shipping_address_extension.dart';

class ShippingAddress extends StatefulWidget {
  final Function? onNext;

  const ShippingAddress({this.onNext});

  @override
  State<ShippingAddress> createState() => _ShippingAddressState();
}

class _ShippingAddressState extends State<ShippingAddress> {
  String get langCode => Provider.of<AppModel>(context, listen: false).langCode;
  bool get isDesktopLayout => Layout.isDisplayDesktop(context);

  bool _showSelectAddress = false;

  final _formKey = GlobalKey<FormState>();

  final Map<int, AddressFieldType> _fieldPosition = {};

  final Map<int, AddressFieldConfig> _configs = {};

  final Map<AddressFieldType, TextEditingController> _textControllers = {
    AddressFieldType.firstName: TextEditingController(),
    AddressFieldType.lastName: TextEditingController(),
    AddressFieldType.phoneNumber: TextEditingController(),
    AddressFieldType.email: TextEditingController(),
    AddressFieldType.country: TextEditingController(),
    AddressFieldType.state: TextEditingController(),
    AddressFieldType.city: TextEditingController(),
    AddressFieldType.apartment: TextEditingController(),
    AddressFieldType.block: TextEditingController(),
    AddressFieldType.street: TextEditingController(),
    AddressFieldType.zipCode: TextEditingController(),
    AddressFieldType.deliveryArea: TextEditingController(),
  };

  final TextEditingController _searchController = TextEditingController();

  final Map<AddressFieldType, FocusNode> _focusNodes = {
    AddressFieldType.firstName: FocusNode(),
    AddressFieldType.lastName: FocusNode(),
    AddressFieldType.phoneNumber: FocusNode(),
    AddressFieldType.email: FocusNode(),
    AddressFieldType.state: FocusNode(),
    AddressFieldType.city: FocusNode(),
    AddressFieldType.apartment: FocusNode(),
    AddressFieldType.block: FocusNode(),
    AddressFieldType.street: FocusNode(),
    AddressFieldType.zipCode: FocusNode(),
    AddressFieldType.deliveryArea: FocusNode(),
  };

  String? _selectedDeliveryArea;
  Address? address;
  List<Country>? countries = [];
  List<CountryState>? states = [];
  List<City>? cities = [];

  Map<String, Map<String, dynamic>> _shippingZones = {};
  bool _isLoadingZones = false;
  bool _isLoadingShipping = false;

  PhoneNumber? initialPhoneNumber;

  Future<void> _loadZones() async {
    setState(() {
      _isLoadingZones = true;
    });
    try {
      final zones = await Services().api.getShippingZones();
      if (zones != null) {
        final zoneMap = <String, Map<String, dynamic>>{};
        for (var zone in zones) {
           final id = (zone['id'] ?? zone['zone_id'])?.toString();
           if (id != null) {
             zoneMap[id] = Map<String, dynamic>.from(zone);
           }
        }
        setState(() {
          _shippingZones = zoneMap;
        });
        
        // If address has a delivery area, check if it matches an ID or Name
        if (address?.deliveryArea != null) {
            final currentArea = address!.deliveryArea!;
            if (_shippingZones.containsKey(currentArea)) {
                _selectedDeliveryArea = currentArea;
                Future.delayed(const Duration(milliseconds: 100), () {
                    _loadShippingWithDeliveryArea(_shippingZones[currentArea]!);
                });
            } else {
                // Try to find by name (migration/fallback)
                final foundZone = _shippingZones.values.firstWhereOrNull((zone) {
                    final name = (zone['name'] ?? zone['zone_name'] ?? zone['name_en'])?.toString();
                    return name == currentArea;
                });
                final id = (foundZone?['id'] ?? foundZone?['zone_id'])?.toString();
                if (id != null) {
                    _selectedDeliveryArea = id;
                    address!.deliveryArea = id;
                    Future.delayed(const Duration(milliseconds: 100), () {
                        _loadShippingWithDeliveryArea(_shippingZones[id]!);
                    });
                } else {
                     // Invalid or not found, maybe show as first one or empty?
                     // Letting it be null or keeping it might be safer, but for dropdown to work it needs to match a key.
                     _selectedDeliveryArea = null;
                }
            }
        }
        
        // Auto-select first zone if none selected
        if (_selectedDeliveryArea == null && _shippingZones.isNotEmpty) {
           final firstId = _shippingZones.keys.first;
           _selectedDeliveryArea = firstId;
             if (address != null) {
               address!.deliveryArea = firstId;
               // Delay to allow frame to settle
               Future.delayed(const Duration(milliseconds: 100), () {
                   final firstZone = _shippingZones[firstId];
                   if (firstZone != null) {
                      _loadShippingWithDeliveryArea(firstZone);
                   }
               });
             }
        }
      }
    } catch (e) {
      printLog('Error loading shipping zones: $e');
    } finally {
      setState(() {
        _isLoadingZones = false;
      });
    }
  }

  Future<void> _loadShippingWithDeliveryArea(Map zone) async {
    final rawId = zone['id'] ?? zone['zone_id'] ?? zone['id_en'];
    final deliveryAreaId = int.tryParse(rawId?.toString() ?? '');
    final nameKey = zone['name'] ?? zone['zone_name'] ?? zone['name_en'];
    final deliveryAreaName = nameKey?.toString() ?? '';
    
    if (deliveryAreaId == null) {
      printLog('Error: deliveryAreaId is null for zone: $zone');
      return;
    }
    
    // Update the selected delivery area in the cart model
    if (address != null) {
      _selectedDeliveryArea = deliveryAreaId.toString();
      address!.deliveryArea = deliveryAreaId.toString();

      final cartModel = Provider.of<CartModel>(context, listen: false);
      cartModel.deliveryAreaId = deliveryAreaId;
      cartModel.deliveryAreaName = deliveryAreaName;
      cartModel.setAddress(address);

      // Mark shipping as loading so the Next button waits
      if (mounted) setState(() { _isLoadingShipping = true; });

      try {
        print("ZONE ID(Calculate): $deliveryAreaId");
        
        // Extract cost from the zone data if available
        double cost = 0.0;
        final methods = zone['methods'];
        if (methods is List && methods.isNotEmpty) {
           final methodCost = methods[0]['cost'];
           cost = double.tryParse(methodCost?.toString() ?? '0') ?? 0.0;
           print("Extracted cost from zone data: $cost");
        }

        // Fetch cost from custom API as a secondary source/verification
        if (cost == 0) {
           print("Cost was 0 from zone data, calling calculateShipping...");
           cost = await Services().api.calculateShipping(deliveryAreaId!);
        }
        
        if (!mounted) return;

        // Apply cost to cart model
        cartModel.setShippingCost(cost);

        print("Final Custom Shipping Cost: ${cartModel.shippingCost}");
        print("Cart Total: ${cartModel.getTotal()}");

        // Update the UI to reflect the new shipping cost in the summary
        setState(() { _isLoadingShipping = false; });
      } catch (e) {
        printLog('Error calculate custom shipping: $e');
        if (mounted) setState(() { _isLoadingShipping = false; });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    _searchController.dispose();
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    /// Init field positions.
    for (var config in Configurations.addressFields) {
      final index = _fieldPosition.values.length;
      _configs[index] = config;
      _fieldPosition[index] = config.type;
    }

    /// Pre-fill the address fields.
    WidgetsBinding.instance.endOfFrame.then(
      (_) async {
        /// Load saved addresses.
        final addressValue =
            await Provider.of<CartModel>(context, listen: false).getAddress();
        if (addressValue != null) {
          updateAddress(addressValue);
        } else {
          var user = Provider.of<UserModel>(context, listen: false).user;
          setState(() {
            address = Address(country: kPaymentConfig.defaultCountryISOCode);
            if (kPaymentConfig.defaultStateISOCode != null) {
              address!.state = kPaymentConfig.defaultStateISOCode;
            }
            _textControllers[AddressFieldType.country]?.text =
                address!.country!;
            _textControllers[AddressFieldType.state]?.text = address!.state!;
            if (user != null) {
              address!.firstName = user.firstName;
              address!.lastName = user.lastName;
              address!.email = user.email;
              loadUserInfoFromAddress(address);
            }
          });
        }

        // Load shipping zones
        _loadZones();

        /// Init default fields.
        for (var field in _configs.values) {
          if ([
            AddressFieldType.searchAddress,
            AddressFieldType.selectAddress,
            AddressFieldType.country,
            AddressFieldType.state,
          ].contains(field.type)) {
            /// Not support default value.
            continue;
          }

          /// Replace current value with default value.
          /// Force to use default value for non-editable field.
          if (field.defaultValue.isNotEmpty && !field.editable) {
            _textControllers[field.type]?.text = field.defaultValue;
            onTextFieldSaved(field.defaultValue, field.type);
          }

          /// When the field is editable, replacing only when it's empty.
          if (field.defaultValue.isNotEmpty &&
              field.editable &&
              (_textControllers[field.type]?.text.isEmpty ?? false)) {
            _textControllers[field.type]?.text = field.defaultValue;
            onTextFieldSaved(field.defaultValue, field.type);
          }
        }

        if (kPhoneNumberConfig.enablePhoneNumberValidation) {
          /// Load phone number.
          try {
            final phoneNumber =
                _textControllers[AddressFieldType.phoneNumber]?.text.trim();
            if (phoneNumber?.isNotEmpty ?? false) {
              initialPhoneNumber = await PhoneNumber.getParsablePhoneNumber(
                PhoneNumber(
                  dialCode: kPhoneNumberConfig.dialCodeDefault,
                  isoCode: kPhoneNumberConfig.countryCodeDefault,
                  phoneNumber: phoneNumber,
                ),
              );
            }
            // In case the phone number is empty, a default `PhoneNumber`
            // object will still be assigned to initialize `dial Code` and
            // `iso Code` for the validator
            initialPhoneNumber ??= PhoneNumber(
              dialCode: kPhoneNumberConfig.dialCodeDefault,
              isoCode: kPhoneNumberConfig.countryCodeDefault,
            );
          } catch (e, trace) {
            printError(e, trace);
          }
        }

        /// Load country list.
        countries = await Services().widget.loadCountries();
        var country = countries!.firstWhereOrNull((element) =>
            element.id == address?.country || element.code == address?.country);
        if (country == null) {
          if (countries!.isNotEmpty) {
            country = countries![0];
            address!.country = countries![0].code;
          } else {
            country = Country.fromConfig(address!.country, null, null, []);
          }
        } else {
          address!.country = country.code;
          address!.countryId = country.id;
        }
        _textControllers[AddressFieldType.country]?.text = country.code!;
        refresh();

        /// Load states.
        states = await Services().widget.loadStates(country);
        refresh();

        /// Load cities.
        var state = states?.firstWhereOrNull(
          (element) =>
              element.id == address?.state || element.code == address?.state,
        );
        if (state != null) {
          cities = await Services().widget.loadCities(country, state);
          var city = cities?.firstWhereOrNull(
            (element) => element.name == address?.city,
          );

          /// Load zipCode
          if (city != null) {
            var zipCode =
                await Services().widget.loadZipCode(country, state, city);
            if (zipCode != null) {
              /// Override the default value with this value
              address!.zipCode = zipCode;
              _textControllers[AddressFieldType.zipCode]?.text = zipCode;
            }
          }
          refresh();
        }
      },
    );
  }

  void _onShowSelectAddressForDesktop() {
    setState(() {
      _showSelectAddress = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return SizedBox(height: 100, child: kLoadingWidget(context));
    }

    final items = _renderFormItem();
    final form = Form(
      key: _formKey,
      child: AutofillGroup(
        child: ShippingAddressLayout(
          children: List.generate(
            items.length,
            (index) => (
              items[index],
              _fieldPosition[index] ?? AddressFieldType.unknown,
              _configs[index]?.visible ?? true,
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isDesktopLayout) ...[
          if (_showSelectAddress) ...[
            ChooseAddressScreen(
              ChooseAddressArguments(
                address: address,
                isModal: true,
                callback: (p0) {
                  setState(() {
                    _showSelectAddress = false;
                  });
                  if (p0 != null) {
                    updateAddress(p0);
                  }
                },
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              child: Row(
                children: [
                  Text(
                    S.of(context).addNewAddress,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      height: 28 / 18,
                    ),
                  ),
                  const Spacer(),
                  _renderSelectAddressButton(),
                ],
              ),
            ),
            form,
          ],
        ] else
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 50.0,
                ),
                child: form,
              ),
            ),
          ),
        if (_showSelectAddress == false)
          Align(
            alignment: isDesktopLayout
                ? AlignmentDirectional.centerStart
                : Alignment.center,
            child: _buildBottom(isDesktopLayout),
          ),
      ],
    );
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  List<Widget> _renderFormItem() {
    var countryName = S.of(context).country;
    final currentCountry =
        _textControllers[AddressFieldType.country]?.text ?? '';
    if (currentCountry.isNotEmpty) {
      try {
        if (countries?.isEmpty ?? true) {
          countryName =
              picker.CountryPickerUtils.getCountryByIsoCode(currentCountry)
                  .name;
        } else {
          countryName = countries!
              .firstWhere((element) => element.code == currentCountry)
              .name!;
        }
      } catch (e) {
        countryName = S.of(context).country;
      }
    }

    return List.generate(_fieldPosition.length, (index) {
      final isVisible = _configs[index]?.visible ?? true;
      if (!isVisible) {
        return const SizedBox();
      }

      final currentFieldType =
          _fieldPosition[index] ?? AddressFieldType.unknown;

      if (currentFieldType == AddressFieldType.country) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktopLayout == false) ...[
              const SizedBox(height: 10),
              Text(
                S.of(context).country,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey),
              ),
            ],
            (countries!.length == 1)
                ? Text(
                    countryName,
                    style: const TextStyle(fontSize: 18),
                  )
                : DropdownStyleWidget(
                    countryName: countryName,
                    onTap: () => _openCountryPickerDialog(),
                  ),
          ],
        );
      }

      if (currentFieldType == AddressFieldType.state &&
          (states?.isNotEmpty ?? false)) {
        return renderStateInput(isDesktopLayout);
      }

      if (currentFieldType == AddressFieldType.city &&
          (cities?.isNotEmpty ?? false)) {
        return renderCityInput(index);
      }

      if (currentFieldType == AddressFieldType.searchAddress) {
        if (kPaymentConfig.allowSearchingAddress && kGoogleApiKey.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: ButtonTheme(
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                        backgroundColor: Theme.of(context).primaryColorLight,
                        elevation: 0.0,
                      ),
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PlacePicker(
                              kIsWeb
                                  ? kGoogleApiKey.web
                                  : isIos
                                      ? kGoogleApiKey.ios
                                      : kGoogleApiKey.android,
                            ),
                          ),
                        );

                        if (result is LocationResult) {
                          address!.country = result.country;
                          address!.street = result.street;
                          address!.state = result.state;
                          address!.city = result.city;
                          address!.zipCode = result.zip;
                          if (result.latLng?.latitude != null &&
                              result.latLng?.latitude != null) {
                            address!.mapUrl =
                                'https://maps.google.com/maps?q=${result.latLng?.latitude},${result.latLng?.longitude}&output=embed';
                            address!.latitude =
                                result.latLng?.latitude.toString();
                            address!.longitude =
                                result.latLng?.longitude.toString();
                          }

                          loadAddressFields(address);
                          final c =
                              Country(id: result.country, name: result.country);
                          states = await Services().widget.loadStates(c);
                          setState(() {});
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            CupertinoIcons.arrow_up_right_diamond,
                            size: 18,
                          ),
                          const SizedBox(width: 10.0),
                          Text(S.of(context).searchingAddress.toUpperCase()),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      }

      if (currentFieldType == AddressFieldType.selectAddress) {
        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ButtonTheme(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
                backgroundColor: Theme.of(context).primaryColorLight,
                elevation: 0.0,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RouteList.selectAddress,
                  arguments: ChooseAddressArguments(
                    address: address,
                    callback: updateAddress,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    CupertinoIcons.person_crop_square,
                    size: 16,
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    S.of(context).selectAddress.toUpperCase(),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (currentFieldType == AddressFieldType.deliveryArea) {
        final zoneData = _shippingZones[_selectedDeliveryArea];
        final selectedZoneName = (zoneData?['name'] ?? zoneData?['zone_name'] ?? zoneData?['name_en'])?.toString() ??
            currentFieldType.getTitle(context);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktopLayout)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  currentFieldType.getTitle(context) ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 20 / 14,
                  ),
                ),
              ),
            InkWell(
              onTap: () => _showDeliveryAreaBottomSheet(context),
              child: Container(
                height: 51,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey[400]!,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).colorScheme.surface,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        selectedZoneName ?? '',
                        style: TextStyle(
                          color: _selectedDeliveryArea == null
                              ? Colors.grey
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      final currentFieldController = _textControllers[currentFieldType];
      final currentFieldFocusNode = _focusNodes[currentFieldType];

      var hasNext = false;
      var nextFieldIndex = index + 1;
      late AddressFieldType? nextFieldType;
      late FocusNode? nextFieldFocus;

      while (nextFieldIndex < _fieldPosition.length) {
        nextFieldType = _fieldPosition[nextFieldIndex];
        nextFieldFocus = _focusNodes[nextFieldType];
        if (nextFieldType == AddressFieldType.country ||
            (nextFieldType == AddressFieldType.state &&
                (states?.isNotEmpty ?? false)) ||
            (nextFieldType == AddressFieldType.city &&
                (cities?.isNotEmpty ?? false))) {
          hasNext = false;
          break;
        }
        if (nextFieldFocus != null) {
          hasNext = true;
          break;
        }
        nextFieldIndex++;
      }

      if (currentFieldType == AddressFieldType.phoneNumber &&
          kPhoneNumberConfig.enablePhoneNumberValidation) {
        return InternationalPhoneNumberInput(
          /// Auto focus first field if it's empty.
          autoFocus:
              index == 0 && (currentFieldController?.text.isEmpty ?? false),
          textFieldController: currentFieldController,
          focusNode: currentFieldFocusNode,
          isReadOnly: isFieldReadOnly(index),
          autofillHints: currentFieldType.autofillHint != null
              ? ['${currentFieldType.autofillHint}']
              : null,
          inputDecoration: InputDecoration(
            labelText: currentFieldType.getTitle(context),
          ),
          keyboardType: getKeyboardType(currentFieldType),
          keyboardAction: hasNext ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (hasNext) {
              nextFieldFocus?.requestFocus();
            }
          },
          onSaved: (value) {
            onTextFieldSaved(
              value.phoneNumber,
              currentFieldType,
            );
          },
          onInputChanged: (PhoneNumber number) {},
          onInputValidated: (value) => {},
          spaceBetweenSelectorAndTextField: 0,
          selectorConfig: SelectorConfig(
            enable: kPhoneNumberConfig.useInternationalFormat,
            showFlags: kPhoneNumberConfig.showCountryFlag,
            selectorType: kPhoneNumberConfig.selectorType,
            setSelectorButtonAsPrefixIcon:
                kPhoneNumberConfig.selectorFlagAsPrefixIcon,
            leadingPadding: 0,
            trailingSpace: false,
          ),
          selectorTextStyle: Theme.of(context).textTheme.titleMedium,
          ignoreBlank: !(_configs[index]?.required ?? true),
          initialValue: initialPhoneNumber,
          formatInput: kPhoneNumberConfig.formatInput,
          countries: kPhoneNumberConfig.customCountryList,
          locale: langCode,
          searchBoxDecoration: InputDecoration(
              labelText: S.of(context).searchByCountryNameOrDialCode),
          errorMessage: S.of(context).invalidPhoneNumber,
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktopLayout)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                currentFieldType.getTitle(context) ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
            ),
          TextFormField(
            /// Auto focus first field if it's empty.
            autofocus:
                index == 0 && (currentFieldController?.text.isEmpty ?? false),
            autocorrect: false,
            controller: currentFieldController,
            focusNode: currentFieldFocusNode,
            readOnly: isFieldReadOnly(index),
            autofillHints: currentFieldType.autofillHint != null
                ? ['${currentFieldType.autofillHint}']
                : null,
            decoration: InputDecoration(
              labelText:
                  isDesktopLayout ? null : currentFieldType.getTitle(context),
              border: isDesktopLayout ? const OutlineInputBorder() : null,
              fillColor: isDesktopLayout
                  ? Theme.of(context).colorScheme.surface
                  : null,
              filled: isDesktopLayout,
            ),

            keyboardType: getKeyboardType(currentFieldType),
            textCapitalization: TextCapitalization.words,
            textInputAction:
                hasNext ? TextInputAction.next : TextInputAction.done,
            validator: (val) {
              final config = _configs[index];
              if (config == null) {
                return null;
              }
              return validateField(val, config, currentFieldType);
            },
            onFieldSubmitted: (_) {
              if (hasNext) {
                nextFieldFocus?.requestFocus();
              }
            },
            onSaved: (value) => onTextFieldSaved(
              value,
              currentFieldType,
            ),
          ),
        ],
      );
    });
  }

  void _showDeliveryAreaBottomSheet(BuildContext context) {
    _searchController.clear();
    var filteredZones = _shippingZones.values.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                   Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AddressFieldType.deliveryArea.getTitle(context) ?? 'Delivery Area',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setBottomSheetState(() {
                          filteredZones = _shippingZones.values
                              .where((zone) {
                                final name = (zone['name'] ?? zone['zone_name'] ?? zone['name_en'])?.toString()?.toLowerCase() ?? '';
                                return name.contains(value.toLowerCase());
                              })
                              .toList();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: filteredZones.isEmpty
                        ? const Center(child: Text('No areas found'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredZones.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final zone = filteredZones[index];
                              final zoneId = (zone['id'] ?? zone['zone_id'])?.toString();
                              final zoneName = (zone['name'] ?? zone['zone_name'] ?? zone['name_en'])?.toString() ?? '';
                              final isSelected = _selectedDeliveryArea == zoneId;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  zoneName,
                                  style: TextStyle(
                                    color: isSelected ? Theme.of(context).primaryColor : null,
                                    fontWeight: isSelected ? FontWeight.bold : null,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                                    : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedDeliveryArea = zoneId;
                                    });
                                    if (address != null) {
                                      address!.deliveryArea = zoneId;
                                      _loadShippingWithDeliveryArea(zone);
                                    }
                                    Navigator.pop(context);
                                  },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class DropdownStyleWidget extends StatelessWidget {
  const DropdownStyleWidget({
    super.key,
    required this.countryName,
    this.onTap,
  });

  final String countryName;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (Layout.isDisplayDesktop(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              S.of(context).country,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 20 / 14,
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Container(
              height: 51,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey[400]!,
                ),
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.surface,
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(countryName,
                        style: const TextStyle(fontSize: 17.0)),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                  )
                ],
              ),
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child:
                      Text(countryName, style: const TextStyle(fontSize: 17.0)),
                ),
                const Icon(Icons.arrow_drop_down)
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: kGrey900,
          )
        ],
      ),
    );
  }
}

class ShippingAddressLayout extends StatelessWidget {
  const ShippingAddressLayout({super.key, required this.children});

  final List<(Widget, AddressFieldType?, bool)> children;

  @override
  Widget build(BuildContext context) {
    final isDesktopLayout = Layout.isDisplayDesktop(context);
    if (isDesktopLayout) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: List.generate(
                children.length,
                (index) {
                  final item = children[index];
                  if ([
                        AddressFieldType.firstName,
                        AddressFieldType.phoneNumber,
                        AddressFieldType.country,
                        AddressFieldType.state,
                        AddressFieldType.street,
                      ].contains(item.$2) &&
                      item.$3) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: item.$1,
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: List.generate(
                children.length,
                (index) {
                  final item = children[index];
                  if ([
                        AddressFieldType.lastName,
                        AddressFieldType.email,
                        AddressFieldType.city,
                        AddressFieldType.zipCode,
                        AddressFieldType.apartment,
                        AddressFieldType.block,
                      ].contains(item.$2) &&
                      item.$3) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: item.$1,
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((e) => e.$1).toList(),
    );
  }
}
