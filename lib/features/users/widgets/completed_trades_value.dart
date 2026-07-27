import 'package:flutter/material.dart';
import 'package:swapstash/core/services/trade_service.dart';

class CompletedTradesValue extends StatefulWidget {
  final String userId;
  final TextStyle? style;

  const CompletedTradesValue({super.key, required this.userId, this.style});

  @override
  State<CompletedTradesValue> createState() => _CompletedTradesValueState();
}

class _CompletedTradesValueState extends State<CompletedTradesValue> {
  final TradeService _tradeService = TradeService();

  late Stream<int> _countStream;

  @override
  void initState() {
    super.initState();
    _countStream = _createStream();
  }

  @override
  void didUpdateWidget(covariant CompletedTradesValue oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId) {
      _countStream = _createStream();
    }
  }

  Stream<int> _createStream() {
    return _tradeService.watchCompletedTradeCount(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _countStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('—', style: widget.style);
        }

        if (!snapshot.hasData) {
          return Text('…', style: widget.style);
        }

        return Text(snapshot.data.toString(), style: widget.style);
      },
    );
  }
}
