import 'package:flutter/material.dart';
import 'package:swapstash/core/models/safety_report.dart';
import 'package:swapstash/core/services/report_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

Future<bool> showSafetyReportDialog({
  required BuildContext context,
  required String reportedUserId,
  required SafetyReportType targetType,
  required String targetId,
  String conversationId = '',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return _SafetyReportDialog(
        reportedUserId: reportedUserId,
        targetType: targetType,
        targetId: targetId,
        conversationId: conversationId,
      );
    },
  );

  if (result == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.safetyReportSubmitted),
      ),
    );
  }

  return result == true;
}

class _SafetyReportDialog extends StatefulWidget {
  final String reportedUserId;
  final SafetyReportType targetType;
  final String targetId;
  final String conversationId;

  const _SafetyReportDialog({
    required this.reportedUserId,
    required this.targetType,
    required this.targetId,
    required this.conversationId,
  });

  @override
  State<_SafetyReportDialog> createState() => _SafetyReportDialogState();
}

class _SafetyReportDialogState extends State<_SafetyReportDialog> {
  final TextEditingController _detailsController = TextEditingController();

  String _selectedReason = 'spam';
  bool _submitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String _reasonLabel(AppLocalizations localizations, String value) {
    switch (value) {
      case 'spam':
        return localizations.safetyReportReasonSpam;
      case 'harassment':
        return localizations.safetyReportReasonHarassment;
      case 'fraud':
        return localizations.safetyReportReasonFraud;
      case 'inappropriate':
        return localizations.safetyReportReasonInappropriate;
      case 'other':
        return localizations.safetyReportReasonOther;
      default:
        return value;
    }
  }

  Future<void> _submit() async {
    final localizations = AppLocalizations.of(context)!;

    if (_submitting) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await ReportService().submitReport(
        reportedUserId: widget.reportedUserId,
        targetType: widget.targetType,
        targetId: widget.targetId,
        conversationId: widget.conversationId,
        reason: _selectedReason,
        details: _detailsController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _submitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations.safetyReportError}: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_submitting,
      child: AlertDialog(
        title: Text(localizations.safetyReportTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations.safetyReportDescription),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedReason,
                decoration: InputDecoration(
                  labelText: localizations.safetyReportReason,
                  border: const OutlineInputBorder(),
                ),
                items:
                    const [
                          'spam',
                          'harassment',
                          'fraud',
                          'inappropriate',
                          'other',
                        ]
                        .map(
                          (value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(_reasonLabel(localizations, value)),
                          ),
                        )
                        .toList(growable: false),
                onChanged: _submitting
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedReason = value;
                        });
                      },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _detailsController,
                enabled: !_submitting,
                maxLength: ReportService.maximumDetailsLength,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: localizations.safetyReportDetails,
                  hintText: localizations.safetyReportDetailsHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting
                ? null
                : () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.flag_outlined),
            label: Text(
              _submitting
                  ? localizations.safetyReportSubmitting
                  : localizations.safetyReportSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
