import 'package:flutter/material.dart';

void main() => runApp(const CalculadoraApp());

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const Calculadora(),
    );
  }
}


class Calculadora extends StatefulWidget {
  const Calculadora({super.key});

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  String _visor = '0'; 
  String _historico = ''; 
  double? _primeiroOperando; 
  String? _operador; 
  bool _novoNumero = false; 

  
  void _digito(String d) {
    setState(() {
      if (_novoNumero || _visor == '0' || _visor == 'Erro') {
        _visor = d;
        _novoNumero = false;
      } else {
        _visor += d;
      }
    });
  }

  void _ponto() {
    setState(() {
      if (_novoNumero || _visor == 'Erro') {
        _visor = '0.';
        _novoNumero = false;
      } else if (!_visor.contains('.')) {
        _visor += '.';
      }
    });
  }

  void _operacao(String op) {
    setState(() {
      if (_visor == 'Erro') return;
      if (_operador != null && !_novoNumero) {
        _calcular();
        if (_visor == 'Erro') return;
      }
      _primeiroOperando = double.parse(_visor);
      _operador = op;
      _historico = '${_formatar(_primeiroOperando!)} $op';
      _novoNumero = true;
    });
  }

  void _igual() {
    if (_operador == null || _primeiroOperando == null) return;
    setState(() {
      final expr = '${_formatar(_primeiroOperando!)} $_operador $_visor =';
      _calcular();
      _historico = expr;
      _operador = null;
      _primeiroOperando = null;
      _novoNumero = true;
    });
  }

  void _calcular() {
    final a = _primeiroOperando!;
    final b = double.parse(_visor);
    double r;
    switch (_operador) {
      case '+':
        r = a + b;
        break;
      case '−':
        r = a - b;
        break;
      case '×':
        r = a * b;
        break;
      case '÷':
        if (b == 0) {
          _visor = 'Erro'; 
          _historico = 'Divisão por zero';
          _operador = null;
          _primeiroOperando = null;
          _novoNumero = true;
          return;
        }
        r = a / b;
        break;
      default:
        return;
    }
    _visor = _formatar(r);
  }

  void _limpar() {
    setState(() {
      _visor = '0';
      _historico = '';
      _primeiroOperando = null;
      _operador = null;
      _novoNumero = false;
    });
  }

  void _apagar() {
    setState(() {
      if (_novoNumero || _visor == 'Erro') return;
      _visor = _visor.length > 1 ? _visor.substring(0, _visor.length - 1) : '0';
    });
  }

  void _inverterSinal() {
    setState(() {
      if (_visor == '0' || _visor == 'Erro') return;
      _visor = _visor.startsWith('-') ? _visor.substring(1) : '-$_visor';
    });
  }

  
  String _formatar(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    var s = v.toStringAsFixed(8);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    return s.endsWith('.') ? s.substring(0, s.length - 1) : s;
  }


  Widget _botao(
    String texto,
    VoidCallback acao, {
    Color? fundo,
    Color? cor,
    int flex = 1,
  }) {
    final esquema = Theme.of(context).colorScheme;
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 72,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: fundo ?? esquema.surfaceContainerHighest,
              foregroundColor: cor ?? esquema.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: acao,
            child: Text(texto, style: const TextStyle(fontSize: 26)),
          ),
        ),
      ),
    );
  }

  Widget _linha(List<Widget> botoes) => Row(children: botoes);

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final opFundo = esquema.primaryContainer;
    final opCor = esquema.onPrimaryContainer;
    final acFundo = esquema.secondaryContainer;
    final acCor = esquema.onSecondaryContainer;

    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _historico,
                          style: TextStyle(
                            fontSize: 20,
                            color: esquema.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _visor,
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Teclado
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    children: [
                      _linha([
                        _botao('C', _limpar, fundo: acFundo, cor: acCor),
                        _botao('⌫', _apagar, fundo: acFundo, cor: acCor),
                        _botao('±', _inverterSinal, fundo: acFundo, cor: acCor),
                        _botao('÷', () => _operacao('÷'),
                            fundo: opFundo, cor: opCor),
                      ]),
                      _linha([
                        _botao('7', () => _digito('7')),
                        _botao('8', () => _digito('8')),
                        _botao('9', () => _digito('9')),
                        _botao('×', () => _operacao('×'),
                            fundo: opFundo, cor: opCor),
                      ]),
                      _linha([
                        _botao('4', () => _digito('4')),
                        _botao('5', () => _digito('5')),
                        _botao('6', () => _digito('6')),
                        _botao('−', () => _operacao('−'),
                            fundo: opFundo, cor: opCor),
                      ]),
                      _linha([
                        _botao('1', () => _digito('1')),
                        _botao('2', () => _digito('2')),
                        _botao('3', () => _digito('3')),
                        _botao('+', () => _operacao('+'),
                            fundo: opFundo, cor: opCor),
                      ]),
                      _linha([
                        _botao('0', () => _digito('0'), flex: 2),
                        _botao('.', _ponto),
                        _botao('=', _igual,
                            fundo: esquema.primary, cor: esquema.onPrimary),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}