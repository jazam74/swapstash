import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/trade_delivery_details.dart';
import 'package:swapstash/core/services/trade_delivery_service.dart';
import 'package:swapstash/features/trades/trade_delivery_form_page.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class TradeDeliverySection extends StatelessWidget {
  final Trade trade;
  final String currentUserId;

  const TradeDeliverySection({
    super.key,
    required this.trade,
    required this.currentUserId,
  });

  String get _otherUserId {
    return trade.senderId == currentUserId ? trade.receiverId : trade.senderId;
  }

  Future<void> _openForm(
    BuildContext context,
    TradeDeliveryDetails? details,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            TradeDeliveryFormPage(trade: trade, initialDetails: details),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final service = TradeDeliveryService();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<TradeDeliveryDetails?>(
          stream: service.watchDetails(
            tradeId: trade.id,
            userId: currentUserId,
          ),
          builder: (context, mySnapshot) {
            return StreamBuilder<TradeDeliveryDetails?>(
              stream: service.watchDetails(
                tradeId: trade.id,
                userId: _otherUserId,
              ),
              builder: (context, otherSnapshot) {
                if ((mySnapshot.connectionState == ConnectionState.waiting &&
                        !mySnapshot.hasData) ||
                    (otherSnapshot.connectionState == ConnectionState.waiting &&
                        !otherSnapshot.hasData)) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (mySnapshot.hasError || otherSnapshot.hasError) {
                  return _DeliveryMessage(
                    icon: Icons.error_outline,
                    message: localizations.tradeDeliveryLoadError,
                  );
                }

                final myDetails = mySnapshot.data;
                final otherDetails = otherSnapshot.data;
                final canEdit = trade.status == TradeStatus.accepted;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            localizations.tradeDeliverySectionTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localizations.tradeDeliverySectionDescription,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    _DetailsPanel(
                      title: localizations.tradeDeliveryYourDetails,
                      details: myDetails,
                      emptyMessage:
                          localizations.tradeDeliveryYourDetailsMissing,
                      canEdit: canEdit,
                      onEdit: () => _openForm(context, myDetails),
                    ),
                    const SizedBox(height: 12),
                    _DetailsPanel(
                      title: localizations.tradeDeliveryPartnerDetails,
                      details: otherDetails,
                      emptyMessage:
                          localizations.tradeDeliveryPartnerDetailsMissing,
                      canEdit: false,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_outline, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            localizations.tradeDeliveryPrivateShortDescription,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  final String title;
  final TradeDeliveryDetails? details;
  final String emptyMessage;
  final bool canEdit;
  final VoidCallback? onEdit;

  const _DetailsPanel({
    required this.title,
    required this.details,
    required this.emptyMessage,
    required this.canEdit,
    this.onEdit,
  });

  Future<void> _copy(BuildContext context, String value) async {
    final localizations = AppLocalizations.of(context)!;

    await Clipboard.setData(ClipboardData(text: value));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.tradeDeliveryCopied)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (canEdit)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(details == null ? Icons.add : Icons.edit_outlined),
                  label: Text(
                    details == null
                        ? localizations.tradeDeliveryAdd
                        : localizations.tradeDeliveryEdit,
                  ),
                ),
            ],
          ),
          if (details == null)
            _DeliveryMessage(icon: Icons.info_outline, message: emptyMessage)
          else ...[
            const SizedBox(height: 4),
            Chip(
              avatar: Icon(
                details!.method == TradeDeliveryMethod.mail
                    ? Icons.local_shipping_outlined
                    : Icons.handshake_outlined,
                size: 18,
              ),
              label: Text(
                details!.method == TradeDeliveryMethod.mail
                    ? localizations.tradeDeliveryByMail
                    : localizations.tradeDeliveryInPerson,
              ),
            ),
            const SizedBox(height: 10),
            if (details!.method == TradeDeliveryMethod.mail) ...[
              _ValueBlock(
                label: localizations.tradeDeliveryAddress,
                value: details!.formattedAddress,
                copyTooltip: localizations.tradeDeliveryCopyAddress,
                onCopy: details!.formattedAddress.isEmpty
                    ? null
                    : () => _copy(context, details!.formattedAddress),
              ),
            ] else ...[
              _ValueBlock(
                label: localizations.tradeDeliveryMeetingDetails,
                value: details!.meetingDetails,
              ),
            ],
            if (details!.phone.trim().isNotEmpty)
              _ValueBlock(
                label: localizations.tradeDeliveryPhone,
                value: details!.phone,
                copyTooltip: localizations.tradeDeliveryCopyPhone,
                onCopy: () => _copy(context, details!.phone),
              ),
            if (details!.method == TradeDeliveryMethod.mail &&
                details!.carrier.trim().isNotEmpty)
              _ValueBlock(
                label: localizations.tradeDeliveryCarrier,
                value: details!.carrier,
              ),
            if (details!.method == TradeDeliveryMethod.mail)
              _ValueBlock(
                label: localizations.tradeDeliveryTrackingNumber,
                value: details!.trackingNumber.trim().isEmpty
                    ? localizations.tradeDeliveryTrackingMissing
                    : details!.trackingNumber,
                copyTooltip: details!.hasTrackingNumber
                    ? localizations.tradeDeliveryCopyTracking
                    : null,
                onCopy: details!.hasTrackingNumber
                    ? () => _copy(context, details!.trackingNumber)
                    : null,
              ),
            if (details!.notes.trim().isNotEmpty)
              _ValueBlock(
                label: localizations.tradeDeliveryNotes,
                value: details!.notes,
              ),
          ],
        ],
      ),
    );
  }
}

class _ValueBlock extends StatelessWidget {
  final String label;
  final String value;
  final String? copyTooltip;
  final VoidCallback? onCopy;

  const _ValueBlock({
    required this.label,
    required this.value,
    this.copyTooltip,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                SelectableText(value),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              tooltip: copyTooltip,
              onPressed: onCopy,
              icon: const Icon(Icons.copy_outlined),
            ),
        ],
      ),
    );
  }
}

class _DeliveryMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _DeliveryMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ],
    );
  }
}
