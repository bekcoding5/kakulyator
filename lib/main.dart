import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oddiy Kalkulyator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _operand = '';
  double? _first;
  double? _second;
  String? _operator;
  bool _shouldResetDisplay = false;

  void _numClick(String text) {
    setState(() {
      if (_shouldResetDisplay || _display == '0') {
        _display = text == '.' ? '0.' : text;
        _shouldResetDisplay = false;
      } else {
        // prevent multiple dots
        if (text == '.' && _display.contains('.')) return;
        _display += text;
      }
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _operand = '';
      _first = null;
      _second = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  void _setOperator(String op) {
    setState(() {
      if (_operator != null) {
        // chain calculation: compute current result first
        _calculate();
      }
      _first = double.tryParse(_display);
      _operator = op;
      _shouldResetDisplay = true;
    });
  }

  void _calculate() {
    setState(() {
      if (_operator == null) return;
      _second = double.tryParse(_display);
      if (_first == null || _second == null) return;

      double result = 0;
      switch (_operator) {
        case '+':
          result = _first! + _second!;
          break;
        case '-':
          result = _first! - _second!;
          break;
        case '×':
          result = _first! * _second!;
          break;
        case '÷':
          if (_second == 0) {
            _display = 'Xato';
            _first = null;
            _operator = null;
            _shouldResetDisplay = true;
            return;
          } else {
            result = _first! / _second!;
          }
          break;
      }

      // remove trailing .0
      String resStr = result.toString();
      if (resStr.endsWith('.0')) {
        resStr = result.toInt().toString();
      }
      _display = resStr;
      _first = result;
      _operator = null;
      _shouldResetDisplay = true;
    });
  }

  Widget _buildButton(
    String label, {
    Color? textColor,
    double fontSize = 24,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.grey[200],
            foregroundColor: textColor ?? Colors.black87,
            elevation: 2,
          ),
          onPressed: onTap,
          child: Text(
            label,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lock orientation (mostly useful on mobile, harmless on desktop)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Oddiy Kalkulyator'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Text(
                _display,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const Divider(height: 1),
          Column(
            children: [
              Row(
                children: [
                  _buildButton('C', textColor: Colors.red, onTap: _clear),
                  _buildButton(
                    '÷',
                    textColor: Colors.blue,
                    onTap: () => _setOperator('÷'),
                  ),
                  _buildButton(
                    '×',
                    textColor: Colors.blue,
                    onTap: () => _setOperator('×'),
                  ),
                  _buildButton(
                    '-',
                    textColor: Colors.blue,
                    onTap: () => _setOperator('-'),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildButton('7', onTap: () => _numClick('7')),
                  _buildButton('8', onTap: () => _numClick('8')),
                  _buildButton('9', onTap: () => _numClick('9')),
                  _buildButton(
                    '+',
                    textColor: Colors.blue,
                    fontSize: 28,
                    onTap: () => _setOperator('+'),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildButton('4', onTap: () => _numClick('4')),
                  _buildButton('5', onTap: () => _numClick('5')),
                  _buildButton('6', onTap: () => _numClick('6')),
                  _buildButton('=', textColor: Colors.green, onTap: _calculate),
                ],
              ),
              Row(
                children: [
                  _buildButton('1', onTap: () => _numClick('1')),
                  _buildButton('2', onTap: () => _numClick('2')),
                  _buildButton('3', onTap: () => _numClick('3')),
                  _buildButton('.', onTap: () => _numClick('.')),
                ],
              ),
              Row(
                children: [
                  _buildButton('0', fontSize: 26, onTap: () => _numClick('0')),
                  // You can expand 0 to take two slots or keep as is:
                  _buildButton(
                    '%',
                    onTap: () {
                      setState(() {
                        double? val = double.tryParse(_display);
                        if (val != null) {
                          double res = val / 100.0;
                          _display =
                              res.toString().endsWith('.0')
                                  ? res.toInt().toString()
                                  : res.toString();
                          _shouldResetDisplay = true;
                        }
                      });
                    },
                  ),
                  _buildButton(
                    '+/-',
                    onTap: () {
                      setState(() {
                        if (_display == '0' || _display == 'Xato') return;
                        if (_display.startsWith('-')) {
                          _display = _display.substring(1);
                        } else {
                          _display = '-$_display';
                        }
                      });
                    },
                  ),
                  // spacer to keep grid consistent (or use another function)
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
