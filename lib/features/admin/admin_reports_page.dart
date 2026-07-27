import 'package:flutter/material.dart';
import 'package:swapstash/core/models/safety_report.dart';
import 'package:swapstash/core/services/report_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  SafetyReportStatus? _filter;

  String _typeLabel(AppLocalizations localizations, SafetyReportType type) {
    switch (type) {
      case SafetyReportType.user:
        return localizations.safetyReportTypeUser;
      case SafetyReportType.message:
        return localizations.safetyReportTypeMessage;
      case SafetyReportType.trade:
        return localizations.safetyReportTypeTrade;
    }
  }

  String _reasonLabel(AppLocalizations localizations, String reason) {
    switch (reason) {
      case 'spam':
        return localizations.safetyReportReasonSpam;
      case 'harassment':
        return localizations.safetyReportReasonHarassment;
      case 'fraud':
        return localizations.safetyReportReasonFraud;
      case 'inappropriate':
        return localizations.safetyReportReasonInappropriate;
      default:
        return localizations.safetyReportReasonOther;
    }
  }

  String _statusLabel(
    AppLocalizations localizations,
    SafetyReportStatus status,
  ) {
    switch (status) {
      case SafetyReportStatus.open:
        return localizations.safetyReportStatusOpen;
      case SafetyReportStatus.reviewing:
        return localizations.safetyReportStatusReviewing;
      case SafetyReportStatus.resolved:
        return localizations.safetyReportStatusResolved;
      case SafetyReportStatus.dismissed:
        return localizations.safetyReportStatusDismissed;
    }
  }

  Future<void> _setStatus(
    BuildContext context,
    SafetyReport report,
    SafetyReportStatus status,
  ) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      await ReportService().updateReportStatus(
        reportId: report.id,
        status: status,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.safetyReportStatusUpdated)),
        );
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations.safetyActionError}: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.safetyAdminReports)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const maxContentWidth = 1200.0;

          final contentWidth = constraints.maxWidth > maxContentWidth
              ? maxContentWidth
              : constraints.maxWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              height: constraints.maxHeight,
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text(localizations.tradeTabAll),
                          selected: _filter == null,
                          onSelected: (_) => setState(() => _filter = null),
                        ),
                        const SizedBox(width: 8),
                        for (final status in SafetyReportStatus.values) ...[
                          ChoiceChip(
                            label: Text(_statusLabel(localizations, status)),
                            selected: _filter == status,
                            onSelected: (_) =>
                                setState(() => _filter = status),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<SafetyReport>>(
              stream: ReportService().watchReports(status: _filter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '${localizations.safetyReportsLoadError}\n'
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final reports = snapshot.data ?? const <SafetyReport>[];

                if (reports.isEmpty) {
                  return Center(child: Text(localizations.safetyNoReports));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  itemCount: reports.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final date = MaterialLocalizations.of(
                      context,
                    ).formatShortDate(report.createdAt.toDate());

                    return Card(
                      child: ExpansionTile(
                        leading: const Icon(Icons.flag_outlined),
                        title: Text(
                          '${_typeLabel(localizations, report.targetType)} · '
                          '${_reasonLabel(localizations, report.reason)}',
                        ),
                        subtitle: Text(
                          '${_statusLabel(localizations, report.status)} · '
                          '$date',
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16,
                        ),
                        children: [
                          _AdminReportValue(
                            label: localizations.safetyReporterId,
                            value: report.reporterId,
                          ),
                          _AdminReportValue(
                            label: localizations.safetyReportedUserId,
                            value: report.reportedUserId,
                          ),
                          _AdminReportValue(
                            label: localizations.safetyTargetId,
                            value: report.targetId,
                          ),
                          if (report.conversationId.isNotEmpty)
                            _AdminReportValue(
                              label: localizations.safetyConversationId,
                              value: report.conversationId,
                            ),
                          if (report.details.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                report.details,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: () => _setStatus(
                                  context,
                                  report,
                                  SafetyReportStatus.reviewing,
                                ),
                                child: Text(
                                  localizations.safetyReportStatusReviewing,
                                ),
                              ),
                              FilledButton(
                                onPressed: () => _setStatus(
                                  context,
                                  report,
                                  SafetyReportStatus.resolved,
                                ),
                                child: Text(
                                  localizations.safetyReportStatusResolved,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _setStatus(
                                  context,
                                  report,
                                  SafetyReportStatus.dismissed,
                                ),
                                child: Text(
                                  localizations.safetyReportStatusDismissed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdminReportValue extends StatelessWidget {
  final String label;
  final String value;

  const _AdminReportValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
