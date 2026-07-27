import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/trade_delivery_details.dart';
import 'package:swapstash/core/services/trade_delivery_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class TradeDeliveryFormPage extends StatefulWidget {
  final Trade trade;
  final TradeDeliveryDetails? initialDetails;

  const TradeDeliveryFormPage({
    super.key,
    required this.trade,
    this.initialDetails,
  });

  @override
  State<TradeDeliveryFormPage> createState() => _TradeDeliveryFormPageState();
}

class _TradeDeliveryFormPageState extends State<TradeDeliveryFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TradeDeliveryService _service = TradeDeliveryService();

  late final TextEditingController _fullNameController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _phoneController;
  late final TextEditingController _meetingDetailsController;
  late final TextEditingController _carrierController;
  late final TextEditingController _trackingNumberController;
  late final TextEditingController _notesController;

  late TradeDeliveryMethod _method;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final details = widget.initialDetails;
    _method = details?.method ?? TradeDeliveryMethod.mail;
    _fullNameController = TextEditingController(text: details?.fullName ?? '');
    _addressLine1Controller = TextEditingController(
      text: details?.addressLine1 ?? '',
    );
    _addressLine2Controller = TextEditingController(
      text: details?.addressLine2 ?? '',
    );
    _postalCodeController = TextEditingController(
      text: details?.postalCode ?? '',
    );
    _cityController = TextEditingController(text: details?.city ?? '');
    _countryController = TextEditingController(text: details?.country ?? '');
    _phoneController = TextEditingController(text: details?.phone ?? '');
    _meetingDetailsController = TextEditingController(
      text: details?.meetingDetails ?? '',
    );
    _carrierController = TextEditingController(text: details?.carrier ?? '');
    _trackingNumberController = TextEditingController(
      text: details?.trackingNumber ?? '',
    );
    _notesController = TextEditingController(text: details?.notes ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _meetingDetailsController.dispose();
    _carrierController.dispose();
    _trackingNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, AppLocalizations localizations) {
    if (value == null || value.trim().isEmpty) {
      return localizations.tradeDeliveryRequiredField;
    }

    return null;
  }

  Future<void> _save() async {
    final localizations = AppLocalizations.of(context)!;

    if (_saving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _service.saveMyDetails(
        trade: widget.trade,
        method: _method,
        fullName: _fullNameController.text,
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text,
        postalCode: _postalCodeController.text,
        city: _cityController.text,
        country: _countryController.text,
        phone: _phoneController.text,
        meetingDetails: _meetingDetailsController.text,
        carrier: _carrierController.text,
        trackingNumber: _trackingNumberController.text,
        notes: _notesController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.tradeDeliverySaved)));

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.tradeDeliverySaveError(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.tradeDeliveryFormTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              localizations.tradeDeliveryChooseMethod,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            SegmentedButton<TradeDeliveryMethod>(
              segments: [
                ButtonSegment(
                  value: TradeDeliveryMethod.mail,
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: Text(localizations.tradeDeliveryByMail),
                ),
                ButtonSegment(
                  value: TradeDeliveryMethod.inPerson,
                  icon: const Icon(Icons.handshake_outlined),
                  label: Text(localizations.tradeDeliveryInPerson),
                ),
              ],
              selected: {_method},
              onSelectionChanged: _saving
                  ? null
                  : (selection) {
                      setState(() {
                        _method = selection.first;
                      });
                    },
            ),
            const SizedBox(height: 20),
            if (_method == TradeDeliveryMethod.mail) ...[
              TextFormField(
                controller: _fullNameController,
                enabled: !_saving,
                maxLength: TradeDeliveryService.shortFieldMaximumLength,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: localizations.tradeDeliveryFullName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => _requiredValidator(value, localizations),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressLine1Controller,
                enabled: !_saving,
                maxLength: TradeDeliveryService.shortFieldMaximumLength,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: localizations.tradeDeliveryAddressLine1,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => _requiredValidator(value, localizations),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressLine2Controller,
                enabled: !_saving,
                maxLength: TradeDeliveryService.shortFieldMaximumLength,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: localizations.tradeDeliveryAddressLine2,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _postalCodeController,
                      enabled: !_saving,
                      maxLength: TradeDeliveryService.shortFieldMaximumLength,
                      keyboardType: TextInputType.streetAddress,
                      decoration: InputDecoration(
                        labelText: localizations.tradeDeliveryPostalCode,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          _requiredValidator(value, localizations),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _cityController,
                      enabled: !_saving,
                      maxLength: TradeDeliveryService.shortFieldMaximumLength,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: localizations.tradeDeliveryCity,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          _requiredValidator(value, localizations),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _countryController,
                enabled: !_saving,
                maxLength: TradeDeliveryService.shortFieldMaximumLength,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: localizations.tradeDeliveryCountry,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => _requiredValidator(value, localizations),
              ),
              const SizedBox(height: 12),
            ] else ...[
              TextFormField(
                controller: _meetingDetailsController,
                enabled: !_saving,
                maxLength: TradeDeliveryService.notesMaximumLength,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: localizations.tradeDeliveryMeetingDetails,
                  hintText: localizations.tradeDeliveryMeetingDetailsHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => _requiredValidator(value, localizations),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _phoneController,
              enabled: !_saving,
              maxLength: TradeDeliveryService.shortFieldMaximumLength,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: localizations.tradeDeliveryPhone,
                border: const OutlineInputBorder(),
              ),
            ),
            if (_method == TradeDeliveryMethod.mail) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _carrierController,
                enabled: !_saving,
                maxLength: TradeDeliveryService.shortFieldMaximumLength,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: localizations.tradeDeliveryCarrier,
                  hintText: localizations.tradeDeliveryCarrierHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _trackingNumberController,
                enabled: !_saving,
                maxLength: TradeDeliveryService.shortFieldMaximumLength,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: localizations.tradeDeliveryTrackingNumber,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              enabled: !_saving,
              maxLength: TradeDeliveryService.notesMaximumLength,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: localizations.tradeDeliveryNotes,
                hintText: localizations.tradeDeliveryNotesHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(localizations.tradeDeliveryPrivateTitle),
                subtitle: Text(localizations.tradeDeliveryPrivateDescription),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _saving
                    ? localizations.tradeDeliverySaving
                    : localizations.tradeDeliverySave,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
