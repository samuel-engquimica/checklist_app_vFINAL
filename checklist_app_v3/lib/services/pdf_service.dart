import 'dart:typed_data';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' show imageFromAssetBundle;
import '../models/checklist_models.dart';

class PdfService {
  // ============================================================
  // para os ajustes depois
  // ============================================================
  static const double _dxCacamba = 0.0;
  static const double _dyCacamba = 0.0;
  static const double _dxCaminhao = 0.0;
  static const double _dyCaminhao = 0.0;

  // ============================================================
  // Cache de templates
  // ============================================================
  static final Map<String, pw.ImageProvider> _templateCache = {};

  Future<pw.ImageProvider> _loadTemplate(String assetPath) async {
    final cached = _templateCache[assetPath];
    if (cached != null) return cached;

    // Mais robusto no Web do que rootBundle.load + MemoryImage
    final provider = await imageFromAssetBundle(assetPath);
    _templateCache[assetPath] = provider;
    return provider;
  }

  // ============================================================
  // Helpers
  // ============================================================
  double _safe(double v) => v.isFinite ? v : 0.0;

  double _mm(double v) {
    final vv = _safe(v);
    final out = vv * pdf.PdfPageFormat.mm;
    return out.isFinite ? out : 0.0;
  }

  pw.Widget _text(String v, {double size = 9, bool bold = false}) {
    return pw.Text(
      v,
      style: pw.TextStyle(
        fontSize: size,
        font: bold ? pw.Font.helveticaBold() : pw.Font.helvetica(),
      ),
    );
  }

  pw.Widget _xMark({double size = 10}) {
    return pw.Center(
      child: pw.Text(
        'X',
        style: pw.TextStyle(
          font: pw.Font.helveticaBold(),
          fontSize: size,
        ),
      ),
    );
  }

  // x menor
  pw.Widget _xMarkSmall({double size = 8}) {
    return pw.Center(
      child: pw.Text(
        'X',
        style: pw.TextStyle(
          font: pw.Font.helveticaBold(),
          fontSize: size,
        ),
      ),
    );
  }

  pw.Widget _assinatura(Uint8List pngBytes,
      {double wMm = 60, double hMm = 16}) {
    // evita quebrar caso venha assinatura vazia
    if (pngBytes.isEmpty) {
      return pw.SizedBox(width: _mm(wMm), height: _mm(hMm));
    }

    final img = pw.MemoryImage(pngBytes);
    return pw.SizedBox(
      width: _mm(wMm),
      height: _mm(hMm),
      child: pw.Image(img, fit: pw.BoxFit.contain),
    );
  }

  pw.Widget _posText({
    required String text,
    required double xMm,
    required double yMm,
    required double dx,
    required double dy,
    double size = 9,
    double widthMm = 0,
  }) {
    final t = text.trim();
    if (t.isEmpty) return pw.SizedBox();
    final w = (widthMm > 0) ? _mm(widthMm) : null;

    return pw.Positioned(
      left: _mm(xMm + dx),
      top: _mm(yMm + dy),
      child: w == null
          ? _text(t, size: size)
          : pw.SizedBox(width: w, child: _text(t, size: size)),
    );
  }

  pw.Widget _markAt({
    required double xMm,
    required double yMm,
    required double dx,
    required double dy,
    double boxWMm = 8,
    double boxHMm = 6,
  }) {
    return pw.Positioned(
      left: _mm(xMm + dx),
      top: _mm(yMm + dy),
      child: pw.SizedBox(
        width: _mm(boxWMm),
        height: _mm(boxHMm),
        child: _xMark(size: 10),
      ),
    );
  }

  pw.Widget _markAtSmall({
    required double xMm,
    required double yMm,
    required double dx,
    required double dy,
    double boxWMm = 5,
    double boxHMm = 5,
  }) {
    return pw.Positioned(
      left: _mm(xMm + dx),
      top: _mm(yMm + dy),
      child: pw.SizedBox(
        width: _mm(boxWMm),
        height: _mm(boxHMm),
        child: _xMarkSmall(size: 8),
      ),
    );
  }

  // ============================================================
  // CAÇAMBA (coordenadas)
  // ============================================================
  static const double _cXSim = 120;
  static const double _cXNao = 132.191;
  static const double _cXNa = 157.981;

  static const List<double> _cYItens = [
    152.2,
    162.036,
    172.111,
    181.932,
    192.499,
    200.854,
  ];

  static const double _cSigX = 62.098;
  static const double _cSigMotorTop = 222.867;
  static const double _cSigVigilTop = 232.192;

  Future<Uint8List> gerarPdfCacamba(ChecklistCacambaData d) async {
    final bg =
        await _loadTemplate('assets/templates/checklist_cacamba_template.png');

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: pdf.PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) {
          final w = pdf.PdfPageFormat.a4.width;
          final h = pdf.PdfPageFormat.a4.height;

          return pw.SizedBox(
            width: w,
            height: h,
            child: pw.Stack(
              children: [
                // Fundo A4
                pw.Positioned(
                  left: 0,
                  top: 0,
                  child: pw.SizedBox(
                    width: w,
                    height: h,
                    child: pw.Image(bg, fit: pw.BoxFit.fill),
                  ),
                ),

                // Campos
                _posText(
                    text: d.motorista,
                    xMm: 36.917,
                    yMm: 37.300,
                    dx: _dxCacamba,
                    dy: _dyCacamba),
                _posText(
                    text: d.transportadora,
                    xMm: 44.187,
                    yMm: 44.549,
                    dx: _dxCacamba,
                    dy: _dyCacamba),
                _posText(
                    text: d.vigilante,
                    xMm: 36.078,
                    yMm: 51.379,
                    dx: _dxCacamba,
                    dy: _dyCacamba),
                _posText(
                    text: d.placaCarreta,
                    xMm: 138.109,
                    yMm: 40.564,
                    dx: _dxCacamba,
                    dy: _dyCacamba),
                _posText(
                    text: d.placaCavalo,
                    xMm: 135.932,
                    yMm: 47.557,
                    dx: _dxCacamba,
                    dy: _dyCacamba),
                _posText(
                    text: d.numeroCacamba,
                    xMm: 169.710,
                    yMm: 48,
                    dx: _dxCacamba,
                    dy: _dyCacamba),
                _posText(
                  text: d.dataChegada,
                  xMm: 28.144,
                  yMm: 73.7,
                  dx: _dxCacamba,
                  dy: _dyCacamba,
                ),
                _posText(
                  text: d.horaChegada,
                  xMm: 31.181,
                  yMm: 80.7,
                  dx: _dxCacamba,
                  dy: _dyCacamba,
                ),
                _posText(
                  text: d.ticketEntrada,
                  xMm: 130.998,
                  yMm: 68.5,
                  dx: _dxCacamba,
                  dy: _dyCacamba,
                ),
                _posText(
                  text: d.dataEntrada,
                  xMm: 124.926,
                  yMm: 75.6,
                  dx: _dxCacamba,
                  dy: _dyCacamba,
                ),
                _posText(
                  text: d.horaEntrada,
                  xMm: 125.685,
                  yMm: 83,
                  dx: _dxCacamba,
                  dy: _dyCacamba,
                ),

                // Itens
                for (int i = 0;
                    i < d.itens.length && i < _cYItens.length;
                    i++) ...[
                  if (d.itens[i].resposta == RespostaChecklist.sim)
                    _markAt(
                        xMm: _cXSim,
                        yMm: _cYItens[i],
                        dx: _dxCacamba,
                        dy: _dyCacamba),
                  if (d.itens[i].resposta == RespostaChecklist.nao)
                    _markAt(
                        xMm: _cXNao,
                        yMm: _cYItens[i],
                        dx: _dxCacamba,
                        dy: _dyCacamba),
                  if (d.itens[i].resposta == RespostaChecklist.na)
                    _markAt(
                        xMm: _cXNa,
                        yMm: _cYItens[i],
                        dx: _dxCacamba,
                        dy: _dyCacamba),
                ],

                // Assinaturas
                if (d.assinaturaMotoristaPng != null &&
                    d.assinaturaMotoristaPng!.isNotEmpty)
                  pw.Positioned(
                    left: _mm(_cSigX + _dxCacamba),
                    top: _mm(_cSigMotorTop + _dyCacamba),
                    child:
                        _assinatura(d.assinaturaMotoristaPng!, wMm: 35, hMm: 6),
                  ),
                if (d.assinaturaVigilantePng != null && //validação do vigia
                    d.assinaturaVigilantePng!.isNotEmpty)
                  pw.Positioned(
                    left: _mm(_cSigX + _dxCacamba),
                    top: _mm(_cSigVigilTop + _dyCacamba),
                    child:
                        _assinatura(d.assinaturaVigilantePng!, wMm: 35, hMm: 6),
                  ),

                // Observações
                _posText(
                  text: d.observacoes,
                  xMm: 40,
                  yMm: 251,
                  dx: _dxCacamba,
                  dy: _dyCacamba,
                  widthMm: 175,
                  size: 9,
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  // ============================================================
  // CAMINHÃO (coordenadas)
  // ============================================================
  static const double _mXSim = 106.317;
  static const double _mXNao = 118.675;
  static const double _mXNa = 130.948;
  static const double _mXObs = 143.5;

  static const List<double> _mYItens = [
    99.206,
    108.223,
    118.200,
    126.200,
    135.200,
    144.200,
    151.2,
    160.2,
    170.2,
    179.2,
    186.2,
    192.2,
    198.2,
    204.2,
    212.2,
  ];

  // dos produtos
  static const double _mProdSimX = 45.9;
  static const double _mProdSimY = 58.9;
  static const double _mProdNaoX = 58.7;
  static const double _mProdNaoY = 58.9;

  static const double _mCarregX = 38.660;
  static const double _mCarregY = 82.380;
  static const double _mDescX = 68.0;
  static const double _mDescY = 82.380;

  static const double _mSigX = 51;
  static const double _mSigMotorTop = 230.0;
  static const double _mSigVigilTop = 242.0;

  Future<Uint8List> gerarPdfCaminhao(ChecklistCaminhaoData d) async {
    final bg =
        await _loadTemplate('assets/templates/checklist_caminhao_template.png');

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: pdf.PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) {
          final w = pdf.PdfPageFormat.a4.width;
          final h = pdf.PdfPageFormat.a4.height;

          return pw.SizedBox(
            width: w,
            height: h,
            child: pw.Stack(
              children: [
                // Fundo A4
                pw.Positioned(
                  left: 0,
                  top: 0,
                  child: pw.SizedBox(
                    width: w,
                    height: h,
                    child: pw.Image(bg, fit: pw.BoxFit.fill),
                  ),
                ),

                _posText(
                    text: d.motorista,
                    xMm: 31.647,
                    yMm: 39.848,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao),
                _posText(
                    text: d.transportadora,
                    xMm: 81.439,
                    yMm: 38.9,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao),
                _posText(
                    text: d.numeroDocumento,
                    xMm: 38.660,
                    yMm: 46.114,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao),
                _posText(
                    text: d.senha,
                    xMm: 73.755,
                    yMm: 46.114,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao),
                _posText(
                    text: d.cnhNumero,
                    xMm: 46.270,
                    yMm: 52.797,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao),
                _posText(
                    text: d.cnhValidade,
                    xMm: 87.213,
                    yMm: 52.797,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao),
                _posText(
                    text: d.mopp,
                    xMm: 47.105,
                    yMm: 65.747,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao),
                _posText(
                    text: d.placaCarreta,
                    xMm: 121.636,
                    yMm: 37,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao),
                _posText(
                    text: d.placaCavalo,
                    xMm: 121.636,
                    yMm: 42.190,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao),
                _posText(
                    text: d.placaVeiculoPerigoso,
                    xMm: 121.636,
                    yMm: 54.139,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao),
                _posText(
                    text: d.placaUtilitario,
                    xMm: 121.636,
                    yMm: 67.671,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao),
                _posText(
                  text: d.horaChegada,
                  xMm: 39.259,
                  yMm: 76.5,
                  dx: _dxCaminhao,
                  dy: _dyCaminhao,
                ),
                _posText(
                  text: d.dataChegada,
                  xMm: 86.562,
                  yMm: 76.5,
                  dx: _dxCaminhao,
                  dy: _dyCaminhao,
                ),
                _posText(
                  text: d.horaEntrada,
                  xMm: 121.839,
                  yMm: 76.5,
                  dx: _dxCaminhao,
                  dy: _dyCaminhao,
                ),
                _posText(
                  text: d.horaEntrada,
                  xMm: 153.356,
                  yMm: 76.5,
                  dx: _dxCaminhao,
                  dy: _dyCaminhao,
                ),
                _posText(
                  text: d.vigilanteVigia,
                  xMm: 123,
                  yMm: 83,
                  dx: _dxCaminhao,
                  dy: _dyCaminhao,
                ),

                // =========================================================
                // Marcações dos parênteses
                // Produto perigoso: SIM / NÃO
                // =========================================================
                if (d.produtoPerigoso == true)
                  _markAtSmall(
                    xMm: _mProdSimX,
                    yMm: _mProdSimY,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao,
                  )
                else if (d.produtoPerigoso == false)
                  _markAtSmall(
                    xMm: _mProdNaoX,
                    yMm: _mProdNaoY,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao,
                  ),

                if (d.carregamento == true)
                  _markAtSmall(
                    xMm: _mCarregX,
                    yMm: _mCarregY,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao,
                  )
                else if (d.carregamento == false)
                  _markAtSmall(
                    xMm: _mDescX,
                    yMm: _mDescY,
                    dx: _dxCaminhao,
                    dy: _dyCaminhao,
                  ),

                for (int i = 0;
                    i < d.itens.length && i < _mYItens.length;
                    i++) ...[
                  if (d.itens[i].resposta == RespostaChecklist.sim)
                    _markAt(
                        xMm: _mXSim,
                        yMm: _mYItens[i],
                        dx: _dxCaminhao,
                        dy: _dyCaminhao),
                  if (d.itens[i].resposta == RespostaChecklist.nao)
                    _markAt(
                        xMm: _mXNao,
                        yMm: _mYItens[i],
                        dx: _dxCaminhao,
                        dy: _dyCaminhao),
                  if (d.itens[i].resposta == RespostaChecklist.na)
                    _markAt(
                        xMm: _mXNa,
                        yMm: _mYItens[i],
                        dx: _dxCaminhao,
                        dy: _dyCaminhao),
                  if (d.itens[i].obs.trim().isNotEmpty)
                    pw.Positioned(
                      left: _mm(_mXObs + _dxCaminhao),
                      top: _mm((_mYItens[i] - 2) + _dyCaminhao),
                      child: pw.SizedBox(
                        width: _mm(28),
                        child: _text(d.itens[i].obs.trim(), size: 8),
                      ),
                    ),
                ],

                if (d.assinaturaMotoristaPng != null &&
                    d.assinaturaMotoristaPng!.isNotEmpty)
                  pw.Positioned(
                    left: _mm(_mSigX + _dxCaminhao),
                    top: _mm(_mSigMotorTop + _dyCaminhao),
                    child:
                        _assinatura(d.assinaturaMotoristaPng!, wMm: 35, hMm: 6),
                  ),

                if (d.assinaturaVigilantePng != null &&
                    d.assinaturaVigilantePng!.isNotEmpty)
                  pw.Positioned(
                    left: _mm(_mSigX + _dxCaminhao),
                    top: _mm(_mSigVigilTop + _dyCaminhao),
                    child:
                        _assinatura(d.assinaturaVigilantePng!, wMm: 35, hMm: 6),
                  ),

                _posText(
                  text: d.observacoes,
                  xMm: 35,
                  yMm: 259,
                  dx: _dxCaminhao,
                  dy: _dyCaminhao,
                  widthMm: 175,
                  size: 9,
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }
}
