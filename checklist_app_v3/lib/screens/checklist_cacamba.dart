import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/checklist_models.dart';
import '../services/pdf_service.dart';
import '../widgets/assinatura_box.dart';
import '../widgets/checklist_item_widget.dart';
import '../screens/calibrador_screen.dart';

class ChecklistCacambaScreen extends StatefulWidget {
  const ChecklistCacambaScreen({super.key});

  @override
  State<ChecklistCacambaScreen> createState() => _ChecklistCacambaScreenState();
}

class _ChecklistCacambaScreenState extends State<ChecklistCacambaScreen> {
  final data = ChecklistCacambaData();
  final _pdfService = PdfService();

  // ✅ Controllers para campos de data
  late final TextEditingController _ctrlDataChegada;
  late final TextEditingController _ctrlDataEntrada;

  @override
  void initState() {
    super.initState();
    _ctrlDataChegada = TextEditingController(text: data.dataChegada);
    _ctrlDataEntrada = TextEditingController(text: data.dataEntrada);
  }

  @override
  void dispose() {
    _ctrlDataChegada.dispose();
    _ctrlDataEntrada.dispose();
    super.dispose();
  }

  // Regra para liberar PDF:
  bool get _itensOk =>
      data.itens.every((i) => i.resposta != null) &&
      data.assinaturaMotoristaPng != null &&
      data.assinaturaVigilantePng != null;

  // -------------------- DATE HELPERS --------------------

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  DateTime? _parseDateBr(String s) {
    // espera dd/MM/yyyy
    final t = s.trim();
    if (t.length != 10) return null;
    try {
      final dd = int.parse(t.substring(0, 2));
      final mm = int.parse(t.substring(3, 5));
      final yyyy = int.parse(t.substring(6, 10));
      return DateTime(yyyy, mm, dd);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required void Function(String) onSelected,
  }) async {
    final now = DateTime.now();
    final current = _parseDateBr(controller.text) ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Selecione a data',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );

    if (picked == null) return;
    final formatted = _fmtDate(picked);

    setState(() {
      controller.text = formatted;
      onSelected(formatted);
    });
  }

  Widget _campoData(
    String label, {
    required TextEditingController controller,
    required void Function(String) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_month),
        ),
        onTap: () => _pickDate(controller: controller, onSelected: onSelected),
      ),
    );
  }

  // ----------------------------------------------------------------------
  void _mostrarResumo() {
    final linhas = <String>[
      'Motorista: ${data.motorista}',
      'Transportadora: ${data.transportadora}',
      'Vigilante: ${data.vigilante}',
      'Placa/Carreta: ${data.placaCarreta}',
      'Placa/Cavalo: ${data.placaCavalo}',
      'Nº da Caçamba: ${data.numeroCacamba}',
      'Chegada: ${data.dataChegada} ${data.horaChegada}',
      'Entrada: Ticket ${data.ticketEntrada} ${data.dataEntrada} ${data.horaEntrada}',
      '--- Itens ---',
    ];
    for (final item in data.itens) {
      linhas.add('${item.numero}) ${item.assunto} => ${item.resposta}');
    }
    linhas.add(
        'Assinatura motorista: ${data.assinaturaMotoristaPng != null ? "OK" : "NÃO"}');
    linhas.add(
        'Assinatura vigilante: ${data.assinaturaVigilantePng != null ? "OK" : "NÃO"}');
    linhas.add('Observações: ${data.observacoes}');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resumo'),
        content: SingleChildScrollView(child: Text(linhas.join('\n'))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  Future<void> _gerarPdf() async {
    if (!_itensOk) return;
    // Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 14),
              Expanded(child: Text('Gerando PDF...')),
            ],
          ),
        ),
      ),
    );
    try {
      final bytes = await _pdfService.gerarPdfCacamba(data);
      if (mounted) Navigator.pop(context);
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'checklist_cacamba.pdf',
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erro ao gerar PDF'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }
  }

  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final infoStatus = _itensOk
        ? 'PDF será gerado conforme o modelo.'
        : 'Preencha todos os itens e assine para gerar o PDF.';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Cabeçalho
              Row(
                children: const [
                  BackButton(),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Check-list de Caçamba',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _secaoTitulo('Dados'),
                      _campo('Motorista', onChanged: (v) => data.motorista = v),
                      _campo('Transportadora',
                          onChanged: (v) => data.transportadora = v),
                      _campo('Vigilante', onChanged: (v) => data.vigilante = v),
                      const SizedBox(height: 10),

                      _secaoTitulo('Veículo / Caçamba'),
                      _campo('Placa/Carreta',
                          onChanged: (v) => data.placaCarreta = v),
                      _campo('Placa/Cavalo',
                          onChanged: (v) => data.placaCavalo = v),
                      _campo('Nº da Caçamba',
                          onChanged: (v) => data.numeroCacamba = v),
                      const SizedBox(height: 10),

                      _secaoTitulo('Chegada no estacionamento'),
                      // ✅ DATA com calendário
                      _campoData(
                        'Data (dd/mm/aaaa)',
                        controller: _ctrlDataChegada,
                        onSelected: (v) => data.dataChegada = v,
                      ),
                      _campo('Horário (hh:mm)',
                          onChanged: (v) => data.horaChegada = v),
                      const SizedBox(height: 10),

                      _secaoTitulo('Entrada na fábrica'),
                      _campo('Nº Ticket',
                          onChanged: (v) => data.ticketEntrada = v),
                      // ✅ DATA com calendário
                      _campoData(
                        'Data (dd/mm/aaaa)',
                        controller: _ctrlDataEntrada,
                        onSelected: (v) => data.dataEntrada = v,
                      ),
                      _campo('Hora (hh:mm)',
                          onChanged: (v) => data.horaEntrada = v),
                      const SizedBox(height: 14),

                      _secaoTitulo('Itens a verificar'),
                      // (mantive seu bloco de itens com as imagens, sem mudar)
                      if (data.itens.isNotEmpty)
                        ChecklistItemWidget(
                          item: data.itens[0],
                          onChanged: (val) =>
                              setState(() => data.itens[0].resposta = val),
                        ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/images/trava_superior.png',
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      if (data.itens.length > 1)
                        ChecklistItemWidget(
                          item: data.itens[1],
                          onChanged: (val) =>
                              setState(() => data.itens[1].resposta = val),
                        ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/images/trava_inferior.png',
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      if (data.itens.length > 2)
                        ChecklistItemWidget(
                          item: data.itens[2],
                          onChanged: (val) =>
                              setState(() => data.itens[2].resposta = val),
                        ),
                      for (int i = 3; i < data.itens.length; i++)
                        ChecklistItemWidget(
                          item: data.itens[i],
                          onChanged: (val) =>
                              setState(() => data.itens[i].resposta = val),
                        ),

                      const SizedBox(height: 10),
                      _secaoTitulo('Assinaturas'),
                      AssinaturaBox(
                        titulo: 'Assinatura do Motorista',
                        onSalvar: (bytes) {
                          data.assinaturaMotoristaPng = bytes;
                          setState(() {});
                        },
                      ),
                      AssinaturaBox(
                        titulo: 'Assinatura do Vigilante',
                        onSalvar: (bytes) {
                          data.assinaturaVigilantePng = bytes;
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 5),
                      _secaoTitulo('Observações'),
                      TextField(
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Digite aqui...',
                        ),
                        onChanged: (v) => data.observacoes = v,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _mostrarResumo,
                      child: const Text('Resumo'),
                    ),
                  ),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CalibradorScreen(
                              initialTemplate: CalibradorTemplate.cacamba,
                            ),
                          ),
                        );
                      },
                      child: const Text('Calibrar Caçamba (mm)'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _itensOk ? _gerarPdf : null,
                      child: const Text('Gerar PDF'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    infoStatus,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // COMPONENTES DE UI -------------------------------------------------------
  Widget _secaoTitulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _campo(String label, {required void Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
