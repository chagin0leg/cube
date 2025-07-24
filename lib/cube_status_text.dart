import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CubeStatusText extends StatefulWidget {
  final String? status;
  const CubeStatusText({super.key, this.status});

  String get statusText => status ?? 'connected';

  @override
  State<CubeStatusText> createState() => _CubeStatusTextState();
}

class _CubeStatusTextState extends State<CubeStatusText>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  bool _show = true;
  int _last = 0;

  String _displayed = '';
  String _prevStatus = '';
  Timer? _animTimer;
  bool _isErasing = false;
  bool _isTyping = false;
  String _targetStatus = '';

  @override
  void initState() {
    super.initState();
    _last = DateTime.now().second;
    _displayed = widget.statusText;
    _prevStatus = widget.statusText;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant CubeStatusText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.statusText != _prevStatus) _startAnimation(widget.statusText);
  }

  void _startAnimation(String to) {
    _animTimer?.cancel();
    _isErasing = true;
    _isTyping = false;
    _targetStatus = to;
    _animTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isErasing) {
        if (_displayed.isNotEmpty) {
          setState(() {
            _displayed = _displayed.substring(0, _displayed.length - 1);
          });
        } else {
          _isErasing = false;
          _isTyping = true;
        }
      } else if (_isTyping) {
        if (_displayed.length < _targetStatus.length) {
          setState(() {
            _displayed = _targetStatus.substring(0, _displayed.length + 1);
          });
        } else {
          _isTyping = false;
          _animTimer?.cancel();
          _prevStatus = _targetStatus;
        }
      }
    });
  }

  void _onTick(Duration _) {
    final now = DateTime.now();
    if (now.second != _last) {
      _last = now.second;
      _show = !_show;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _animTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _displayed;
    return Text(
      'The Cube: $status${_show ? '_' : ' '}',
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF454545),
        fontFamily: 'RobotoMono',
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        backgroundColor: Color(0xFFEAEAEA),
      ),
    );
  }
}
