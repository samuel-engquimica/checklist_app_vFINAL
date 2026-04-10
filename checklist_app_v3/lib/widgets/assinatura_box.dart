import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class AssinaturaBox extends StatefulWidget {
  final String titulo;
  final void Function(Uint8List? pngBytes) onSalvar;

  const AssinaturaBox({
    super.key,
    required this.titulo,
    required this.onSalvar,
  });

  @override
  State<AssinaturaBox> createState() => _AssinaturaBoxState();
}

class _AssinaturaBoxState extends State<AssinaturaBox> {
  late final SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3.2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_controller.isEmpty) {
      widget.onSalvar(null);
      return;
    }
    final bytes = await _controller.toPngBytes();
    widget.onSalvar(bytes);
  }

  void _limpar() {
    _controller.clear();
    widget.onSalvar(null);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.titulo,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          // Área de assinatura
          Container(
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Botões (somente texto)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _limpar,
                  child: const Text('Limpar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _salvar,
                  child: const Text('Salvar assinatura'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            _controller.isEmpty
                ? 'Assine no quadro acima.'
                : 'Assinatura desenhada. Clique em “Salvar assinatura”.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
