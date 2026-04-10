import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CalibradorTemplate { cacamba, caminhao }

class CalibradorScreen extends StatefulWidget {
  final CalibradorTemplate initialTemplate;

  const CalibradorScreen({
    super.key,
    this.initialTemplate = CalibradorTemplate.cacamba,
  });

  @override
  State<CalibradorScreen> createState() => _CalibradorScreenState();
}

class _CalibradorScreenState extends State<CalibradorScreen> {
  late CalibradorTemplate _template;

  static const Map<CalibradorTemplate, String> _templates = {
    CalibradorTemplate.caminhao:
        'assets/templates/checklist_caminhao_template.png',
    CalibradorTemplate.cacamba:
        'assets/templates/checklist_cacamba_template.png',
  };

  int? _imgW;
  int? _imgH;

  Offset? _markerLocal;
  double? _xMm;
  double? _yMm;

  bool _capturaLista = false;
  final List<Map<String, double>> _capturados = [];

  @override
  void initState() {
    super.initState();
    _template = widget.initialTemplate;
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    final path = _templates[_template]!;
    final bd = await rootBundle.load(path);
    final Uint8List bytes = bd.buffer.asUint8List();

    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final img = frame.image;

    setState(() {
      _imgW = img.width;
      _imgH = img.height;
      _markerLocal = null;
      _xMm = null;
      _yMm = null;
      _capturados.clear();
    });
  }

  void _handleTap(Offset localPos, Size containerSize) {
    if (_imgW == null || _imgH == null) return;

    final double cw = containerSize.width;
    final double ch = containerSize.height;

    final double iw = _imgW!.toDouble();
    final double ih = _imgH!.toDouble();

    // BoxFit.contain (sem distorcer)
    final double scale = (cw / iw < ch / ih) ? (cw / iw) : (ch / ih);
    final double drawnW = iw * scale;
    final double drawnH = ih * scale;

    final double offX = (cw - drawnW) / 2.0;
    final double offY = (ch - drawnH) / 2.0;

    final double xIn = localPos.dx - offX;
    final double yIn = localPos.dy - offY;

    // clicou fora da imagem
    if (xIn < 0 || yIn < 0 || xIn > drawnW || yIn > drawnH) return;

    // A4: 210mm x 297mm
    final double xMm = (xIn / drawnW) * 210.0;
    final double yMm = (yIn / drawnH) * 297.0;

    setState(() {
      _markerLocal = localPos;
      _xMm = xMm;
      _yMm = yMm;

      if (_capturaLista) {
        _capturados.add({'xMm': xMm, 'yMm': yMm});
      }
    });
  }

  Future<void> _copiarPonto() async {
    if (_xMm == null || _yMm == null) return;
    final txt =
        'xMm: ${_xMm!.toStringAsFixed(3)}, yMm: ${_yMm!.toStringAsFixed(3)}';
    await Clipboard.setData(ClipboardData(text: txt));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copiado: $txt')),
      );
    }
  }

  Future<void> _copiarListaY() async {
    if (_capturados.isEmpty) return;
    final ys = _capturados.map((p) => p['yMm']!).toList();
    final txt = ys.map((v) => v.toStringAsFixed(3)).join(',\n');
    await Clipboard.setData(ClipboardData(text: txt));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista de Y copiada (um por linha)')),
      );
    }
  }

  Future<void> _copiarListaDart() async {
    if (_capturados.isEmpty) return;
    final lines =
        _capturados.map((p) => '  ${p['yMm']!.toStringAsFixed(3)},').join('\n');
    final txt = 'static const List<double> yItens = [\n$lines\n];';
    await Clipboard.setData(ClipboardData(text: txt));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista Dart copiada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = _templates[_template]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calibrador (mm A4)'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<CalibradorTemplate>(
              value: _template,
              items: const [
                DropdownMenuItem(
                  value: CalibradorTemplate.cacamba,
                  child: Text('Caçamba'),
                ),
                DropdownMenuItem(
                  value: CalibradorTemplate.caminhao,
                  child: Text('Caminhão'),
                ),
              ],
              onChanged: (v) async {
                if (v == null) return;
                setState(() => _template = v);
                await _loadImageSize();
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _imgW == null
                          ? 'Carregando template...'
                          : 'Template: $path | PNG: ${_imgW}x${_imgH}px\n'
                              'Clique no ponto desejado para obter xMm/yMm (A4).',
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton(
                          onPressed: (_xMm != null && _yMm != null)
                              ? _copiarPonto
                              : null,
                          child: const Text('Copiar ponto (xMm,yMm)'),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              setState(() => _capturaLista = !_capturaLista),
                          child: Text(
                              _capturaLista ? 'Captura: ON' : 'Captura: OFF'),
                        ),
                        OutlinedButton(
                          onPressed: _capturados.isNotEmpty
                              ? () => setState(_capturados.clear)
                              : null,
                          child: const Text('Limpar lista'),
                        ),
                        OutlinedButton(
                          onPressed:
                              _capturados.isNotEmpty ? _copiarListaY : null,
                          child: const Text('Copiar só Y (linhas)'),
                        ),
                        OutlinedButton(
                          onPressed:
                              _capturados.isNotEmpty ? _copiarListaDart : null,
                          child: const Text('Copiar lista Dart'),
                        ),
                        Text('Capturados: ${_capturados.length}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Área com proporção A4
                  final double maxW = constraints.maxWidth;
                  final double maxH = constraints.maxHeight;
                  const double a4Ratio = 210.0 / 297.0;

                  double w = maxW;
                  double h = w / a4Ratio;
                  if (h > maxH) {
                    h = maxH;
                    w = h * a4Ratio;
                  }
                  final boxSize = Size(w, h);

                  return Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _handleTap(d.localPosition, boxSize),
                      child: SizedBox(
                        width: w,
                        height: h,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(path, fit: BoxFit.contain),
                            ),
                            if (_markerLocal != null)
                              Positioned(
                                left: _markerLocal!.dx - 10,
                                top: _markerLocal!.dy - 10,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.red, width: 2),
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'X',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            if (_xMm != null && _yMm != null)
                              Positioned(
                                left: 8,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'xMm=${_xMm!.toStringAsFixed(3)} | yMm=${_yMm!.toStringAsFixed(3)}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
