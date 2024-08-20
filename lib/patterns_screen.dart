import 'dart:math';

import 'package:bbl_security/AppsScreen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatternsScreen extends StatefulWidget {
  final String useremail;

  PatternsScreen({super.key, required this.useremail});

  @override
  _PatternsScreenState createState() => _PatternsScreenState();
}

class _PatternsScreenState extends State<PatternsScreen>
    with TickerProviderStateMixin {
  Offset? offset;
  List<int> codes = [];
  final GlobalKey _paintKey = GlobalKey();
  late AnimationController _controller;
  late Animation<double> _animation;
  String _statusText = "Draw Pattern to setup Lock";
  FToast? _currentToast;
  List<int> _initialPattern = [];
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _currentToast = FToast();
    _currentToast!.init(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var _sizePainter = Size.square(_width);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            Text(
              _statusText,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(223, 4, 4, 4),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: GestureDetector(
                child: CustomPaint(
                  key: _paintKey,
                  painter: _LockScreenPainter(
                    codes: codes,
                    offset: offset,
                    onSelect: _onSelect,
                    animation: _animation,
                  ),
                  size: _sizePainter,
                ),
                onPanStart: (details) {
                  _clearCodes();
                  _onPanUpdate(DragUpdateDetails(
                      globalPosition: details.globalPosition));
                },
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails event) {
    RenderBox box = _paintKey.currentContext!.findRenderObject() as RenderBox;
    setState(() => offset = box.globalToLocal(event.globalPosition));
  }

  void _onPanEnd(DragEndDetails event) {
    if (codes.length < 4) {
      _showToast("You must draw at least 4 points to set a pattern.",
          isSuccess: false);
      _clearCodes();
    } else {
      if (_isConfirming) {
        if (_initialPattern.join() == codes.join()) {
          _sendPatternToServer(_initialPattern.join());
        } else {
          _showToast("Patterns do not match! Try again.", isSuccess: false);
          _resetPatternSetup();
        }
      } else {
        setState(() {
          _initialPattern = List.from(codes);
          _isConfirming = true;
          _statusText = "Confirm your Pattern";
          _clearCodes();
        });
      }
    }
    setState(() => offset = null);
  }

  void _onSelect(int code) {
    if (!codes.contains(code)) {
      codes.add(code);
    }
  }

  void _clearCodes() {
    setState(() {
      codes = [];
      offset = null;
    });
  }

  void _resetPatternSetup() {
    setState(() {
      _isConfirming = false;
      _initialPattern = [];
      _statusText = "Draw Pattern to setup Lock";
      _clearCodes();
    });
  }

  Future<void> _sendPatternToServer(String pattern) async {
    final url = 'http://192.168.1.79:3000/setpattern';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'useremail': widget.useremail,
          'pattern': pattern,
        }),
      );
      print(pattern);

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final successMessage =
            responseBody['message'] ?? 'Pattern setup successfully!';

        // Save the pattern and authentication method to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        bool success = await prefs.setString('user_pattern', pattern);
        await prefs.setString('auth_method', 'Pattern');

        if (success) {
          _showToast(successMessage, isSuccess: true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AppsScreen()),
          );
        } else {
          print('Failed to commit the pattern to SharedPreferences');
        }
      } else {
        _showToast('Failed to send pattern to server.', isSuccess: false);
      }
    } catch (e) {
      _showToast('An error occurred.', isSuccess: false);
    }
  }

  void _showToast(String message, {required bool isSuccess}) {
    _currentToast!.removeCustomToast();
    _currentToast!.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: isSuccess ? Colors.green : Colors.redAccent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8.0),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
      toastDuration: const Duration(seconds: 1),
      gravity: ToastGravity.BOTTOM,
    );
  }
}

class _LockScreenPainter extends CustomPainter {
  final int _total = 9;
  final int _col = 3;
  Size? size;

  final List<int> codes;
  final Offset? offset;
  final Function(int code) onSelect;
  final Animation<double> animation;

  _LockScreenPainter({
    required this.codes,
    required this.offset,
    required this.onSelect,
    required this.animation,
  }) : super(repaint: animation);

  double get _sizeCode => size != null ? size!.width / _col : 0;

  Paint get _painter => Paint()
    ..color = Colors.black
    ..strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    this.size = size;

    for (var i = 0; i < _total; i++) {
      var offset = _getOffsetByIndex(i);
      var _color = _getColorByIndex(i);

      var _radiusIn = _sizeCode / 2.0 * 0.2;
      _drawCircle(canvas, offset, _radiusIn, _color, true);

      var _pathGesture = _getCirclePath(offset, _radiusIn);
      if (offset != null && _pathGesture.contains(offset!)) onSelect(i);
    }

    for (var i = 0; i < codes.length; i++) {
      var _start = _getOffsetByIndex(codes[i]);
      if (i + 1 < codes.length) {
        var _end = _getOffsetByIndex(codes[i + 1]);
        _drawLine(canvas, _start, _end);
      } else if (offset != null) {
        var _end = offset!;
        _drawLine(canvas, _start, _end);
      }
    }
  }

  Path _getCirclePath(Offset offset, double radius) {
    var _rect = Rect.fromCircle(radius: radius, center: offset);
    return Path()..addOval(_rect);
  }

  void _drawCircle(Canvas canvas, Offset offset, double radius, Color color,
      [bool isDot = false]) {
    var _path = _getCirclePath(offset, radius);
    var _painter = this._painter
      ..color = color
          .withOpacity(isDot && codes.contains(offset) ? animation.value : 1.0)
      ..style = isDot ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawPath(_path, _painter);
  }

  void _drawLine(Canvas canvas, Offset start, Offset end) {
    var _painter = this._painter
      ..color = Color(0xFF00358C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    var _path = Path();
    _path.moveTo(start.dx, start.dy);
    _path.lineTo(end.dx, end.dy);
    canvas.drawPath(_path, _painter);
  }

  Color _getColorByIndex(int i) {
    return codes.contains(i) ? Color(0xFF00358C) : Colors.black;
  }

  Offset _getOffsetByIndex(int i) {
    var _dxCode = _sizeCode * (i % _col + .5);
    var _dyCode = _sizeCode * ((i / _col).floor() + .5);
    var _offsetCode = Offset(_dxCode, _dyCode);
    return _offsetCode;
  }

  @override
  bool shouldRepaint(_LockScreenPainter oldDelegate) {
    return offset != oldDelegate.offset || codes != oldDelegate.codes;
  }
}
